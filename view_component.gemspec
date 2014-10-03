$:.push File.expand_path('../lib', __FILE__)

# Maintain your gem's version:
require 'view_component/version'

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = 'view_component-rails'
  s.version     = ViewComponent::VERSION
  s.authors     = ['yukihiro hara']
  s.email       = ['yukihr@gmail.com']
  s.homepage    = 'https://github.com/yukihr/view_component-rails'
  s.summary     = 'TODO: Summary of ViewComponent.'
  s.description = 'TODO: Description of ViewComponent.'
  s.license     = 'MIT'

  s.files = Dir['{app,config,db,lib}/**/*', 'MIT-LICENSE', 'Rakefile', 'README.rdoc']
  s.test_files = Dir['test/**/*']
  s.require_paths = ['lib']

  s.required_ruby_version = '>= 1.9.3'

  s.add_dependency 'rails', '>= 4.0.0'

  s.add_development_dependency 'bundler', '>= 0'
  s.add_development_dependency 'pg'
end
