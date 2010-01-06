module DataMapper
  module Mongo
    module EmbeddedResource
      class MissingParentError < StandardError; end

      include Types
      include DataMapper::Resource

      DataMapper::Model.descendants.delete(self)

      def self.included(base)
        base.extend(DataMapper::Mongo::EmbeddedModel)
      end

      # @api public
      alias_method :model, :class

      # @api public
      attr_reader :parent

      # @overrides DataMapper::Resource#attributes
      def attributes(key_on=:name)
        attributes = {}

        fields.each do |property|
          if model.public_method_defined?(name = property.name)
            key = case key_on
            when :name  then name
            when :field then property.field
            else             property
            end

            attributes[key] = __send__(name)
          end
        end

        attributes
      end

      def parent=(resource)
        @parent = resource
      end

      def saved?
        parent && parent.saved?
      end

      def new?
        !parent? || parent.new?
      end

      def parent?
        !parent.nil?
      end

      def save
        if parent
          if parent.save
            original_attributes.clear
          end
        else
          raise(MissingParentError)
        end
      end

      def dirty_self?
        if original_attributes.any?
          true
        elsif new?
          properties.any? { |property| property.default? }
        else
          false
        end
      end
    end
  end
end
