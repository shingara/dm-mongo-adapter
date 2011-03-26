module DataMapper
  module Mongo
    class Property
      class Array < DataMapper::Property::Object
        include DataMapper::Property::PassThroughLoadDump
        primitive ::Array
      end
    end # Property
  end # Mongo
end # DataMapper
