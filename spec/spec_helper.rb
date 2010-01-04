$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))

require 'spec'
require 'mongo_adapter'

$adapter = DataMapper.setup(:default,
                            :adapter  => 'mongo',
                            :hostname => 'localhost',
                            :database => 'dm-mongo-test'
                            )

$db = Mongo::Connection.new.db('dm-mongo-test')

include DataMapper::Mongo
