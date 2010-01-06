require File.join(File.dirname(__FILE__), 'spec_helper')

describe "Single Table Inheritance" do
  before(:all) do
    cleanup_models :Person, :Male, :Father, :Son
    $db.drop_collection('people')

    class Person
      include DataMapper::Mongo::Resource
      
      property :id, ObjectID
      property :name, String
      property :job, String
      property :type, Discriminator
    end

    class Male < Person; end
    class Father < Male; end
    class Son < Male; end
  end

  it "should have a type property that reflects the class" do
    [Person, Male, Father, Son].each do |model|
      object = model.create
      object.reload
      object.type.should == model
    end
  end

  it "should parent should return an instance of the child when type is explicitly specified" do
    male = Person.new(:type => "Male")
    male.should be_instance_of(Male)
    male.save
    male.reload
    male.should be_instance_of(Male)
  end

  it "should discriminate types during reads" do
    person = Person.all(:type => Person)
    p person
    Son.create
    father1 = Father.create
    father2 = Father.create
    fathers = Father.all(:type => "Father")
    fathers.should == [father1, father2]
    fathers.each do |father|
      father.should be_instance_of(Father)
    end
  end
  
end
