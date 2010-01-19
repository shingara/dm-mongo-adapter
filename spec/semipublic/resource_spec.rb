require File.expand_path(File.join(File.dirname(__FILE__), '..', 'spec_helper'))

describe DataMapper::Mongo::Resource do

  before(:all) do
    class Address
      include DataMapper::Mongo::EmbeddedResource
      property :city, String
    end

    class User
      include DataMapper::Mongo::Resource
      property  :id,        ObjectID
      property  :name,      String
      property  :tags,      Array
      property  :metadata,  Hash
      embeds 1, :address,   :model => Address
      embeds n, :locations, :model => Address
    end
  end

  #
  # dirty_attributes
  #

  describe '#dirty_attributes' do
    describe 'when the resource has a change' do
      it 'should return true' do
        dirty = User.new(:name => 'Mongo').dirty_attributes
        dirty.should == { User.properties[:name] => 'Mongo' }
      end
    end

    describe 'when the resource has no changes' do
      it 'should return true if a one-to-one embedment has a change' do
        user = User.new(:address => Address.new(:city => 'Rock Ridge'))
        user.dirty_attributes.should == {
          User.embedments[:address] => {
            Address.properties[:city] => 'Rock Ridge'
          }
        }
      end

      it 'should return false having just been saved' do
        user = User.new(:address => Address.new(:city => 'Rock Ridge'))
        user.save
        user.dirty_attributes.should == {}
        user.dirty_attributes.should be_empty
      end

      it 'should return true if a one-to-many embedment has a change' do
        user = User.new
        user.locations << Address.new(:city => 'Rock Ridge')
        user.dirty_attributes.should == {
          User.embedments[:locations] => [{
            Address.properties[:city] => 'Rock Ridge'
          }]
        }
      end

      it 'should return false if no embedments have changes' do
        user = User.new(:address => Address.new(:city => 'Rock Ridge'))
        user.locations << Address.new(:city => 'Rock Ridge')
        user.save
        user.dirty_attributes.should be_empty
      end
    end
  end # dirty_attributes

end
