module DataMapper
  module Mongo
    # Used in preference over DataMapper::Resource to add MongoDB-specific
    # functionality to models.
    module Resource
      def self.included(model)
        model.send(:include, DataMapper::Resource)
        model.send(:include, ResourceMethods)
        model.send(:include, DataMapper::Mongo::Types)

        # Needs to be after the inclusion of DM::Resource so as to overwrite
        # methods added by DM::Model.
        model.extend(Model)
      end

      module ResourceMethods
        # monkey patching based on this: http://github.com/datamapper/dm-core/commit/3332db6c25ab9cea9ba58ce62a9ad3038303baa1
        # TODO: remove once dm-core 0.10.3 is released
        def eager_load(properties)
          unless properties.empty? || key.nil? || collection.nil?
            collection.reload(:fields => properties)
          end

          self
        end

        # Checks if the resource, or embedded documents, have unsaved changes
        #
        # @return [Boolean]
        #  True if resource may be persisted
        #
        # @overrides DataMapper::Resource#dirty?
        #
        # @api public
        def dirty?
          super || run_once(true) { dirty_embedments? }
        end

        # Checks if any embedded documents have unsaved changes
        #
        # @return [Boolean]
        #   True if any embedded documents can be persisted
        #
        # @api public
        def dirty_embedments?
          embedments.values.any? do |embedment|
            embedment.loaded?(self) && case embedment
            when Embedments::OneToOne::Relationship  then embedment.get!(self).dirty?
            when Embedments::OneToMany::Relationship then embedment.get!(self).any? { |r| r.dirty? }
            else false
            end
          end
        end

        # Hash of attributes that have unsaved changes
        #
        # @return [Hash]
        #   attributes that have unsaved changes
        #
        # @overrides DataMapper::Resource#dirty_attributes
        #
        # @api semipublic
        def dirty_attributes
          embedded_attributes = {}

          each_embedment do |name, resource|
            embedded_attributes[embedments[name]] = resource.dirty_attributes if resource.dirty?
          end

          super.merge(embedded_attributes)
        end

        private

        # The embedments (relationships to embedded objects) on this model
        #
        # @return [Hash<Symbol,Embedments::Relationship>]
        #
        # @api private
        def embedments
          model.embedments
        end

        # Iterates through each loaded embedment, yielding the name and value
        #
        # @yieldparam [Symbol]
        #   The name of the embedment
        # @yieldparam [Mongo::Collection]
        #   The embedded resource, or collection of embedded resources
        #
        # @api semipublic
        def each_embedment
          embedments.each { |name, embedment|
            embedment.loaded?(self) && yield(name, embedment.get!(self)) }
        end

        # Saves the resource and it's embedments
        #
        # @return [Boolean]
        #   True if the resource was successfully saved
        #
        # @overrides DataMapper::Resource#save_self
        #
        # @api semipublic
        def save_self(safe = true)
          super && embedments.values.each do |e|
            e.loaded?(self) && Array(e.get!(self)).each { |r| r.original_attributes.clear }
          end
        end
      end # ResourceMethods

    end # Resource
  end # Mongo
end # DataMapper
