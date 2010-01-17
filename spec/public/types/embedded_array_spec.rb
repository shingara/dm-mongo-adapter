require File.expand_path(File.join(File.dirname(__FILE__), '..', '..', 'spec_helper'))

describe DataMapper::Mongo::Types::EmbeddedArray do
  describe '.load' do
    it 'should return nil when given nil' do
      DataMapper::Mongo::Types::EmbeddedArray.load(nil, nil).should be_nil
    end

    it 'should return the argument when given an Array' do
      loaded = DataMapper::Mongo::Types::EmbeddedArray.load([1, 2], nil)
      loaded.should == [1, 2]
    end

    it 'should raise an error when given anything else' do
      pending "EmbeddedArray should not be able to load arbitrary objects" do
        [ 0, 1, Object.new, true, false, {} ].each do |value|
          lambda {
            DataMapper::Mongo::Types::EmbeddedArray.load(value, nil)
          }.should raise_error(ArgumentError)
        end
      end
    end
  end

  describe '.dump' do
    it 'should return nil when given nil' do
      DataMapper::Mongo::Types::EmbeddedArray.dump(nil, nil).should == nil
    end

    it 'should return the argument when given an Array' do
      dumped = DataMapper::Mongo::Types::EmbeddedArray.dump([1, 2], nil)
      dumped.should == [1, 2]
    end

    it 'should return an Array when given a Set' do
      pending do
        dumped = DataMapper::Mongo::Types::EmbeddedArray.dump(Set.new(1, 2), nil)
        dumped.should be_kind_of(Array)
        dumped.should == [1, 2]
      end
    end

    it 'should raise an error when given anything else' do
      pending "EmbeddedArray should not be able to dump objects which " \
              "can't later be loaded" do
        [ 0, 1, Object.new, true, false, {} ].each do |value|
          lambda {
            DataMapper::Mongo::Types::EmbeddedArray.dump(value, nil)
          }.should raise_error(ArgumentError)
        end
      end
    end
  end

end
