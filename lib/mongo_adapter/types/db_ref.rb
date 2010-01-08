module DataMapper
  module Mongo
    module Types
      # Database references are references from one document (object) to
      # another within a database. A database reference is a standard embedded
      # object: this is a MongoDB convention, not a special type.
      #
      # The DBRef is made available via your model as a String.
      #
      # @see http://www.mongodb.org/display/DOCS/DB+Ref
      #
      # @api public
      class DBRef < DataMapper::Type
        primitive ::Object

        # Returns the DBRef as a string; suitable for use in a Resource
        #
        # @return [String]
        #
        # @api public
        def self.load(value, property)
          typecast(value, property)
        end

        # Returns the DBRef as a Mongo ObjectID; suitable to be passed to the
        # Mongo library
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
            raise ArgumentError.new('+value+ must be nil, String, ObjectID')
          end
        end

        # Returns the DBRef as a string
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
            raise ArgumentError.new('+value+ must be nil, String, ObjectID')
          end
        end

      end # DBRef
    end # Types
  end # Mongo
end # DataMapper
