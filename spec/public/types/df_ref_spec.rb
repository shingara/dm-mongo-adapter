require File.expand_path(File.join(File.dirname(__FILE__), '..', '..', 'spec_helper'))

describe DataMapper::Mongo::Types::DBRef do
  before(:all) { @type_class = DataMapper::Mongo::Types::DBRef }
  it_should_behave_like 'An ObjectID Type'
end
