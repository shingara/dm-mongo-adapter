module DataMapper
  module Mongo
    module Types
      class DBRef < DataMapper::Type
        primitive ::Object

        def self.load(value, property)
          typecast(value, property)
        end

        def self.dump(value, property)
          case value
          when NilClass
            nil
          when String
            ::Mongo::ObjectID.from_string(value)
          when ::Mongo::ObjectID
            value
          else
            raise ArgumentError.new('+value+ must be nil, String, ObjectID')
          end
        end

        def self.typecast(value, property)
          case value
          when NilClass
            nil
          when String
            value
          when ::Mongo::ObjectID
            value.to_s
          else
            raise ArgumentError.new('+value+ must be nil, String, ObjectID')
          end
        end
      end # DBRef
    end # Types
  end # Mongo
end # DataMapper
