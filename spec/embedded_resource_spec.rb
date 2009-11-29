require File.join(File.dirname(__FILE__), 'spec_helper')

describe DataMapper::Mongo::EmbeddedModel do
  DataMapper.setup(:default,
    :adapter  => 'mongo',
    :hostname => 'localhost',
    :database => 'dm-mongo-test'
  )

  class User
    include DataMapper::Mongo::EmbeddedResource

    property :name, String
    property :age,  Integer
  end

  describe "#new" do
    it "should not need a key" do
      lambda {
        User.new
      }.should_not raise_error
    end
  end
end
