require File.expand_path(File.join(File.dirname(__FILE__), '..', '..', 'spec_helper'))

describe DataMapper::Mongo::Model::Embedment do

  before(:all) do
    class Address
      include DataMapper::Mongo::EmbeddedResource
      property :street, String
      property :city,   String, :field => 'conurbation'
    end

    class User
      include DataMapper::Mongo::Resource
      property :id, ObjectID
      embeds 1, :address
      embeds n, :locations, Address
    end
  end

  describe '#embedments' do
    before(:all) do
      @embedments = User.embedments
    end

    it 'should return a hash' do
      @embedments.should be_kind_of(Hash)
    end

    it 'should include OneToOne embedments' do
      @embedments.should have_key(:address)
      @embedments[:address].should \
        be_kind_of(DataMapper::Mongo::Embedments::OneToOne::Relationship)
    end

    it 'should include OneToMany embedments' do
      @embedments.should have_key(:locations)
      @embedments[:locations].should \
        be_kind_of(DataMapper::Mongo::Embedments::OneToMany::Relationship)
    end
  end

end