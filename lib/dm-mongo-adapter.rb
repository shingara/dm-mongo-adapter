gem 'dm-core', '~> 0.10.2'
gem 'mongo', '~> 0.16'

require 'dm-core'
require 'mongo'

dir = Pathname(__FILE__).dirname.expand_path / 'dm-mongo-adapter'

require dir / 'query'
require dir / 'adapter'
require dir / 'types'
require dir / 'resource'
