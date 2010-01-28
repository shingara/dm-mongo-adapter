require File.expand_path(File.join(File.dirname(__FILE__), '..', 'spec_helper'))

describe DataMapper::Mongo::Resource do

  before(:all) do
    class ::CarType
      include DataMapper::Mongo::EmbeddedResource
      property :name, String
    end

    class ::Car
      include DataMapper::Mongo::Resource
      property :model, String
    end

    class ::DMCar
      include DataMapper::Resource
      property :type, String
    end
  end

  #
  # descendants
  #

  describe '#descendants' do
    before(:all) do
      @descendants = DataMapper::Mongo::EmbeddedModel.descendants
    end

    it 'should include Mongo embedment models' do
      @descendants.should include(CarType)
    end

    it 'should not include Mongo models' do
      @descendants.should_not include(Car)
    end

    it 'should not include DataMapper models' do
      @descendants.should_not include(DMCar)
    end
  end
end
