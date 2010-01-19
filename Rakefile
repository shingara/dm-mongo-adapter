require 'rubygems'
require 'rake'
require 'rake/clean'

CLOBBER.include ['pkg', '*.gem', 'doc', 'coverage', 'measurements']

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gem|
    gem.name        = 'dm-mongo-adapter'
    gem.summary     = 'Mongo DataMapper Adapter'
    gem.description = 'An adapter the DataMapper ORM which adds support for MongoDB.'
    gem.email       = "shane.hanna@gmail.com, piotr.solnica@gmail.com, lcarlson@rubyskills.com"
    gem.homepage    = "http://github.com/solnic/dm-mongo-adapter"
    gem.authors     = ['Shane Hanna', 'Piotr Solnica', 'Lance Carlson']

    gem.has_rdoc    = false

    # Dependencies
    gem.add_dependency 'dm-core', '~> 0.10.0'
    gem.add_dependency 'mongo',   '~> 0.18.2'
    gem.add_development_dependency 'rspec',     '>= 1.2.0'
    gem.add_development_dependency 'yard',      '>= 0.5'
    gem.add_development_dependency 'yardstick', '>= 0.1'
  end

  FileList['tasks/**/*.rake'].each { |task| import task }
rescue LoadError
  puts 'Jeweler (or a dependency) not available. Install it with: sudo gem ' \
       'install jeweler'
end

task :install_fast do
  sh "rake build; gem install pkg/dm-mongo-adapter*.gem --local"
end
