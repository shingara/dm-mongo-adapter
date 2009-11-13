module DataMapper
  module Mongo
    module Types
      class DBRef < DataMapper::Type
        primitive ::Object

        def self.load(value, property)
          typecast(value, property)
        end

        def self.dump(value, property)
          typecast(value, property)
        end

        def self.typecast(value, property)
          case value
          when NilClass
            nil
          when String
            ::Mongo::DBRef.new(property.model.storage_name, ::Mongo::ObjectID.from_string(value))
          when ::Mongo::ObjectID
            ::Mongo::DBRef.new(property.model.storage_name, value)
          when ::Mongo::DBRef
            value
          else
            raise ArgumentError.new('+value+ must be nil, String, ObjectID or DBRef')
          end
        end
      end # DBRef
    end # Types
  end # Mongo
end # DataMapper
