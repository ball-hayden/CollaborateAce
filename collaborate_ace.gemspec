$LOAD_PATH.push File.expand_path('../lib', __FILE__)

# Maintain your gem's version:
require 'collaborate/ace/version'

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = 'collaborate-ace'
  s.version     = Collaborate::Ace::VERSION
  s.authors     = ['Hayden Ball']
  s.email       = ['hayden@haydenball.me.uk']
  s.homepage    = 'TODO'
  s.summary     = 'TODO: Summary of Collaborate.'
  s.description = 'TODO: Description of Collaborate.'
  s.license     = 'MIT'

  s.files = Dir['{app,config,db,lib}/**/*', 'MIT-LICENSE', 'Rakefile', 'README.rdoc']
  s.test_files = Dir['spec/**/*']

  s.add_dependency 'rails', '> 4.2.0'
  s.add_dependency 'collaborate'

  s.add_development_dependency 'mysql2'
  s.add_development_dependency 'teaspoon-jasmine'
end
