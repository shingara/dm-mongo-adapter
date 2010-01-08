module DataMapper
  module Types
    class Discriminator < DataMapper::Type
      primitive String
      def self.load(value, property)
        typecast(value, property)
      end

      def self.dump(value, property)
        value.name
      end

      def self.typecast(value, property)
        if value
          if value.is_a?(String)
            Object.const_get(value)
          else
            value
          end
        end
      end
    end
  end
end
