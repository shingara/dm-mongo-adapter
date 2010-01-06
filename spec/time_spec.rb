require File.join(File.dirname(__FILE__), 'spec_helper')

describe "Single Table Inheritance" do
  before(:all) do
    cleanup_models :Appointment, :Male, :Father, :Son
    $db.drop_collection('appointments')

    class ::Appointment
      include DataMapper::Mongo::Resource
      
      property :id, ObjectID
      property :description, String
      property :starts_at, DateTime
      property :ends_at, Time
      property :next_appointment_on, Date
    end
  end

  it "should have a property that reflects its class" do
    Appointment.create(:starts_at => DateTime.now, :ends_at => Time.now, :next_appointment_on => Date.today)
    appointment = Appointment.first
    appointment.starts_at.to_s.should == DateTime.parse(Time.now.utc.to_s).to_s
    appointment.ends_at.to_s.should == Time.now.utc.to_s
    appointment.next_appointment_on.should == Date.today
  end
  
end
