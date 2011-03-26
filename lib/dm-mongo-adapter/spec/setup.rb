require 'dm-mongo-adapter'
require 'dm-core/spec/setup'

module DataMapper
  module Spec
    module Adapters

      class MongoAdapter < Adapter
      end

      use MongoAdapter

    end
  end
end
