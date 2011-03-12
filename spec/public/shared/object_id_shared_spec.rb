share_examples_for 'An ObjectId Type' do
  describe '#typecast' do
    it 'should return nil when given nil' do
      @property.typecast(nil).should be_nil
    end

    it 'should return BSON::ObjectId when given a valid string' do
      value = '4d7b57618f9f1f12bd000002'
      loaded = @property.typecast(value)
      loaded.should == ::BSON::ObjectId.from_string(value)
    end

    it 'should raise BSON::InvalidObjectId when give an invalid string' do
      lambda {
        @property.typecast('#invalid#')
      }.should raise_error(::BSON::InvalidObjectId)
    end

    it 'should return the argument when given a BSON::ObjectId' do
      mongo_id = ::BSON::ObjectId.new
      loaded = @property.typecast(mongo_id)
      loaded.should be(mongo_id)
    end

    it 'should raise an error when given anything else' do
      [ 0, 1, Object.new, true, false, [], {} ].each do |value|
        lambda {
          @property.typecast(value)
        }.should raise_error(ArgumentError)
      end
    end
  end
end
