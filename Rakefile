require 'rubygems'
require 'rake'

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gem|
    gem.name     = "dm-mongo-adapter"
    gem.summary  = %Q{Mongo DataMapper Adapter.}
    gem.email    = "shane.hanna@gmail.com, piotr.solnica@gmail.com, lcarlson@rubyskills.com"
    gem.homepage = "http://github.com/solnic/dm-mongo-adapter"
    gem.authors  = ['Shane Hanna', 'Piotr Solnica', 'Lance Carlson']
    gem.add_dependency 'dm-core', '~> 0.10.0'
    gem.add_dependency 'mongo', '~> 0.18.2' # gemcutter
    # gem is a Gem::Specification... see http://www.rubygems.org/read/chapter/20 for additional settings
  end
rescue LoadError
  puts "Jeweler (or a dependency) not available. Install it with: sudo gem install jeweler"
end

require 'spec/rake/spectask'
Spec::Rake::SpecTask.new(:spec) do |spec|
  spec.spec_opts = ['-c -L random -f s']
  spec.libs << 'lib' << 'spec'
  spec.spec_files = FileList['spec/**/*_spec.rb']
end
 
Spec::Rake::SpecTask.new(:rcov) do |spec|
  spec.spec_opts = ['-c -L random -f s']
  spec.libs << 'lib' << 'spec'
  spec.pattern = 'spec/**/*_spec.rb'
  spec.rcov = true
end

task :install_fast do
  sh "rake build; gem install pkg/dm-mongo-adapter*.gem --local"
end