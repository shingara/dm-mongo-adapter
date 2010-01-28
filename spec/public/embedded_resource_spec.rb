require File.expand_path(File.join(File.dirname(__FILE__), '..', 'spec_helper'))

describe DataMapper::Mongo::EmbeddedResource do
  before(:all) do
    class ::Address
      include DataMapper::Mongo::EmbeddedResource
      property :street, String
      property :city,   String, :field => 'conurbation'
    end

    class ::AddressWithDefault
      include DataMapper::Mongo::EmbeddedResource
      property :city, String, :default => 'Rock Ridge'
    end

    class ::User
      include DataMapper::Mongo::Resource
      property :id, ObjectID
      embeds 1, :address, :model => Address
    end
  end

  #
  # attributes
  #

  describe 'attributes' do
    before(:all) do
      @address = Address.new(:street => 'Main Street', :city => 'Rock Ridge')
    end

    it 'should return a Hash' do
      @address.attributes.should be_kind_of(Hash)
    end

    it 'should use the property names when key_on=:name' do
      @address.attributes(:name).should ==
        { :street => 'Main Street', :city => 'Rock Ridge' }
    end

    it 'should use the field names when key_on=:field' do
      @address.attributes(:field).should ==
        { 'street' => 'Main Street', 'conurbation' => 'Rock Ridge' }
    end

    it 'should use the property instances when key_on=:property' do
      @address.attributes(:property).should == {
        Address.properties[:street] => 'Main Street',
        Address.properties[:city]   => 'Rock Ridge'
      }
    end
  end

  #
  # dirty?
  #

  describe '#dirty?' do
    describe 'on a new embedded resource' do
      it 'should return false' do
        Address.new.should_not be_dirty
      end

      it 'should return true if an attribute has been changed' do
        Address.new(:city => 'Rock Ridge').should be_dirty
      end

      it 'should return false if a changed attribute has been saved' do
        address = Address.new(:city => 'Rock Ridge')

        lambda { User.create(:address => address) }.should \
          change(address, :dirty?).to(false)
      end
    end

    describe 'on a persisted embedded resource' do
      before(:each) do
        user = User.create(:address => Address.new(:city => 'Rock Ridge'))
        @address = user.address
      end

      it 'should return false when no changes have been made' do
        @address.should_not be_dirty
      end

      it 'should return true if an attribute has been changed' do
        @address.street = 'Main Street'
        @address.should be_dirty
      end

      it 'should return false if a changed attribute has been saved' do
        @address.street = 'Main Street'

        lambda { @address.parent.save }.should \
          change(@address, :dirty?).to(false)
      end
    end
  end

  #
  # dirty_self?
  #

  describe '#dirty_self?' do
    describe 'on a new embedded resource' do
      it 'should return false if no changes have been made and no ' \
         'properties have a default' do
        Address.new.should_not be_dirty_self
      end

      it 'should return true if no changes have been made, but a property ' \
         'has a default' do
        AddressWithDefault.new.should be_dirty_self
      end

      it 'should return true if a change has been made' do
        Address.new(:city => 'Rock Ridge').should be_dirty_self
      end
    end

    describe 'on a persisited embedded resource' do
      before(:each) do
        user = User.create(:address => Address.new(:city => 'Rock Ridge'))
        @address = user.address
      end

      it 'should return false if no changes have been made' do
        @address.should_not be_dirty_self
      end

      it 'should return true if a change has been made' do
        @address.street = 'Main Street'
        @address.should be_dirty_self
      end
    end
  end

  #
  # parent?
  #

  describe '#parent?' do
    it 'should return true if the embedded resource has a parent' do
      address = Address.new
      address.parent = User.new
      address.parent?.should be_true
    end

    it 'should return false if the embedded resource has no parent' do
      Address.new.parent?.should be_false
    end
  end

  #
  # new?
  #

  describe '#new?' do
    it 'should return false if it has been persisted' do
      user = User.create(:address => Address.new(:city => 'Rock Ridge'))
      user.address.should_not be_new
    end

    it 'should return true if its parent has not been persisted' do
      user = User.new(:address => Address.new(:city => 'Rock Ridge'))
      user.address.should be_new
    end

    it 'should return true if it has no parent' do
      Address.new.should be_new
    end
  end

  #
  # saved?
  #

  describe '#saved?' do
    it 'should return true if it has been persisted' do
      user = User.create(:address => Address.new(:city => 'Rock Ridge'))
      user.address.should be_saved
    end

    it 'should return false if its parent has not been persisted' do
      user = User.new(:address => Address.new(:city => 'Rock Ridge'))
      user.address.should_not be_saved
    end

    it 'should return false if it has no parent' do
      Address.new.should_not be_saved
    end
  end

  #
  # save
  #

  describe '#save' do
    it 'should raise MissingParentError if no parent is set' do
      lambda { Address.new.save }.should raise_error(
        DataMapper::Mongo::EmbeddedResource::MissingParentError)
    end

    it 'should clear the original attributes if the parent saved' do
      user = User.new(:address => Address.new(:city => 'Rock Ridge'))

      expectation = lambda { user.address.original_attributes.empty? }
      lambda { user.address.save }.should change(&expectation).to(true)
    end

    it 'should not clear the original_attributes is the parent did not save' do
      user = User.new(:address => Address.new(:city => 'Rock Ridge'))
      user.stub!(:save).and_return(false)

      expectation = lambda { user.address.original_attributes.empty? }
      lambda { user.address.save }.should_not change(&expectation).to(true)
    end
  end

end
