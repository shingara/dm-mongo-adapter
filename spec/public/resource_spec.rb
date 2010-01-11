require File.expand_path(File.join(File.dirname(__FILE__), '..', 'spec_helper'))

describe DataMapper::Mongo::Resource do

  before(:all) do
    class Address
      include DataMapper::Mongo::EmbeddedResource
      property :city, String
    end

    class User
      include DataMapper::Mongo::Resource
      property :id,   ObjectID
      property :name, String
      embeds 1, :address,   :model => Address
      embeds n, :locations, :model => Address
    end
  end

  #
  # all
  #

  describe '#all' do
    describe 'with no query' do
      it 'should return a collection' do
        User.all.should be_kind_of(DataMapper::Collection)
      end

      it 'should return an empty collection when there are no resources' do
        User.all.destroy!
        User.all.should be_empty
      end

      it 'should return all resources' do
        expected = [User.create(:name => 'One'), User.create(:name => 'Two')]
        User.all.should == expected
      end
    end

    describe 'with a query' do
      it 'should return a collection' do
        User.all.should be_kind_of(DataMapper::Collection)
      end

      it 'should return an empty collection when there are no matching resources' do
        User.all.destroy!
        User.create(:name => 'One')
        User.all(:name => 'Two').should be_empty
      end

      it 'should return the specific resources' do
        User.create(:name => 'One')
        expected = User.create(:name => 'Two')
        User.all(:name => 'Two').should == [expected]
      end
    end
  end

  #
  # first
  #

  describe '#first' do
    before(:all) do
      User.all.destroy!
      @user_one = User.create(:name => 'Three')
      @user_two = User.create(:name => 'Four')
    end

    describe 'with no query' do
      it 'should return a resource' do
        User.first.should be_kind_of(DataMapper::Mongo::Resource)
      end

      it 'should return the first resource' do
        User.first.should == @user_one
      end
    end

    describe 'when a query' do
      it 'should return a resource' do
        User.first(:name => @user_two.name).should \
          be_kind_of(DataMapper::Mongo::Resource)
      end

      it 'should return the first resource' do
        User.first(:name => @user_two.name).should == @user_two
      end
    end
  end

  #
  # dirty?
  #

  describe '#dirty?' do
    describe 'when the resource has a change' do
      it 'should return true' do
        User.new(:name => 'Mongo').should be_dirty
      end
    end

    describe 'when the resource has no changes' do
      it 'should return true if a one-to-one embedment has a change' do
        user = User.new(:address => Address.new(:city => 'Rock Ridge'))
        user.should be_dirty
      end

      it 'should return false having just been saved' do
        user = User.new(:address => Address.new(:city => 'Rock Ridge'))
        user.save
        user.should_not be_dirty
      end

      it 'should return true if a one-to-many embedment has a change' do
        user = User.new
        user.locations << Address.new(:city => 'Rock Ridge')
        user.should be_dirty
      end

      it 'should return false if no embedments have changes' do
        user = User.new(:address => Address.new(:city => 'Rock Ridge'))
        user.locations << Address.new(:city => 'Rock Ridge')
        user.save
        user.should_not be_dirty
      end
    end
  end

end
