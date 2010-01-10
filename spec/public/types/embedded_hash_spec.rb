require File.expand_path(File.join(File.dirname(__FILE__), '..', '..', 'spec_helper'))

describe DataMapper::Mongo::Types::EmbeddedHash do
  EHash = DataMapper::Mongo::Types::EmbeddedHash

  describe '.load' do
    it 'should return nil when given nil' do
      EHash.load(nil, nil).should be_nil
    end

    it 'should return an empty Hash when given an empty Hash' do
      loaded = EHash.load({}, nil)
      loaded.should == {}
    end

    it 'should return a Hash with values when given a Hash with values' do
      loaded = EHash.load({ :hello => 'World' }, nil)
      loaded.should == { :hello => 'World' }
    end

    it 'should return a Hash with symbolized keys' do
      loaded = EHash.load({ 'hello' => 'World' }, nil)
      loaded.should == { :hello => 'World' }
    end

    it 'should return an empty Hash when given an Array with no values' do
      pending "Mash#symbolize_keys doesn't like this" do
        loaded = EHash.load([], nil)
        loaded.should == {}
      end
    end

    it 'should return an empty Hash with values when given an Array with values' do
      loaded = EHash.load([:hello, 'World'], nil)
      loaded.should == { :hello => 'World' }
    end

    it 'should raise an error when given anything else' do
      pending "EmbeddedHash should not be able to load arbitrary objects" do
        lambda { EHash.load(0, nil) }.should          raise_error(ArgumentError)
        lambda { EHash.load(1, nil) }.should          raise_error(ArgumentError)
        lambda { EHash.load(Object.new, nil) }.should raise_error(ArgumentError)
        lambda { EHash.load(true, nil) }.should       raise_error(ArgumentError)
        lambda { EHash.load(false, nil) }.should      raise_error(ArgumentError)
      end
    end
  end

  describe '.dump' do
    it 'should return nil when given nil' do
      EHash.dump(nil, nil).should be_nil
    end

    it 'should return an empty Hash when given an empty Hash' do
      EHash.dump({}, nil).should == {}
    end

    it 'should return a Hash with values when given a Hash with values' do
      EHash.dump({ :hello => 'World' }, nil).should == { :hello => 'World' }
    end

    it 'should return an empty Hash when given an empty Mash' do
      EHash.dump(Mash.new, nil).should == {}
    end

    it 'should return a Hash with values when given a Mash with values' do
      dumped = EHash.dump(Mash.new('hello' => 'World'), nil)
      dumped.should == { 'hello' => 'World' }
    end

    it 'should raise an error when given anything else' do
      pending "EmbeddedHash should not be able to dump objects which " \
              "can't later be loaded" do
        lambda { EHash.dump(0, nil) }.should          raise_error(ArgumentError)
        lambda { EHash.dump(1, nil) }.should          raise_error(ArgumentError)
        lambda { EHash.dump(Object.new, nil) }.should raise_error(ArgumentError)
        lambda { EHash.dump(true, nil) }.should       raise_error(ArgumentError)
        lambda { EHash.dump(false, nil) }.should      raise_error(ArgumentError)
        lambda { EHash.dump([], nil) }.should         raise_error(ArgumentError)
      end
    end

  end

end
