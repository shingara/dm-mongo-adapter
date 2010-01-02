$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))

require 'spec'
require 'mongo_adapter'

include DataMapper::Mongo
