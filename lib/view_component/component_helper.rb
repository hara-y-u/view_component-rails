require 'view_component/view_component'

class ViewComponent
  module ComponentHelper
    extend ActiveSupport::Concern

    included do
      alias_method :c, :render_component
    end

    def render_component(path, attributes = {}, options = {})
      if ViewComponent.components.nil? || ViewComponent.components[path].nil?
        fail "Register component like `ViewComponent.register('#{path}')`
              in config/initializer/component.rb"
      else
        component = ViewComponent.components[path]
        opts = {
          component_locals: attributes
        }
        opts.merge!(options)
        component.controller = controller || parent_component.controller
        component.render(opts)
      end
    end
  end
end
