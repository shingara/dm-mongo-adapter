require 'dm-core/spec/adapter_shared_spec'

require File.join(File.dirname(__FILE__), 'spec_helper')

describe DataMapper::Adapters::MongoAdapter do
  before do
    Heffalump.property :id, DataMapper::Mongo::Types::ObjectID
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

  it_should_behave_like 'An Adapter'

  describe "associations" do
    before :all do
      class User
        include DataMapper::Resource

        property :id, DataMapper::Mongo::Types::ObjectID
        property :group_id, DataMapper::Mongo::Types::ObjectID, :field => 'group_id'
        property :name, String
        property :age, Integer
      end

      class Group
        include DataMapper::Resource

        property :id, DataMapper::Mongo::Types::ObjectID
        property :name, String
      end

      User.belongs_to :group
      Group.has Group.n, :users
    end

    before :each do
      @db.drop_collection('users')
      @db.drop_collection('groups')

      @john = User.create(:name => 'john', :age => 101)
      @jane = User.create(:name => 'jane', :age => 102)

      @group = Group.create(:name => 'dm hackers')
    end

    describe "belongs_to" do
      it "should set parent object _id" do
        lambda {
          @john.group = @group
          @john.save
        }.should_not raise_error

        @john.group_id.should eql(@group.id)
      end

      it "should fetch parent object" do
        user = User.create(:name => 'jane')
        user.group_id = @group.id
        user.group.should eql(@group)
      end
    end

    describe "has many" do
      before :each do
        [@john, @jane].each { |user| user.update(:group_id => @group.id) }
      end

      it "should get children" do
        @group.users.size.should eql(2)
      end

      it "should add new children with <<" do
        user = User.new(:name => 'kyle')
        @group.users << user
        user.group_id.should eql(@group.id)
        @group.users.size.should eql(3)
      end

      it "should replace children" do
        user = User.create(:name => 'stan')
        @group.users = [user]
        @group.users.size.should eql(1)
        @group.users.first.should eql(user)
      end

      it "should fetch children matching conditions" do
        users = @group.users.all(:name => 'john')
        users.size.should eql(1)
      end
    end
  end
end
