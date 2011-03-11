source 'http://rubygems.org'

group :runtime do
  # MongoDB driver
  gem 'mongo',     '~> 1.1'

  platforms :mri_18, :mri_19 do
    gem 'bson_ext',  '~> 1.1'
  end

  # DataMapper libs
  DM_VERSION = '~> 1.1.0.rc3'

  gem 'dm-core',       DM_VERSION
  gem 'dm-aggregates', DM_VERSION
  gem 'dm-migrations', DM_VERSION
end

group :development do
  gem 'rake'
  gem 'rcov'
  gem 'rspec',   '~> 1.3'
  gem 'jeweler', '~> 1.5.1'
  gem 'yard',    '~> 0.5'
end

group :quality do
  gem 'yardstick', '~> 0.1'
end
