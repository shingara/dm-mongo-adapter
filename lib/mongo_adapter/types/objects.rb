module DataMapper
  module Mongo
    module Types
      class EmbeddedArray < DataMapper::Type
        primitive Object
      end

      class EmbeddedHash < DataMapper::Type
        primitive Object

        # @api public
        def self.load(value, property)
          typecast(value, property)
        end

        # @api semipublic
        def self.typecast(value, property)
          case value
          when NilClass
            nil
          when Hash
            value.to_mash.symbolize_keys
          when Array
            value.empty? ? Mash.new : [value].to_mash.symbolize_keys
          end
        end
      end #EmbeddedHash

    end # Types
  end # Mongo
end # DataMapper
