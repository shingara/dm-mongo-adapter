source 'http://gemcutter.org'

group :runtime do
  # MongoDB driver
  gem 'mongo',     '~> 0.19'
  gem 'mongo_ext', '~> 0.19'

  # ActiveSupport is preffered over Extlib
  gem 'activesupport', '~> 3.0.0.beta1', :git => 'git://github.com/rails/rails.git', :require => false

  # DataMapper libs
  gem 'dm-core',       :git => 'git://github.com/datamapper/dm-core.git', :branch => 'next'
  gem 'dm-aggregates', :git => 'git://github.com/snusnu/dm-more.git',     :branch => 'active_support'
end

group :development do
  gem 'rake'
  gem 'rcov'
  gem 'rspec'
  gem 'jeweler'
  gem 'yard',      '~> 0.5'
end

group :quality do
  gem 'yardstick', '~> 0.1'
end
