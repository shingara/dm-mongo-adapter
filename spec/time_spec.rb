require File.join(File.dirname(__FILE__), 'spec_helper')

describe "Time fields" do
  before(:all) do
    ENV['TZ'] = 'utc'

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

  it "should set correct values for time, date time and date fields" do
    starts_at = DateTime.now
    ends_at   = Time.now.utc
    next_appointment_on = Date.today

    Appointment.create(
      :starts_at => starts_at, :ends_at => ends_at, :next_appointment_on => next_appointment_on)

    appointment = Appointment.first

    appointment.starts_at.to_s.should == starts_at.to_s
    appointment.ends_at.to_s.should == ends_at.to_s
    appointment.next_appointment_on.to_s.should == next_appointment_on.to_s
  end

end
