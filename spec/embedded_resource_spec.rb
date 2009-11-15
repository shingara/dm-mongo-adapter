require File.join(File.dirname(__FILE__), 'spec_helper')

describe DataMapper::Mongo::EmbeddedResource do
  DataMapper.setup(:default,
    :adapter  => 'mongo',
    :hostname => 'localhost',
    :database => 'dm-mongo-test'
  )

  class User
    include DataMapper::Mongo::Resource

    property :id,   ObjectID
    property :name, String
    property :age,  Integer
  end

  class Address
    include DataMapper::Mongo::EmbeddedResource

    property :id,          ObjectID
    property :street,      String
    property :location,    String
    property :subdivision, String
    property :postal_code, String
    property :country,     String
  end

  User.property :address, DataMapper::Mongo::Types::EmbeddedResource

  before :all do
    @db = Mongo::Connection.new.db('dm-mongo-test')
    @db.drop_collection('users')
  end

  describe "as a property" do
    it "should be able to assign an embedded resource" do
      lambda {
        User.new.address = new_address
      }.should_not raise_error
    end

    it "should be able to save a resource" do
      lambda {
        address = new_address
        user = User.new(:address => address)
        user.save
        user.address.should eql(address)
      }.should_not raise_error
    end

    it "should load the embedded resource when fetching the parent" do
      address = new_address
      user = User.create(:name => 'john', :age => 100, :address => new_address)

      User.get(user.id).address.should eql(address)
    end

    def new_address
      Address.new(:street => '1st avenue', :location => 'nyc', :country => 'us')
    end
  end
end