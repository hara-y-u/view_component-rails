require 'rails/railtie'
require 'view_component/component_helper'

class ViewComponent
  class Rails < Rails::Railtie
    config.view_component = ActiveSupport::OrderedOptions.new

    config.view_component.components_path = 'app/views/components'
    config.view_component.main_partial_name = 'show'

    initializer 'view_component' do
      ::ActionView::Base.send(:include, ViewComponent::ComponentHelper)
    end
  end
end
