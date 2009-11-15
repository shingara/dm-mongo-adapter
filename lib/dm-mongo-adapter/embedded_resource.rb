# TODO: This is obiously not what we want, but current dm-core API doesn't support resources embedded in other resources.
module DataMapper
  module Mongo
    module EmbeddedResource
      include Types

      def self.included(base)
        base.send(:include, DataMapper::Resource)
      end

      def attributes_as_fields
        attributes = {}
        fields.each do |property|
          if model.public_method_defined?(name = property.name)
            value = __send__(name)
            attributes[property.field] = value
          end
        end
        attributes
      end
    end
  end
end
