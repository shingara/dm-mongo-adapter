module DataMapper
  module Mongo
    class Property
      # Database references are references from one document (object) to
      # another within a database. A database reference is a standard embedded
      # object: this is a MongoDB convention, not a special type.
      #
      # The DBRef is made available via your model as a String.
      #
      # @see http://www.mongodb.org/display/DOCS/DB+Ref
      #
      # @api public
      class DBRef < DataMapper::Mongo::Property::ObjectID
      end # DBRef
    end # Property
  end # Mongo
end # DataMapper
