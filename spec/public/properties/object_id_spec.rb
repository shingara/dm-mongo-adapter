require File.expand_path(File.join(File.dirname(__FILE__), '..', '..', 'spec_helper'))

describe DataMapper::Mongo::Property::ObjectId do
  before(:all) do
    class User
      include DataMapper::Mongo::Resource
      property :id,       ObjectId
    end

    @property_class = DataMapper::Mongo::Property::ObjectId
    @property       = User.properties[:id]
  end

  it_should_behave_like 'An ObjectId Type'
end
