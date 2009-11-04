module DataMapper
  module Mongo
    module Resource
      def self.included(base)
        base.send(:include, DataMapper::Resource)
        base.send(:include, DataMapper::Mongo::Types)
      end
    end
  end
end
