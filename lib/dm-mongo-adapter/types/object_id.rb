module DataMapper
  module Mongo
    module Types
      class ObjectID < DataMapper::Type
        primitive ::Object
        default lambda{|r, p| ::Mongo::ObjectID.new}

        def self.load(value, property)
          typecast(value, property)
        end

        def self.dump(value, property)
          typecast(value, property)
        end

        def self.typecast(value, property)
          if value.nil?
            nil
          elsif value.is_a?(String)
            ::Mongo::ObjectID.from_string(value)
          elsif value.is_a?(::Mongo::ObjectID)
            value
          else
            raise ArgumentError.new('+value+ must be nil, String or ObjectID')
          end
        end
      end # ObjectID
    end # Types
  end # Mongo
end # DataMapper
