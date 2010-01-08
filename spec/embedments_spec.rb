require File.join(File.dirname(__FILE__), 'spec_helper')

describe DataMapper::Model::Embedment do
  before :all do
    # let's start with an empty collection
    $db.drop_collection('users')

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

    class Car
      include EmbeddedResource

      property :name, String
    end

    @user_attributes = {:name => 'piotr', :age => 26, :address => {:street => '1st ave', :post_code => '123-45'}}
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
      end

      describe "#dirty?" do
        it "should return false without dirty attributes and without an embedded resource" do
          u = User.new
          u.dirty?.should be_false
        end

        it "should return true with a dirty attributes and with an embedded resource" do
          u = User.new(@user_attributes.except(:address))
          u.dirty?.should be_true
        end
      end

      it "should create a new embedment" do
        User.embedments[:address].class.should be(Embedments::OneToOne::Relationship)
      end

      it "should create readers and writers for the embedded resource" do
        user = User.new

        user.should respond_to("address")
        user.should respond_to("address=")
      end

      it "should not require embedded resource to save the parent" do
        user = User.new(@user_attributes.except(:address))
        user.save.should be_true
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
        _id = $db.collection('users').insert(@user_attributes)

        user = User.get(_id)

        user.address.should_not be_nil
      end

      it "should load parent if the embedded resource is nil" do
        _id = $db.collection('users').insert(:name => 'john')

        user = User.get(_id)
        user.address.should_not be_nil
      end
    end

    describe "One-to-Many Relationship" do
      before :all do
        User.embeds User.n, :cars
      end

      it "should create a new embedment" do
        User.embedments[:cars].class.should be(Embedments::OneToMany::Relationship)
      end

      it "should create readers and writers for the embedded resource" do
        user = User.new

        user.should respond_to("cars")
        user.should respond_to("cars=")
      end

      it "should set the embedded collection" do
        user = User.new

        3.times { user.cars << Car.new }

        user.cars.size.should eql(3)
        user.cars.all?{ |c| c.parent == user }.should be(true)
      end

      it "should save the embedded resources" do
        user = User.new @user_attributes.except(:address)

        ['ford', 'honda', 'volvo'].each { |name| user.cars << Car.new(:name => name) }

        user.save.should be(true)
        user.cars.all? { |car| car.saved? }.should be(true)
      end

      it "should load parent with its embedded collection" do
        _id = $db.collection('users').insert(
          "name"=>"piotr", "cars"=>[{"name"=>"ford"}, {"name"=>"honda"}, {"name"=>"volvo"}], "age"=>26)

        user = User.get(_id)

        user.cars.should_not be_nil
        user.cars.size.should eql(3)
      end
    end

    describe "Many-To-One Relationship" do
      it "should be implemented"
    end
  end
end
