require File.expand_path(File.join(File.dirname(__FILE__), 'spec_helper'))

describe "Property" do
  before :all do
    ENV['TZ'] = 'UTC'

    class ::User
      include DataMapper::Mongo::Resource

      property :id, ObjectID
      property :date_time_field, DateTime
      property :date_field, Date
      property :type, Discriminator
    end
  end

  describe "Class" do
    it "should be typecasted to a string" do
      lambda{
        user = User.create!(:type => User)
      }.should_not raise_error
    end
  end

  describe "DateTime" do
    it "should be typecasted from a Time object" do
      dt_now = DateTime.now
      t_now  = Time.now

      _id = $db.collection('users').insert(:type => 'User', :date_time_field => t_now)

      user = User.get(_id)

      user.date_time_field.class.should be(DateTime)

      Time.parse(user.date_time_field.to_s).to_i.should == Time.parse(dt_now.to_s).to_i
    end
  end

  describe "Date" do
    it "should be typecasted from a Time object" do
      today = Date.today

      _id = $db.collection('users').insert(:type => 'User', :date_field => Time.parse(today.to_s))

      user = User.get(_id)

      user.date_field.class.should be(Date)
      Time.parse(user.date_field.to_s).should == Time.parse(today.to_s)
    end
  end
end
