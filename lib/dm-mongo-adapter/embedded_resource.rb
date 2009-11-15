# TODO: This is obiously not what we want, but current dm-core API doesn't support resources embedded in other resources.
module DataMapper
  module Mongo
    module EmbeddedResource
      include Types

      def self.included(base)
        base.send(:include, DataMapper::Resource)
      end
    end
  end
end
