require File.join(File.dirname(__FILE__), 'spec_helper')

include DataMapper::Mongo

describe DataMapper::Model::Embedment do
  before :all do
    @db = Mongo::Connection.new.db('dm-mongo-test')

    # let's start with an empty collection
    @db.drop_collection('users')

    # DataMapper::Logger.new(STDOUT, :debug)
    @adapter = DataMapper.setup(:default,
      :adapter  => 'mongo',
      :hostname => 'localhost',
      :database => 'dm-mongo-test'
    )

    class User
      include Resource

      property :id,   ObjectID
      property :name, String
      property :age,  Integer
    end

    class Address
      include EmbeddedResource

      property :street,    String
      property :post_code, String
      property :phone,     String
    end
  end

  describe "Resource" do
    it "should respond to #embeds" do
      User.should respond_to(:embeds)
    end

    it "should respond to #embedded_in" do
      User.should respond_to(:embedded_in)
    end

    it "should respond to #embedments" do
      User.should respond_to(:embedments)
    end
  end

  describe "#embeds" do
    describe "One-To-One Relationship" do
      before :all do
        User.embeds(1, :address, :model => Address)
        @user_attributes = {:name => 'piotr', :address => {:street => '1st ave', :post_code => '123-45'}}
      end

      it "should create a new embedment" do
        User.embedments[:address].class.should be(Embedments::OneToOne::Relationship)
      end

      it "should create readers and writers for the embedded resource" do
        user = User.new

        user.should respond_to("address")
        user.should respond_to("address=")
      end

      it "should set the embedded resource" do
        user = User.new
        address = Address.new

        user.address = address
        user.address.should be(address)
      
        address.parent.should be(user)
      end

      it "should save the embedded resource" do
        user = User.new(@user_attributes)
        user.save.should be(true)
        user.address.new?.should be(false)
      end

      it "should load parent and the embedded resource" do
        _id = @db.collection('users').insert(@user_attributes)

        user = User.get(_id)

        user.address.should_not be_nil
      end
    end

    describe "Many-To-One Relationship" do
      it "should be implemented"
    end
  end
end
