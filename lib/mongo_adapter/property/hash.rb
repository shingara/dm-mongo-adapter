require 'active_support/core_ext/hash/keys'

module DataMapper
  module Mongo
    class Property
      class Hash < DataMapper::Property::Object
        include DataMapper::Property::PassThroughLoadDump
        primitive ::Hash

        # @api semipublic
        def load(value)
          typecast_to_primitive(value)
        end

        # @api semipublic
        def typecast_to_primitive(value)
          case value
          when NilClass
            nil
          when ::Hash
            value.symbolize_keys
          when ::Array
            value.empty? ? {} : {value.first.to_sym => value.last}
          end
        end
      end #Array
    end # Property
  end # Mongo
end # DataMapper
