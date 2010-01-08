module DataMapper
  module Mongo
    module Types
      class ObjectID < DataMapper::Type
        primitive ::Object
        key true
        field "_id"
        required false

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
            raise ArgumentError.new('+value+ must be nil, String or ObjectID')
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
            raise ArgumentError.new('+value+ must be nil, String or ObjectID')
          end
        end
      end # ObjectID
    end # Types
  end # Mongo
end # DataMapper
