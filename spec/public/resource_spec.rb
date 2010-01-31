require File.expand_path(File.join(File.dirname(__FILE__), '..', 'spec_helper'))

describe DataMapper::Mongo::Resource do

  before(:all) do
    class ::Address
      include DataMapper::Mongo::EmbeddedResource
      property :city, String
    end

    class ::Location
      include DataMapper::Mongo::EmbeddedResource
      property :country, String
    end

    class ::User
      include DataMapper::Mongo::Resource
      property  :id,        ObjectID
      property  :name,      String
      property  :tags,      Array
      property  :metadata,  Hash
      property  :created_at, DateTime
      embeds 1, :address,   :model => Address
      embeds n, :locations
    end
  end

  #
  # all
  #

  describe '#all' do
    describe 'with no query' do
      it 'should return a collection' do
        User.all.should be_kind_of(DataMapper::Collection)
      end

      it 'should return an empty collection when there are no resources' do
        User.all.destroy!
        User.all.should be_empty
      end

      it 'should return all resources' do
        expected = [User.create(:name => 'One'), User.create(:name => 'Two')]
        User.all.should == expected
      end

      it 'should fail if incorrect conditions are given' do
        lambda {
          User.all :'adres.blah' => 'New York'
        }.should raise_error
      end
    end

    describe 'with a query' do
      it 'should return a collection' do
        User.all.should be_kind_of(DataMapper::Collection)
      end

      it 'should return an empty collection when there are no matching resources' do
        User.all.destroy!
        User.create(:name => 'One')
        User.all(:name => 'Two').should be_empty
      end

      it 'should return the specific resources' do
        User.create(:name => 'One')
        expected = User.create(:name => 'Two')
        User.all(:name => 'Two').should == [expected]
      end

      describe 'including conditions for an embedded has 1 resource' do
        before(:all) do
          User.all.destroy!
          User.create(:name => 'Boston guy', :address => { :city => 'Boston' })
          @expected = User.create(:name => 'NY guy', :address => { :city => 'New York' })
        end

        it 'should return a collection' do
          collection = User.all('address.city' => 'Washington')
          collection.should be_kind_of(DataMapper::Collection)
        end

        it 'should return an empty collection when there are no matching resources' do
          collection = User.all('address.city' => 'Washington')
          collection.should be_empty
        end

        it 'should return specific resources' do
          User.all('address.city' => 'New York').should == [@expected]
        end
      end # including conditions for an embedded has 1 resource

      describe 'including conditions for an embedded has n resource' do
        before(:all) do
          User.all.destroy!
          User.create(:name => 'Boston guy', :locations => [{ :country => 'Boston' }])
          @expected = User.create(:name => 'NY guy', :locations => [{ :country => 'New York' }])
        end

        it 'should return a collection' do
          collection = User.all('locations.country' => 'Washington')
          collection.should be_kind_of(DataMapper::Collection)
        end

        it 'should return an empty collection when there are no matching resources' do
          collection = User.all('locations.country' => 'Washington')
          collection.should be_empty
        end

        it 'should return specific resources' do
          User.all('locations.country' => 'New York').should == [@expected]
        end
      end # including conditions for an embedded has n resource

    end
  end

  #
  # first
  #

  describe '#first' do
    before(:all) do
      User.all.destroy!
      @user_one = User.create(:name => 'Three')
      @user_two = User.create(:name => 'Four')
    end

    describe 'with no query' do
      it 'should return a resource' do
        User.first.should be_kind_of(DataMapper::Mongo::Resource)
      end

      it 'should return the first resource' do
        User.first.should == @user_one
      end
    end

    describe 'when a query' do
      it 'should return a resource' do
        User.first(:name => @user_two.name).should \
          be_kind_of(DataMapper::Mongo::Resource)
      end

      it 'should return the first resource' do
        User.first(:name => @user_two.name).should == @user_two
      end
    end
  end

  #
  # aggregations
  #
  describe 'aggregations' do
    before(:all) do
      class ::Student
        include DataMapper::Mongo::Resource

        property  :id,     ObjectID
        property  :name,   String
        property  :school, String
        property  :score,  Float
      end

      Student.all.destroy!

      @student_one   = Student.create(:school => 'School 1', :name => 'One',   :score => 3.0)
      @student_two   = Student.create(:school => 'School 2', :name => 'Two',   :score => 3.5)
      @student_three = Student.create(:school => 'School 2', :name => 'Three', :score => 4.5)
    end

    #
    # count
    #
    describe "#count" do
      describe 'with no query' do
        it 'should return number of all resources' do
          Student.count.should == 3
        end
      end

      describe 'with a query' do
        it 'should return number of resources matching conditions' do
          Student.count(:name => /one|two/i).should == 2
        end
      end
    end

    #
    # aggregate
    #

    describe "#aggregate" do

      #
      # simple aggregation without any operators
      #

      describe "without operators" do
        describe "without conditions" do
          it "should return array of hashes based on all records" do
            result = Student.aggregate(:school, :score)

            result.should == [
              {:school => "School 1", :score => 3.0},
              {:school => "School 2", :score => 3.5},
              {:school => "School 2", :score => 4.5}]
          end
        end

        describe "with conditions" do
          it "should return array of hashes based on records that match conditions" do
            result = Student.aggregate(:school, :score, :score.gt => 3.0)

            result.should == [
              {:school => "School 2", :score => 3.5},
              {:school => "School 2", :score => 4.5}]
          end
        end
      end

      #
      # count
      #

      describe "count operator" do
        describe "without conditions" do
          it "should get correct results based on all records" do
            result = Student.aggregate(:school, :score.count)

            result.size.should == 2

            school_1, school_2 = result

            school_1[:school].should == 'School 1'
            school_2[:school].should == 'School 2'

            school_1[:score].should == 1
            school_2[:score].should   == 2
          end
        end

        describe "with conditions" do
          it "should get correct results based on records that match conditions" do
            result = Student.aggregate(:school, :score.count, :name => /two|three/i)

            result.size.should == 1
            result.first[:score].should == 2
            result.first[:school].should == 'School 2'
          end
        end
      end

      #
      # avg
      #
      # TODO: add spec for #avg with conditions

      describe "avg operator" do
        describe 'without conditions' do
          it 'should return an avarage value of the given field' do
            result = Student.aggregate(:school, :score.avg)

            school_1, school_2 = result

            school_1[:school].should == 'School 1'
            school_2[:school].should == 'School 2'

            school_1[:score].should == 3.0
            school_2[:score].should == 4.0
          end
        end
      end

      #
      # min
      #
      # TODO: add spec for #min with conditions

      describe "min operator" do
        describe 'without conditions' do
          it 'should return the minimum value of the given field' do
            result = Student.aggregate(:school, :score.min)

            school_1, school_2 = result

            school_1[:school].should == 'School 1'
            school_2[:school].should == 'School 2'

            school_1[:score].should == 3.0
            school_2[:score].should == 3.5
          end
        end
      end

      #
      # max
      #
      # TODO: add spec for #max with conditions

      describe "max operator" do
        describe 'without conditions' do
          it 'should return the maximum value of the given field' do
            result = Student.aggregate(:school, :score.max)

            school_1, school_2 = result

            school_1[:school].should == 'School 1'
            school_2[:school].should == 'School 2'

            school_1[:score].should == 3.0
            school_2[:score].should == 4.5
          end
        end
      end

       #
      # max
      #
      # TODO: add spec for #sum with conditions

      describe "sum operator" do
        describe 'without conditions' do
          it 'should return the maximum value of the given field' do
            result = Student.aggregate(:school, :score.sum)

            school_1, school_2 = result

            school_1[:school].should == 'School 1'
            school_2[:school].should == 'School 2'

            school_1[:score].should == 3.0
            school_2[:score].should == 8.0
          end
        end
      end
    end
  end

  #
  # dirty?
  #

  describe '#dirty?' do
    describe 'when the resource has a change' do
      it 'should return true' do
        User.new(:name => 'Mongo').should be_dirty
      end
    end

    describe 'when the resource has no changes' do
      it 'should return true if a one-to-one embedment has a change' do
        user = User.new(:address => Address.new(:city => 'Rock Ridge'))
        user.should be_dirty
      end

      it 'should return false having just been saved' do
        user = User.new(:address => Address.new(:city => 'Rock Ridge'))
        user.save
        user.should_not be_dirty
      end

      it 'should return true if a one-to-many embedment has a change' do
        user = User.new
        user.locations << Address.new(:city => 'Rock Ridge')
        user.should be_dirty
      end

      it 'should return false if no embedments have changes' do
        user = User.new(:address => Address.new(:city => 'Rock Ridge'))
        user.locations << Address.new(:city => 'Rock Ridge')
        user.save
        user.should_not be_dirty
      end
    end
  end

  #
  # Array properties
  #

  describe 'Array properties' do
    it 'should permit nil' do
      user = User.new(:tags => nil)
      user.tags.should be_nil
    end

    it 'should persist nil' do
      user = User.create(:tags => nil)
      User.get(user.id).tags.should be_nil
    end

    it 'should permit an Array' do
      user = User.new(:tags => ['loud', 'troll'])
      user.tags.should == ['loud', 'troll']
    end

    it 'should persist an Array' do
      user = User.create(:tags => ['loud', 'troll'])
      User.get(user.id).tags.should ==['loud', 'troll']
    end

    it 'should persist nested properties in an Array' do
      user = User.create(:tags => ['troll', ['system', 'banned']])
      User.get(user.id).tags.should == ['troll', ['system', 'banned']]
    end
  end

  #
  # Hash properties
  #

  describe 'Hash properties' do
    it 'should permit nil' do
      user = User.new(:metadata => nil)
      user.metadata.should be_nil
    end

    it 'should persist nil' do
      user = User.create(:metadata => nil)
      User.get(user.id).metadata.should be_nil
    end

    it 'should permit a Hash' do
      user = User.new(:metadata => { :one => 'two' })
      user.metadata.should == { :one => 'two' }
    end

    it 'should persist a Hash' do
      user = User.create(:metadata => { :one => 'two' })
      User.get(user.id).metadata.should == { :one => 'two' }
    end

    it 'should permit Hash-like Arrays' do
      user = User.new(:metadata => [:one, 'two'])
      user.metadata.should == { :one => 'two' }
    end

    it 'should persist Hash-like Arrays' do
      user = User.create(:metadata => [:one, 'two'])
      User.get(user.id).metadata.should == { :one => 'two' }
    end

    it 'should persist nested properties in an Array' do
      user = User.create(:metadata => { :one => { :two => :three } })
      pending "EmbeddedHash doesn't typecast nested keys yet" do
        User.get(user.id).metadata.should == { :one => { :two => :three } }
      end
    end
  end

  describe "Modifier" do
    before :all do
      class ::Post
        include DataMapper::Mongo::Resource

        property :id, ObjectID
        property :comment_count, Integer
        property :body, Text
      end

      Post.all.destroy!
    end

    describe "#increment" do
      before :all do
        @post = Post.create(:comment_count => 1)
        @post.increment(:comment_count, 1)
      end

      it "should update the given property with the incremented value" do
        @post.comment_count.should == 2
        Post.get(@post.id).comment_count.should == 2
      end

      it "should reload the updated resource" do
        @post.dirty?.should be_false
      end
    end

    describe "#decrement" do
      before :all do
        @post = Post.create(:comment_count => 10)
        @post.decrement(:comment_count, 5)
      end

      it "should update the given property with the decremented value" do
        @post.comment_count.should == 5
        Post.get(@post.id).comment_count.should == 5
      end

      it "should reload the updated resource" do
        @post.dirty?.should be_false
      end
    end

    describe "#set" do
      it "should set the value of a property" do
        post = Post.create(:body => "This needs to be edited", :comment_count => 2)

        pending "not implemented yet" do
          post.set(:body => "This was edited", :comment_count => 3)
          post.body.should == "This was edited"
          post.comment_count.should == 3
          fresh_post = Post.get(post.id)
          fresh_post.body.should == "This was edited"
          fresh_post.comment_count.should == 3
        end
      end
    end

    describe "#unset" do
      it "should unset the value of a property" do
        post = Post.create(:body => "This needs to be removed", :comment_count => 2)

        pending "not implemented yet" do
          post.unset(:body, :comment_count)
          post.body.should be_nil
          post.comment_count.should be_nil
          fresh_post = Post.get(post.id)
          fresh_post.body.should be_nil
          fresh_post.comment_count.should be_nil
        end
      end
    end

    describe "#push" do
      it "should be implemented" do
        pending
      end
    end

    describe "#push_all" do
      it "should be implemented" do
        pending
      end
    end

    describe "#pop" do
      it "should be implemented" do
        pending
      end
    end

    describe "#pull" do
      it "should be implemented" do
        pending
      end
    end

    describe "#pull_all" do
      it "should be implemented" do
        pending
      end
    end
  end
end
