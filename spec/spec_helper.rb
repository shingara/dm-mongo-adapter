$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))

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
  
    if Object.const_defined?(model)
      Object.send(:remove_const, model)
    end

    cleanup_models(*models)
  end
end

Spec::Runner.configure do |config|
  config.before(:all) do

  end
end
