require File.join(File.dirname(__FILE__), 'spec_helper')

describe "Single Table Inheritance" do
  before(:all) do
    $db.drop_collection('people')

    class ::Person
      include DataMapper::Mongo::Resource

      property :id, ObjectID
      property :name, String
      property :job, String
      property :type, Discriminator
    end

    class ::Male < Person; end
    class ::Father < Male; end
    class ::Son < Male; end
  end

  it "should have a type property that reflects the class" do
    [Person, Male, Father, Son].each do |model|
      object = model.create
      object.reload
      object.type.should == model
    end
  end

  it "should parent should return an instance of the child when type is explicitly specified" do
    [Person, Male, Father, Son].each do |model|
      object = model.create
      object.reload
      object.should be_instance_of(model)
    end
  end

  it "should discriminate types during reads" do
    $db.drop_collection('people')

    father1 = Father.create
    father2 = Father.create
    son1 = Son.create
    son2 = Son.create

    fathers = Father.all
    fathers.should == [father1, father2]
    fathers.each do |father|
      father.should be_instance_of(Father)
    end

    sons = Son.all
    sons.should == [son1, son2]
  end

end
