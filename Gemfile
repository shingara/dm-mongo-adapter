source 'http://rubygems.org'

group :runtime do
  MONGO_VERSION = '~> 1.2.4'

  # MongoDB driver
  gem 'bson_ext', :platforms => [ :mri ]
  gem 'mongo', MONGO_VERSION

  # DataMapper libs
  DM_VERSION = '~> 1.1.0'

  gem 'dm-core',       DM_VERSION
  gem 'dm-aggregates', DM_VERSION
  gem 'dm-migrations', DM_VERSION
end

group :development do
  gem 'rake'
  gem 'rcov',    '~> 0.9.9', :platforms => [ :mri_18 ]
  gem 'rspec',   '~> 1.3'
  gem 'jeweler', '~> 1.5.1'
  gem 'yard',    '~> 0.5'
end

group :quality do
  gem 'yardstick', '~> 0.1'
end
