module DataMapper
  module Mongo
    module EmbeddedResource
      include Types
      include DataMapper::Resource

      def self.included(base)
        base.extend(DataMapper::Mongo::EmbeddedModel)
      end

      # @api public
      alias_method :model, :class

      # @api public
      attr_reader :parent

      def parent=(resource)
        @parent = resource
      end

      private

      # @api public
      def initialize(attributes = {}, &block) # :nodoc:
        self.attributes = attributes
      end

      def saved?
        parent && parent.saved?
      end
    end
  end
end
