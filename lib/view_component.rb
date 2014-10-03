require 'active_support'
require 'action_view'

module ViewComponent
  extend ActiveSupport::Autoload

  self.config = Rails.configuration.view_component
  COMPONENTS_PATH = config.components_path
  MAIN_PARTIAL_NAME = config.main_partial_name

  class << self
    attr_accessor :components, :helpers

    Rails.application.config.assets.paths << COMPONENTS_PATH

    def register_asset_path(path)
      path = path.join('assets')
      paths = Rails.application.config.assets.paths
      paths << path unless paths.include?(path)
      Rails.application.config.assets.paths = paths
    end

    def register(path)
      @components ||= ActiveSupport::HashWithIndifferentAccess.new
      @components[path] ||= component = Component.new(path)
      register_asset_path(component.full_path)
      if component.view_model_class_file_exist?
        eager_autoload do
          autoload_at component.view_model_class_path do
            component.view_model_names.each do |module_name|
              autoload module_name
            end
          end
        end
      end
    end

    def add_helper(helper_module)
      @helpers ||= []
      @helpers << helper_module
    end
  end

  module ComponentHelper
    extend ActiveSupport::Concern

    included do
      alias_method :c, :render_component
    end

    def render_component(path, attributes = {}, options = {})
      if Component.components.nil? || Component.components[path].nil?
        fail "Register component like `Component.register('#{path}')`
              in config/initializer/component.rb"
      else
        component = Component.components[path]
        opts = {
          component_locals: attributes
        }
        opts.merge!(options)
        component.controller = controller || parent_component.controller
        component.render(opts)
      end
    end
  end

  attr_accessor :path, :controller

  def initialize(path)
    @path = path
  end

  def full_path
    Rails.root.join(COMPONENTS_PATH, path)
  end

  def full_path_in_app
    COMPONENTS_PATH + '/' + path
  end

  def main_partial_path_in_view
    COMPONENTS_PATH.gsub(/\Aapp\/views\//, '') + '/' +
      path + '/' + MAIN_PARTIAL_NAME
  end

  def view_model_names
    Array('Component') + path.split('/').map(&:capitalize)
  end

  def view_model_class_name
    view_model_names.join('::')
  end

  def basename
    File.basename(path)
  end

  def view_model_class_path
    @view_model_class_path ||=
      File.dirname(full_path) + '/' + basename + '.rb'
  end

  def view_model_class_file_exist?
    File.exist?(view_model_class_path)
  end

  def view_model_class
    if view_model_class_file_exist?
      view_model_class_name.constantize
    else
      ViewModel
    end
  end

  def lookup_context
    @lookup_context ||= ActionView::LookupContext.new(
      ['app/views', full_path_in_app,
       COMPONENTS_PATH, 'app/views/application']
    )
  end

  def view_renderer
    @view_renderer ||= ActionView::Renderer.new(lookup_context)
  end

  def view_context_class(locals)
    parent_component = self
    Class.new(view_model_class) do
      include *Component.helpers

      define_local_getters(locals)

      define_method :parent_component do
        parent_component
      end
    end
  end

  def view_context(locals = {}, view_assigns = {})
    view_context_class(locals)
      .new(view_renderer, view_assigns, controller)
      .tap do |context|
      context.component = self
    end
  end

  def render(options, view_assigns = {})
    # render with PartialRenderer
    options[:partial] ||= main_partial_path_in_view
    context = view_context(options.delete(:component_locals), view_assigns)
    context.render(options)
  end

  class ViewModel < ActionView::Base
    include Rails.application.routes.url_helpers
    include Rails.application.routes.mounted_helpers

    attr_accessor :component

    def self.define_local_getters(locals)
      locals.each do |key, val|
        fail "Method for local variable #{key} is already defined" if
          method_defined?(key)

        define_method key.to_sym do
          val
        end
      end
    end
  end
end
