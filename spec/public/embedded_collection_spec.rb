require File.expand_path(File.join(File.dirname(__FILE__), '..', 'spec_helper'))

describe DataMapper::Mongo::EmbeddedResource do
  before :all do
    class ::Student
      include DataMapper::Mongo::Resource
      property :id,   ObjectID
      property :name, String

      embeds n, :scores
    end

    class ::Score
      include DataMapper::Mongo::EmbeddedResource
      property :value,  Float
      property :course, String
    end

    Student.all.destroy!

    @student = Student.new
  end

  describe "#new" do
    it "should create a new instance and add it to the collection" do
      score = @student.scores.new
      score.should be_kind_of(Score)
      score.parent.should be(@student)
    end

    it "should set a new instance with attributes" do
      attrs = { :value => 5.0, :course => 'MongoDB' }
      score = @student.scores.new(attrs)
      score.attributes.should == attrs
    end
  end

  describe "#dirty?" do
    it "should return true when includes dirty resources" do
      @student.scores << Score.new(:value => 6.0)
      @student.scores.dirty?.should be(true)
    end

    it "should return false when it doesn't include dirty resources" do
      @student.scores << Score.new
      @student.scores.dirty?.should be(true)
    end
  end

  describe "#save" do
    it "should call save on parent" do
      expected = Score.new(:value => 7.0)

      pending do
        @student.scores << expected
        @student.scores.save.should be(true)
        @student.clean?.should be(true)

        @student.reload.scores.should == [expected]
      end
    end
  end
end