require File.expand_path(File.join(File.dirname(__FILE__), '..', '..', 'spec_helper'))

describe DataMapper::Mongo::Embedments do
  before(:all) do
    class ::Car
      include DataMapper::Mongo::Resource
      property :id, ObjectID
      property :name, String
    end

    class ::Engine
      include DataMapper::Mongo::EmbeddedResource
      property :name, String
    end

    class ::Door
      include DataMapper::Mongo::EmbeddedResource
      property :name, String
    end
  end

  def n
    Car.n
  end

  it { Car.should respond_to(:embeds) }
  it { Car.should respond_to(:embedments) }

  describe '#embeds(1, ...)' do
    before(:all) do
      @model = Engine
      @name  = :engine

      Car.embeds(1, :engine)

      @car = Car.new(:name => 'Ford')
    end

    it_should_behave_like 'A singular embedment reader'
    it_should_behave_like 'A singular embedment writer'
  end

  describe '#embeds(1, :through ...)' do
    it 'should raise an ArgumentError' do
      pending ':through option not supported on embedments'
    end
  end

  describe '#embeds(n, ...)' do
    before(:all) do
      @model = Door
      @name = :doors

      Car.embeds(n, :doors)
      @car = Car.new(:name => 'Ford')
    end

    it_should_behave_like 'A many embedment reader'
    it_should_behave_like 'A many embedment writer'
  end

  describe '#embeds(n, :through ...)' do
    it 'should raise an ArgumentError' do
      pending ':through option not supported on embedments'
    end
  end

  describe '#embeds(1..4)' do
    before(:all) do
      @model = Door
      @name = :doors

      Car.embeds(1..4, :doors)
      @car = Car.new(:name => 'Ford')
    end

    it_should_behave_like 'A many embedment reader'
    it_should_behave_like 'A many embedment writer'
  end

  describe '#embeds' do
    describe 'when the third argument is a model' do
      it 'should set the relationship target model' do
        Car.embeds(1, :engine, Engine)
        Car.embedments[:engine].target_model.should == Engine
      end
    end

    describe 'when the third argument is a string' do
      it 'should set the relationship target model' do
        Car.embeds(1, :engine, 'Engine')
        pending { Car.embedments[:engine].target_model.should == Engine }
      end
    end

    describe 'when a :model option is given' do
      it 'should set the relationship target model when given a string' do
        Car.embeds(1, :engine, :model => 'Engine')
        pending { Car.embedments[:engine].target_model.should == Engine }
      end

      it 'should set the relationship target model when given a model' do
        Car.embeds(1, :engine, :model => Engine)
        Car.embedments[:engine].target_model.should == Engine
      end
    end

    it 'should raise an exception if the cardinality is not understood' do
      lambda { Car.embeds(n..n, :doors) }.should raise_error(ArgumentError)
    end

    it 'should raise an exception if the minimum constraint is larger than the maximum' do
      lambda { Car.embeds(2..1, :doors) }.should raise_error(ArgumentError)
    end
  end

end
