require File.expand_path(File.join(File.dirname(__FILE__), '..', '..', 'spec_helper'))

describe DataMapper::Mongo::Embedments do
  # Removes the Engine constant, runs the block, then redefines the Engine
  # class.
  def without_engine_defined
    old_engine = ::Engine
    Object.send(:remove_const, :Engine) if defined?(::Engine)
    yield
    Object.send(:const_set, :Engine, old_engine)
  end

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
    describe 'when inferring the model from the name' do
      it 'should set the relationship target model' do
        Car.embeds(1, :engine)
        Car.embedments[:engine].target_model.should == Engine
      end

      it 'should set the relationship target model when it is not defined' do
        without_engine_defined do
          Car.embeds(1, :engine)
        end

        Car.embedments[:engine].target_model.should == Engine
      end
    end

    describe 'when the third argument is a model' do
      it 'should set the relationship target model' do
        Car.embeds(1, :engine, Engine)
        Car.embedments[:engine].target_model.should == Engine
      end
    end

    describe 'when the third argument is a string' do
      it 'should set the relationship target model' do
        without_engine_defined do
          Car.embeds(1, :engine, 'Engine')
        end

        Car.embedments[:engine].target_model.should == Engine
      end

      it 'should raise NameError when given an invalid string' do
        Car.embeds(1, :engine, 'DoesNotExist')
        running = lambda { Car.embedments[:engine].target_model }
        running.should raise_error(NameError)
      end
    end

    describe 'when a :model option is given' do
      it 'should set the relationship target model when given a string' do
        without_engine_defined do
          Car.embeds(1, :engine, :model => 'Engine')
        end

        Car.embedments[:engine].target_model.should == Engine
      end

      it 'should raise NameError when given an invalid string' do
        Car.embeds(1, :engine, :model => 'DoesNotExist')
        running = lambda { Car.embedments[:engine].target_model }
        running.should raise_error(NameError)
      end

      it 'should set the relationship target model when given a model' do
        Car.embeds(1, :engine, :model => Engine)
        Car.embedments[:engine].target_model.should == Engine
      end
    end

    describe 'when no model is given' do
      it 'should raise NameError' do
        Car.embeds(1, :does_not_exist)
        running = lambda { Car.embedments[:engine].target_model }
        running.should raise_error(NameError)
      end
    end

    it 'should raise an exception if a :through option is given' do
      running = lambda { Car.embeds(1, Engine, :through => :engines) }
      running.should raise_error(ArgumentError)
    end

    it 'should raise an exception if a :remote_name option is given' do
      running = lambda { Car.embeds(1, Engine, :remote_name => :engines) }
      running.should raise_error(ArgumentError)
    end

    it 'should raise an exception if a :via option is given' do
      running = lambda { Car.embeds(1, Engine, :via => :engines) }
      running.should raise_error(ArgumentError)
    end

    it 'should raise an exception if a :inverse option is given' do
      running = lambda { Car.embeds(1, Engine, :inverse => :parent) }
      running.should raise_error(ArgumentError)
    end

    it 'should raise an exception if a :parent_key option is given' do
      running = lambda { Car.embeds(1, Engine, :parent_key => :id) }
      running.should raise_error(ArgumentError)
    end

    it 'should raise an exception if the cardinality is not understood' do
      lambda { Car.embeds(n..n, :doors) }.should raise_error(ArgumentError)
    end

    it 'should raise an exception if the minimum constraint is larger than the maximum' do
      lambda { Car.embeds(2..1, :doors) }.should raise_error(ArgumentError)
    end
  end

end
