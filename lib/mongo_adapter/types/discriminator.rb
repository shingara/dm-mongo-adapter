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
        Object.const_get(Extlib::Inflection.classify(value)) if value
      end
    end
  end
end
