require File.expand_path(File.join(File.dirname(__FILE__), '..', '..', 'spec_helper'))

describe DataMapper::Mongo::Property::DBRef do
  before(:all) do
    class User
      include DataMapper::Mongo::Resource

      property :id,       ObjectId
      property :group_id, DBRef
    end

    @property_class = DataMapper::Mongo::Property::DBRef
    @property       = User.properties[:group_id]
  end

  it_should_behave_like 'An ObjectId Type'
end
