$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))

require 'rubygems'
require 'spec'
require 'mongo_adapter'

$adapter = DataMapper.setup(:default,
                            :adapter  => 'mongo',
                            :hostname => 'localhost',
                            :database => 'dm-mongo-test'
                            )

$db = Mongo::Connection.new.db('dm-mongo-test')

include DataMapper::Mongo

def cleanup_models(*models)
  unless models.empty?
    model = models.pop
    sym   = model.to_s.to_sym

    if Object.const_defined?(sym)
      $db.drop_collection(model.storage_name) if model.respond_to?(:storage_name)

      DataMapper::Model.descendants.delete(model)
      DataMapper::Mongo::EmbeddedModel.descendants.delete(model)

      Object.send(:remove_const, sym)
    end

    cleanup_models(*models)
  end
end

Spec::Runner.configure do |config|
  config.before(:all) do
    models = (DataMapper::Model.descendants.to_a + DataMapper::Mongo::EmbeddedModel.descendants.to_a)
    models.delete(DataMapper::Mongo::EmbeddedResource)
    cleanup_models(*models)
  end
end
