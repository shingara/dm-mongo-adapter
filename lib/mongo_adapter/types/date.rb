module DataMapper
  module Mongo
    module Types
      class Date < DataMapper::Type
        primitive ::Date

        def self.load(value, property)
          self.typecast(value, property)
        end

        def self.dump(value, property)
          self.typecast(value, property)
        end

        def self.typecast(value, property)
          case value
          when ::Date
            Time.utc(value.year, value.month, value.day)
          when ::Time
            ::Date.new(value.year, value.month, value.day)
          when NilClass, Range
            value
          end
        end
      end
    end # Types
  end # Mongo
end # DataMapper
