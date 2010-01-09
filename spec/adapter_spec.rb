require File.join(File.dirname(__FILE__), 'spec_helper')
require File.join(File.dirname(__FILE__), 'adapter_shared_spec')

describe DataMapper::Adapters::MongoAdapter do
  before :all do
    @adapter = $adapter
    # let's start with an empty collection
    $db.drop_collection('heffalumps')

    class ::Heffalump
      include DataMapper::Mongo::Resource

      property :id,        ObjectID
      property :color,     String
      property :num_spots, Integer
      property :striped,   Boolean
    end
  end

  it_should_behave_like "An Adapter"

  describe "authentication" do
    before(:all) do
      # Create a user if needed.
      @details = { :username => 'dm-mongo-auth',
                   :password => 'dm-mongo-password' }

      connection = Mongo::Connection.new

      begin
        users = connection.db('dm-mongo-test-auth').collection('system.users')

        # Remove the existing user if one is present.
        users.remove(:user => @details[:username])
        users.remove(:username => @details[:username])

        # Create a new user.
        users.save(
          :user => @details[:username],
          :pwd  => Digest::MD5.hexdigest(
            "#{@details[:username]}:mongo:#{@details[:password]}")
        )
      ensure
        connection.close
      end
    end

    it 'should raise no error when connecting with valid credentials' do
      DataMapper.setup(:dm_mongo_auth,
        :adapter  => 'mongo',
        :hostname => 'localhost',
        :database => 'dm-mongo-test-auth',
        :username => @details[:username],
        :password => @details[:password]
      )

      lambda do
        repository(:dm_mongo_auth) do
          Heffalump.create(:color => 'red', :num_spots => 2)
        end
      end.should_not raise_error(DataMapper::Mongo::Adapter::ConnectionError)
    end

    it 'should raise an error when connecting with an invalid username' do
      DataMapper.setup(:dm_mongo_auth,
        :adapter  => 'mongo',
        :hostname => 'localhost',
        :database => 'dm-mongo-test',
        :username => @details[:username],
        :password => '__invalid__'
      )

      lambda do
        repository(:dm_mongo_auth) do
          Heffalump.create(:color => 'red', :num_spots => 2)
        end
      end.should raise_error(DataMapper::Mongo::Adapter::ConnectionError)
    end

    it 'should raise an error when connecting with an invalid password' do
      DataMapper.setup(:dm_mongo_auth,
        :adapter  => 'mongo',
        :hostname => 'localhost',
        :database => 'dm-mongo-test',
        :username => '__invalid__',
        :password => @details[:password]
      )

      lambda do
        repository(:dm_mongo_auth) do
          Heffalump.create(:color => 'red', :num_spots => 2)
        end
      end.should raise_error(DataMapper::Mongo::Adapter::ConnectionError)
    end
  end

  describe "queries" do
    before :all do
      @red   = Heffalump.create(:color => 'red', :num_spots => 2)
      @green = Heffalump.create(:color => 'green', :num_spots => 3)
      @blue  = Heffalump.create(:color => 'blue', :num_spots => 5)
    end

    it "should be able to search for objects matching conditions for the same property" do
      col = Heffalump.all(:num_spots.gt => 2, :num_spots.not => 3)

      col.size.should == 1
      col.first.should eql(@blue)
    end
  end

  describe "embedded objects as properties" do
    before :all do
      class Zoo
        include DataMapper::Mongo::Resource

        property :id, ObjectID
        property :animals, EmbeddedArray
        property :address, EmbeddedHash
      end
    end

    describe "using arrays" do
      it "should save a resource" do
        zoo = Zoo.new
        zoo.animals = [:marty, :alex, :gloria]

        lambda {
          zoo.save
        }.should_not raise_error
      end

      it "should be able to search with 'equal to' criterium" do
        penguins = [:skipper, :kowalski, :private, :rico]
        Zoo.create(:animals => penguins)

        zoo = Zoo.first(:animals => penguins)
        zoo.should_not be_nil
        zoo.animals.should eql(penguins)
      end
    end

    describe "using hashes" do
      it "should save a resource" do
        zoo = Zoo.new
        zoo.address = {:street => 'Street 1', :telephone => '123-45-67'}

        lambda {
          zoo.save
          zoo.address.class.should be(Hash)
        }.should_not raise_error
      end

      it "should set the property value as hash" do
        _id = $db.collection('zoos').insert(:address => { :street => 'Street 2' })

        zoo = Zoo.get(_id)

        zoo.address.should be_kind_of(Hash)
        zoo.address[:street].should eql('Street 2')
      end

      it "should be able to search with 'equal to' criterium" do
        address = {:street => 'Street 3'}

        Zoo.create(:address => address)

        zoo = Zoo.first(:address => address)

        zoo.should_not be_nil
        zoo.address.should == address
      end
    end
  end
end
