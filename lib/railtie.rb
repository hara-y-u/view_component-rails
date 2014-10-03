require 'rails/railtie'
require 'view_component'

module ViewComponent
  class Railtie < Rails::Railtie
    config.view_component = ActiveSupport::OrderedOptions.new

    config.view_component.components_path = 'app/views/components'
    config.view_component.main_partial_name = 'show'

    initializer 'ungarbled' do
      ::ActionView::Base.send(:include, Component::ComponentHelper)
    end
  end
end
