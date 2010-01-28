module DataMapper
  module Mongo
    module Types
      class DateTime < DataMapper::Type
        primitive ::DateTime

        def self.load(value, property)
          self.typecast(value, property)
        end

        def self.dump(value, property)
          self.typecast(value, property)
        end

        def self.typecast(value, property)
          case value
          when Time
            value.to_datetime
          when ::DateTime
            value.to_time.utc
          when NilClass, Range
            value
          end
        end
      end
    end # Types
  end # Mongo
end # DataMapper
