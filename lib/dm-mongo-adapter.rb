gem 'dm-core', '~> 0.10.2'
gem 'mongo', '~> 0.16'

require 'dm-core'
require 'mongo'

dir = Pathname(__FILE__).dirname.expand_path / 'dm-mongo-adapter'

require dir / 'query'
require dir / 'conditions'
require dir / 'types'
require dir / 'resource'
require dir / 'embedments' / 'relationship'
require dir / 'embedments' / 'one_to_one'
require dir / 'model' / 'embedment'
require dir / 'embedded_model'
require dir / 'embedded_resource'
require dir / 'adapter'
