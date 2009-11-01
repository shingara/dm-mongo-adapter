require 'dm-core/spec/adapter_shared_spec'

require File.join(File.dirname(__FILE__), 'spec_helper')

describe DataMapper::Adapters::MongoAdapter do
  before do
    Heffalump.property :id, DataMapper::Mongo::Types::ObjectID, :key => true, :field => '_id'
  end

  before :all do
    @db = Mongo::Connection.new.db('dm-mongo-test')

    # let's start with an empty collection
    @db.drop_collection('heffalumps')

    # DataMapper::Logger.new(STDOUT, :debug)
    @adapter = DataMapper.setup(:default,
      :adapter  => 'mongo',
      :hostname => 'localhost',
      :database => 'dm-mongo-test'
    )
  end

#  after :all do
#    @db.drop_collection('heffalumps')
#  end

  it_should_behave_like 'An Adapter'
end
