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

        private

        # @api private
        def embedments
          model.embedments
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
          resources = super

          # Load embedded resources
          resources.each_with_index do |resource, index|
            resource.model.embedments.each do |name, relationship|
              unless (targets = records[index][name.to_s]).blank?
                relationship.set(resource, targets)
              end

            end
          end

          resources
        end
      end
    end
  end
end
