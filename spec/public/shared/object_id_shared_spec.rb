share_examples_for 'An ObjectID Type' do

  describe '.load' do
    it 'should return nil when given nil' do
      @type_class.load(nil, nil).should be_nil
    end

    it 'should return the argument when given a string' do
      loaded = @type_class.load('avalue', nil)
      loaded.should == 'avalue'
    end

    it 'should return a string when given a BSON::ObjectID' do
      mongo_id = ::BSON::ObjectID.new
      loaded = @type_class.load(mongo_id, nil)
      loaded.should be_kind_of(String)
      loaded.should == mongo_id.to_s
    end

    it 'should raise an error when given anything else' do
      [ 0, 1, Object.new, true, false, [], {} ].each do |value|
        lambda {
          @type_class.load(value, nil)
        }.should raise_error(ArgumentError)
      end
    end
  end

  describe '.dump' do
    it 'should return nil when given nil' do
      @type_class.dump(nil, nil).should be_nil
    end

    it 'should return a BSON::ObjectID when given a string' do
      mongo_id = ::BSON::ObjectID.new
      dumped = @type_class.dump(mongo_id.to_s, nil)
      dumped.should be_kind_of(::BSON::ObjectID)
      dumped.to_s.should == mongo_id.to_s
    end

    it 'should return the argument when given a BSON::ObjectID' do
      mongo_id = ::BSON::ObjectID.new
      dumped = @type_class.dump(mongo_id, nil)
      dumped.should == mongo_id
    end

    it 'should raise an error when given anything else' do
      [ 0, 1, Object.new, true, false, [], {} ].each do |value|
        lambda {
          @type_class.dump(value, nil)
        }.should raise_error(ArgumentError)
      end
    end
  end

end
