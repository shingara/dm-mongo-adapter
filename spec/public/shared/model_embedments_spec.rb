# The share specs contained herein are very slightly modified versions of
# those found in dm-core/spec/public/model/relationship_spec.rb

share_examples_for 'A singular embedment reader' do
  it { @car.should respond_to(@name) }

  describe 'reader' do
    describe 'when there is no associated resource' do
      it 'should return nil when there is no query' do
        pending 'OneToOne should not create new resource if none is set; ' \
                'not dm-core convention, breaks setting to nil' do
          @car.__send__(@name).should be_nil
        end
      end

      it 'should return nil when there is a query' do
        pending 'OneToOne should not create new resource if none is set; ' \
                'not dm-core convention, breaks setting to nil' do
          @car.__send__(@name, :name => '__nothing__').should be_nil
        end
      end
    end # when there is no associated resource

    describe 'when there is an associated resource' do
      before(:all) do
        @expected = @model.new
        @car.__send__("#{@name}=", @expected)
      end

      describe 'without a query' do
        it 'should return an EmbeddedResource' do
          returned = @car.__send__(@name)
          returned.should be_kind_of(DataMapper::Mongo::EmbeddedResource)
        end

        it 'should return the correct EmbeddedResource' do
          @car.__send__(@name).should == @expected
        end
      end

      describe 'with a query' do
        it 'should return a EmbeddedResource' do
          returned = @car.__send__(@name, :name => @expected.name)
          returned.should be_kind_of(DataMapper::Mongo::EmbeddedResource)
        end

        it 'should return the correct EmbeddedResource' do
          @car.__send__(@name, :name => @expected.name).should == @expected
        end
      end
    end # when there is an associated resource

  end # reader
end # A singular embedment reader

share_examples_for 'A singular embedment writer' do
  it { @car.should respond_to("#{@name}=") }

  describe 'writer' do
    describe 'when setting the wrong kind of target' do
      it 'should raise an ArgumentError' do
        calling = lambda { @car.__send__("#{@name}=", Object.new) }
        calling.should raise_error(ArgumentError)
      end
    end

    describe 'when setting an EmbeddedResource' do
      before(:all) do
        @expected = @model.new
        @return = @car.__send__("#{@name}=", @expected)
      end

      it 'should return the expected EmbeddedResource' do
        @return.should equal(@expected)
      end

      it 'should set the EmbeddedResource' do
        @car.__send__(@name).should equal(@expected)
      end

      it 'should relate the associated EmbeddedResource' do
        @expected.parent.should == @car
      end

      it 'should persist the Resource' do
        @car.save.should be_true
        @car.model.get(*@car.key).__send__(@name).should == @expected
      end
    end # when setting an EmbeddedResource

    describe 'when setting a Hash' do
      before(:all) do
        @expected = @model.new(:name => 'Name')
        @return = @car.__send__("#{@name}=", { :name => 'Name' })
      end

      it 'should return the expected EmbeddedResource' do
        @return.should == @expected
      end

      it 'should set the EmbeddedResource' do
        @car.__send__(@name).should equal(@return)
      end

      it 'should relate the associated EmbeddedResource' do
        @car.__send__(@name).parent.should == @car
      end

      it 'should persist the Resource' do
        @car.save.should be_true
        @car.model.get(*@car.key).__send__(@name).should == @expected
      end
    end # when setting a Hash

    describe 'when setting nil' do
      before(:all) do
        @car.__send__("#{@name}=", @model.new)
        @return = @car.__send__("#{@name}=", nil)
      end

      it 'should return nil' do
        @return.should be_nil
      end

      it 'should set nil' do
        pending 'OneToOne should not create new resource if none is set; ' \
                'not dm-core convention, breaks setting to nil' do
          @car.__send__(@name).should be_nil
        end
      end

      it 'should persist as nil' do
        pending 'OneToOne should not create new resource if none is set; ' \
                'not dm-core convention, breaks setting to nil' do
          @car.save.should be_true
          @car.model.get(*@car.key).__send__(@name).should be_nil
        end
      end
    end # when setting nil

    describe 'when changing the EmbeddedResource' do
      before(:all) do
        @car.__send__("#{@name}=", @model.new)
        @return = @car.__send__("#{@name}=", @expected = @model.new)
      end

      it 'should return the expected EmbeddedResource' do
        @return.should equal(@expected)
      end

      it 'should set the EmbeddedResource' do
        @car.__send__(@name).should equal(@return)
      end

      it 'should relate the associated EmbeddedResource' do
        @car.__send__(@name).parent.should == @car
      end

      it 'should persist the Resource' do
        @car.save.should be_true
        @car.model.get(*@car.key).__send__(@name).should == @expected
      end
    end # when changing the EmbeddedResource

  end # writer
end # A singular embedment writer

share_examples_for 'A many embedment reader' do
  it { @car.should respond_to(@name) }

  describe 'reader' do
    describe 'when there are no child resources and the source is saved' do
      before(:all) do
        @car.save.should be_true
        @return = @car.__send__(@name)
      end

      it 'should return a Collection' do
        @return.should be_kind_of(
          DataMapper::Mongo::Embedments::OneToMany::Collection)
      end

      it 'should return an empty Collection' do
        @return.should be_empty
      end
    end # when there is no child resource and the source is saved

    describe 'when there are no child resources and the source is not saved' do
      before(:all) do
        @return = @car.__send__(@name)
      end

      it 'should return a Collection' do
        @return.should be_kind_of(
          DataMapper::Mongo::Embedments::OneToMany::Collection)
      end

      it 'should return an empty Collection' do
        @return.should be_empty
      end
    end # when there is no child resource and the source is not save

    describe 'when there is a child resource' do
      before(:all) do
        @expected = @model.new
        @car.__send__("#{@name}=", [ @expected ])
        @return = @car.__send__(@name)
      end

      it 'should return a Collection' do
        @return.should be_kind_of(
          DataMapper::Mongo::Embedments::OneToMany::Collection)
      end

      it 'should return the expected resources' do
        @return.should == [ @expected ]
      end
    end # when there is a child resource

  end # reader
end # A many embedment reader

share_examples_for 'A many embedment writer' do
  it { @car.should respond_to("#{@name}=") }

  describe 'writer' do
    describe 'when setting an Array of the wrong kind of target' do
      it 'should raise an ArgumentError' do
        calling = lambda { @car.__send__("#{@name}=", [Object.new]) }
        calling.should raise_error(ArgumentError)
      end
    end # when setting an Array of the wrong kind of target

    describe 'when setting an Array of EmbeddedResources' do
      before(:all) do
        @expected = [ @model.new ]
        @return = @car.__send__("#{@name}=", @expected)
      end

      it 'should return the expected Collection' do
        @return.should == @expected
      end

      it 'should set the Collection' do
        @car.__send__(@name).should == @expected
        @car.__send__(@name).zip(@expected) do |value, expected|
          value.should equal(expected)
        end
      end

      it 'should relate the associated Collection' do
        @expected.each { |resource| resource.parent.should == @car }
      end

      it 'should persist the Collection' do
        @car.save.should be_true
        @car.model.get(*@car.key).__send__(@name).should == @expected
      end

      it 'should persist the associated EmbeddedResources' do
        @car.save.should be_true
        @expected.each { |resource| resource.should be_saved }
      end
    end # when setting an Array of EmbeddedResources

    describe 'when setting an Array of Hashes' do
      before(:all) do
        @expected = [ @model.new(:name => 'Name') ]
        @return = @car.__send__("#{@name}=", [{ :name => 'Name' }])
      end

      it 'should return the expected Collection' do
        @return.should == @expected
      end

      it 'should set the Collection' do
        @car.__send__(@name).should == @expected
        @car.__send__(@name).zip(@expected) do |value, expected|
          value.should == expected
        end
      end

      it 'should relate the associated Collection' do
        @return.each { |resource| resource.parent.should == @car }
      end

      it 'should persist the Collection' do
        @car.save.should be_true
        @car.model.get(*@car.key).__send__(@name).should == @expected
      end

      it 'should persist the associated EmbeddedResources' do
        @car.save.should be_true
        @return.each { |resource| resource.should be_saved }
      end
    end # when setting an Array of Hashes

    describe 'when setting an empty collection' do
      before :all do
        @car.__send__("#{@name}=", [ @model.new ])
        @return = @car.__send__("#{@name}=", [])
      end

      it 'should return a Collection' do
        @return.should be_kind_of(
          DataMapper::Mongo::Embedments::OneToMany::Collection)
      end

      it 'should set a empty Collection' do
        @car.__send__(@name).should be_empty
      end

      it 'should persist as an empty collection' do
        @car.save.should be_true
        @car.model.get(*@car.key).__send__(@name).should be_empty
      end
    end # when setting an empty collection

    describe 'when changing an associated collection' do
      before(:all) do
        @car.__send__("#{@name}=", [ @model.new ])
        @expected = [ @model.new ]
        @return = @car.__send__("#{@name}=", @expected)
      end

      it 'should return the expected Resource' do
        @return.should == @expected
      end

      it 'should set the Resource' do
        @car.__send__(@name).should == @expected
      end

      it 'should relate the associated Resource' do
        @expected.each { |resource| resource.parent.should == @car }
      end

      it 'should persist the Resource' do
        @car.save.should be_true
        @car.model.get(*@car.key).__send__(@name).should == @expected
      end

      it 'should persist the associated Resource' do
        @car.save.should be_true
        @expected.each { |resource| resource.should be_saved }
      end
    end # when setting an associated collection

  end #writer
end # A many embedment writer
