require File.expand_path(File.join(File.dirname(__FILE__), '..', 'spec_helper'))

describe DataMapper::Mongo::Model do
  before(:all) do
    class ::Student
      include DataMapper::Mongo::Resource

      property  :id,     ObjectId
      property  :name,   String
      property  :school, String
      property  :score,  Float
    end

    Student.all.destroy!

    @student_one   = Student.create(:school => 'School 1', :name => 'One',   :score => 3.0)
    @student_two   = Student.create(:school => 'School 2', :name => 'Two',   :score => 3.5)
    @student_three = Student.create(:school => 'School 2', :name => 'Three', :score => 4.5)
  end

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

  describe "#aggregate" do
    describe "without operators" do
      describe "without conditions" do
        it "should return array of hashes based on all records" do
          result = Student.aggregate(:school, :score).to_a

          result.should == [
            { :school => "School 1", :score => 3.0 },
            { :school => "School 2", :score => 3.5 },
            { :school => "School 2", :score => 4.5 }]
        end
      end

      describe "with conditions" do
        it "should return array of hashes based on records that match conditions" do
          result = Student.aggregate(:school, :score, :score.gt => 3.0)

          result.should == [
            { :school => "School 2", :score => 3.5 },
            { :school => "School 2", :score => 4.5 }]
        end
      end
    end

    describe "count operator" do
      describe "without conditions" do
        it "should get correct results based on all records" do
          result = Student.aggregate(:school, :score.count)

          result.size.should == 2

          school_1, school_2 = result

          school_1[:school].should == 'School 1'
          school_2[:school].should == 'School 2'

          school_1[:score].should == 1
          school_2[:score].should == 2
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
