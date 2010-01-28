require File.expand_path(File.join(File.dirname(__FILE__), '..', 'spec_helper'))

describe DataMapper::Mongo::Model do

  before(:all) do
    class ::PropertyTest
      include DataMapper::Mongo::Resource
      property :array,     Array
      property :hash,      Hash
      property :date,      Date
      property :date_time, DateTime
    end
  end

  describe '#property' do
    it 'should cast Array types to EmbeddedArray' do
      prop = PropertyTest.properties[:array]
      prop.type.should == DataMapper::Mongo::Types::EmbeddedArray
    end

    it 'should cast Hash types to EmbeddedHash' do
      prop = PropertyTest.properties[:hash]
      prop.type.should == DataMapper::Mongo::Types::EmbeddedHash
    end

    it 'should cast Hash types to Types::Date' do
      prop = PropertyTest.properties[:date]
      prop.type.should == DataMapper::Mongo::Types::Date
    end

    it 'should cast Hash types to Types::DateTime' do
      prop = PropertyTest.properties[:date_time]
      prop.type.should == DataMapper::Mongo::Types::DateTime
    end
  end

end
