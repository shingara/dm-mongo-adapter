module DataMapper
  module Mongo
    module Types
      class Array < DataMapper::Type
        primitive ::Object
      end

      # TODO: make it work with symbolized keys
      class Hash < DataMapper::Type
        primitive ::Object
      end
    end
  end
end
