module DataMapper
  module Types
    class Discriminator < DataMapper::Type
      def self.load(value, property)
        typecast(value, property)
      end

      def self.typecast(value, property)
        value.is_a?(String) ? Object.const_get(Extlib::Inflection.classify(value)) : value
      end
    end
  end
end
