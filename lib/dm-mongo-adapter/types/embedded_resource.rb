# This is a workaround so we can use embedded resources as properties
module DataMapper
  module Mongo
    module Types
      class EmbeddedResource < DataMapper::Type
        primitive Object
        lazy false

        def self.load(record, property)
          typecast(record, property)
        end

        def self.dump(record, property)
          typecast(record, property, true)
        end

        def self.typecast(record, property, new=false)
          if record.nil?
            nil
          elsif record.kind_of?(Hash) || record.kind_of?(OrderedHash)
            if new
              record
            else
              klass = Extlib::Inflection.constantize(property.name.to_s.camel_case)
              klass.new(record || {})
            end
          elsif record.kind_of?(DataMapper::Mongo::EmbeddedResource)
            if new
              record.attributes.to_h
            else
              record
            end
          else
            raise ArgumentError.new("+value+ must be nil, Hash or DataMapper::Mongo::EmbeddedResource")
          end
        end
      end
    end
  end
end
