require 'dm-core'
require 'dm-aggregates'
require 'mongo'

dir = Pathname(__FILE__).dirname.expand_path + 'dm-mongo-adapter'

require dir + 'query'
require dir + 'query' + 'java_script'

require dir + 'property' + 'object_id'
require dir + 'property' + 'db_ref'
require dir + 'property' + 'array'
require dir + 'property' + 'hash'

require dir + 'support' + 'class'
require dir + 'support' + 'date'
require dir + 'support' + 'date_time'
require dir + 'support' + 'object'

require dir + 'migrations'
require dir + 'model'
require dir + 'resource'
require dir + 'migrations'
require dir + 'modifier'

require dir + 'aggregates'
require dir + 'adapter'
