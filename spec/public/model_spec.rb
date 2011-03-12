require File.expand_path(File.join(File.dirname(__FILE__), '..', 'spec_helper'))

describe DataMapper::Mongo::Model do
  before(:all) do
    class ::PropertyTest
      include DataMapper::Mongo::Resource
      property :array_attr, Array
      property :hash_attr,  Hash
    end
  end

  describe '#property' do
    it 'should cast Array class to DataMapper::Mongo::Property::Array' do
      prop = PropertyTest.properties[:array_attr]
      prop.should be_kind_of(DataMapper::Mongo::Property::Array)
    end

    it 'should cast Hash class to DataMapper::Mongo::Property::Hash' do
      prop = PropertyTest.properties[:hash_attr]
      prop.should be_kind_of(DataMapper::Mongo::Property::Hash)
    end
  end
end
