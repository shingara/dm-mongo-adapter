module DataMapper
  module Mongo
    module Types
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
      class ObjectID < DataMapper::Type
        primitive ::Object
        key true
        field "_id"
        required false

        # Returns the ObjectID as a string; suitable for use in a Resource
        #
        # @return [String]
        #
        # @api public
        def self.load(value, property)
          typecast(value, property)
        end

        # Returns the ObjectID as a Mongo::ObjectID; suitable to be passed to
        # the Mongo library
        #
        # @return [Mongo::ObjectID] The dumped ID.
        #
        # @api public
        def self.dump(value, property)
          case value
          when NilClass
            nil
          when String
            ::Mongo::ObjectID.from_string(value)
          when ::Mongo::ObjectID
            value
          else
            raise ArgumentError.new('+value+ must be nil, String or ObjectID')
          end
        end

        # Returns the ObjectID as a string
        #
        # @return [String]
        #
        # @api public
        def self.typecast(value, property)
          case value
          when NilClass
            nil
          when String
            value
          when ::Mongo::ObjectID
            value.to_s
          else
            raise ArgumentError.new('+value+ must be nil, String or ObjectID')
          end
        end

      end # ObjectID
    end # Types
  end # Mongo
end # DataMapper
