module DataMapper
  module Mongo
    module EmbeddedResource
      # Raised when trying to save an EmbeddedResource which doesn't have a
      # parent set.
      class MissingParentError < StandardError; end

      include Types
      include DataMapper::Resource

      def self.included(base)
        base.extend(DataMapper::Mongo::EmbeddedModel)
      end

      # @api public
      alias_method :model, :class

      # Returns the resource to which this EmbeddedResource belongs.
      #
      # @return [DataMapper::Mongo::Resource]
      #   The parent
      #
      # @api public
      attr_reader :parent

      # Gets all the attributes of the EmbeddedResource instance
      #
      # @param [Symbol] key_on
      #   Use this attribute of the Property as keys.
      #   defaults to :name. :field is useful for adapters
      #   :property or nil use the actual Property object.
      #
      # @return [Hash]
      #   All the attributes
      #
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

      # Sets the resource to which this EmbeddedResource belongs
      #
      # @param [DataMapper::Mongo::Resource] resource
      #   The new parent resource
      #
      # @api public
      def parent=(resource)
        @parent = resource
      end

      # Returns whether this resource (or rather, it's parent) has been saved
      #
      # @return [Boolean]
      #
      # @api public
      def saved?
        parent && parent.saved?
      end

      # Returns whether this resource (or rather, it's parent) is unsaved
      #
      # @return [Boolean]
      #
      # @api public
      def new?
        !parent? || parent.new?
      end

      # Returns if the EmbeddedResource has a parent set
      #
      # @return [Boolean]
      #
      # @api public
      def parent?
        !parent.nil?
      end

      # Saves the EmbeddedResource by saving the parent
      #
      # @return [Boolean]
      #   Returns true if the resource was successfully saved, false
      #   otherwise
      #
      # @raise [MissingParentError]
      #   Raises a MissingParentError if a parent has not been set
      #
      # @api public
      def save
        if parent
          if parent.save
            original_attributes.clear
          end
        else
          raise(MissingParentError)
        end
      end

      # Checks if the resource has unsaved changes
      #
      # @return [Boolean]
      #  True if resource may be persisted
      #
      # @api public
      def dirty_self?
        if original_attributes.any?
          true
        elsif new?
          properties.any? { |property| property.default? }
        else
          false
        end
      end

    end # EmbeddedResource
  end # Mongo
end # DataMapper
