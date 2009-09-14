require 'dm-core'
require 'mongo'
require 'json'

dir = Pathname(__FILE__).dirname.expand_path / 'dm-mongo-adapter'

require dir / 'query'
require dir / 'adapter'
require dir / 'types'