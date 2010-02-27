require 'pathname'
require 'rubygems'
require 'spec'

# pull in local dm-core and dm-aggregates checkouts if present
local_dm_core_lib = File.expand_path(File.join(File.dirname(__FILE__), '..', '..', 'dm-core', 'lib'))
$LOAD_PATH.unshift(local_dm_core_lib) if File.directory?(local_dm_core_lib)

local_dm_aggregates_lib = File.expand_path(File.join(File.dirname(__FILE__), '..', '..', 'dm-more', 'dm-aggregates', 'lib'))
$LOAD_PATH.unshift(local_dm_aggregates_lib) if File.directory?(local_dm_aggregates_lib)

MONGO_SPEC_ROOT = Pathname(__FILE__).dirname.expand_path
$LOAD_PATH.unshift(MONGO_SPEC_ROOT.parent + 'lib')

require 'mongo_adapter'

Pathname.glob((MONGO_SPEC_ROOT + '{lib,*/shared}/**/*.rb').to_s).each { |file| require file }

# Define the repositories used by the specs. Override the defaults by
# supplying ENV['DEFAULT_SPEC_URI'] or ENV['AUTH_SPEC_URI'].

REPOS = {
  'default' => 'mongo://localhost/dm-mongo-test',
  'auth'    => 'mongo://dmm-auth:dmm-password@localhost/dm-mongo-test-auth'
}

REPOS.each do |name, default|
  connection_string = ENV["#{name.upcase}_SPEC_URI"] || default

  DataMapper.setup(name.to_sym, connection_string)
  REPOS[name] = connection_string  # ensure *_SPEC_URI is saved
end

REPOS.freeze

Spec::Runner.configure do |config|
  config.include(DataMapper::Mongo::Spec::CleanupModels)

  config.before(:all) do
    models  = DataMapper::Model.descendants.to_a
    models += DataMapper::Mongo::EmbeddedModel.descendants.to_a
    models.delete(DataMapper::Mongo::EmbeddedResource)

    cleanup_models(*models)
  end

  config.after(:suite) do
    # Close all the raw connections
    DataMapper::Mongo::Spec.database(:default).connection.close
    DataMapper::Mongo::Spec.database(:auth).connection.close
  end
end
