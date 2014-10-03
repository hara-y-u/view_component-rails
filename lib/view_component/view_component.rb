require 'view_component/view_model'

class ViewComponent
  extend ActiveSupport::Autoload

  class << self
    attr_accessor :components, :helpers

    def register_asset_path(path)
      path = path.join('assets')
      paths = assets_config.paths
      paths << path unless paths.include?(path)
      assets_config.paths = paths
    end

    def register(path)
      @components ||= ActiveSupport::HashWithIndifferentAccess.new
      @components[path] ||= component = new(path)
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

    def assets_config
      ::Rails.configuration.assets
    end

    def config
      ::Rails.configuration.view_component
    end

    def routes
      ::Rails.application.routes
    end

    def rails_root
      ::Rails.root
    end
  end

  attr_accessor :path, :controller

  def initialize(path)
    @path = path
  end

  def full_path
    self.class.rails_root.join(self.class.config.components_path, path)
  end

  def full_path_in_app
    self.class.config.components_path + '/' + path
  end

  def main_partial_path_in_view
    self.class.config.components_path.gsub(/\Aapp\/views\//, '') + '/' +
      path + '/' + self.class.config.main_partial_name
  end

  def view_model_names
    Array(self.class.name) + path.split('/').map(&:capitalize)
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
       self.class.config.components_path, 'app/views/application']
    )
  end

  def view_renderer
    @view_renderer ||= ActionView::Renderer.new(lookup_context)
  end

  def view_context_class(locals)
    parent_component = self
    Class.new(view_model_class) do
      include ViewComponent.routes.url_helpers
      include ViewComponent.routes.mounted_helpers
      include *ViewComponent.helpers

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
end
