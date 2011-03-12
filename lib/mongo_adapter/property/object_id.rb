module DataMapper
  module Mongo
    class Property
      # Each object (document) stored in Mongo DB has an _id field as its
      # first attribute.  This is an object id.  It must be unique for each
      # member of a collection (this is enforced if the collection has an _id
      # index, which is the case by default).
      #
      # The database will assign an _id if an object being inserted into a
      # collection does not have one.
      #
      # The _id may be of any type as long as it is a unique value.
      #
      # @see http://www.mongodb.org/display/DOCS/Object+IDs
      #
      # @api public
      class ObjectId < DataMapper::Property::Object
        include DataMapper::Property::PassThroughLoadDump

        primitive ::BSON::ObjectId
        key true
        field "_id"
        required false

        # Returns the ObjectId as a string
        #
        # @return [String]
        #
        # @api semipublic
        def typecast_to_primitive(value)
          case value
          when ::String
            ::BSON::ObjectId.from_string(value)
          else
            raise ArgumentError.new('+value+ must String')
          end
        end

        # @api semipublic
        def valid?(value, negated = false)
          value.nil? || primitive?(value)
        end

      end # ObjectId
    end # Property
  end # Mongo
end # DataMapper
