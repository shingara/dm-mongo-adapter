require File.expand_path(File.join(File.dirname(__FILE__), '..', 'spec_helper'))

describe DataMapper::Mongo::Adapter do

  describe "#connection" do
    let(:adapter) { DataMapper::Mongo::Adapter.new(REPOS['default']) }
    subject { adapter.send(:connection) }
    it { should be_a ::Mongo::Connection }
    its(:host_to_try) { should == ['localhost', 27017] }
    its(:logger) { should == DataMapper.logger }
  end
end
