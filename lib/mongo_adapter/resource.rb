module DataMapper
  module Mongo
    module Resource
      def self.included(base)
        DataMapper::Model.append_extensions(ModelMethods)

        base.send(:include, DataMapper::Resource) unless base.kind_of?(DataMapper::Resource)
        base.send(:include, ResourceMethods)
        base.send(:include, DataMapper::Mongo::Types)
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

        # @overrides DataMapper::Resource#dirty?
        def dirty?
          super || run_once(true) { dirty_embedments? }
        end

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

        # @overrides DataMapper::Resource#dirty_attributes
        def dirty_attributes
          embedded_attributes = {}

          each_embedment do |name, resource|
            embedded_attributes[embedments[name]] = resource.dirty_attributes if resource.dirty?
          end

          super.merge(embedded_attributes)
        end

        private

        # @api private
        def embedments
          model.embedments
        end

        def each_embedment
          embedments.each { |name, embedment|
            embedment.loaded?(self) && yield(name, embedment.get!(self)) }
        end

        # @overrides DataMapper::Resource#save_self
        def save_self(safe = true)
          super && embedments.values.each do |e|
            e.loaded?(self) && Array(e.get!(self)).each { |r| r.original_attributes.clear }
          end
        end
      end

      module ModelMethods
        # @overrides DataMapper::Model#load
        def load(records, query)
          if discriminator = properties(query.repository.name).discriminator
            records.each do |record|
              discriminator_key   = discriminator.name.to_s
              discriminator_value = discriminator.type.load(record[discriminator_key], discriminator)

              record[discriminator_key] = discriminator_value
            end
          end

          resources = super

          # Load embedded resources
          resources.each_with_index do |resource, index|
            resource.model.embedments.each do |name, relationship|
              unless (targets = records[index][name.to_s]).blank?
                relationship.set(resource, targets, true)
              end
            end
          end

          resources
        end
      end
    end
  end
end
