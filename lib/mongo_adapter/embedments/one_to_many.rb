module DataMapper
  module Mongo
    module Embedments
      module OneToMany
        class Relationship < Embedments::Relationship
          # Loads and returns embedment target for given source
          #
          # @param [DataMapper::Mongo::Resource] source
          #   The resource whose relationship value is to be retrieved.
          #
          # @return [DataMapper::Collection]
          #
          # @api semipublic
          def get(source, other_query = nil)
            assert_kind_of 'source', source, source_model

            unless loaded?(source)
              set!(source, collection_for(source, other_query))
            end

            get!(source)
          end

          # Sets and returns association target for given source
          #
          # @param [DataMapper::Mongo::Resource] source
          #   The parent resource whose target is to be set.
          # @param [DataMapper::Mongo::EmbeddedResource] targets
          #   The embedded resources to be set to the relationship
          # @param [Boolean] loading
          #   Do the attributes have to be loaded before being set? Setting
          #   this to true will typecase the attributes, and set the
          #   original_values on the resource.
          #
          # @api semipublic
          def set(source, targets, loading=false)
            assert_kind_of 'source',  source,  source_model
            assert_kind_of 'targets', targets, Array

            targets = targets.map{|t| t.kind_of?(Hash) ? load_target(source, t) : t.parent = source}

            set_original_attributes(source, targets) unless loading

            unless loaded?(source)
              set!(source, collection_for(source))
            end

            get!(source).replace(targets)
          end

          private

          # Creates a new collection instance for the source resources.
          #
          # @param [DataMapper::Mongo::Resource] source
          #   The resources to be wrapped in a Collection.
          #
          # @return [DataMapper::Collection]
          #
          # @api private
          def collection_for(source, other_query=nil)
            Collection.new(source)
          end
        end

        # Extends Array to ensure that each EmbeddedResource has it's +parent+
        # attribute set.
        class Collection < Array
          # Returns the resource to which this collection belongs
          #
          # @return [DataMapper::Mongo::Resource]
          #   The resource to which the contained EmbeddedResource instances
          #   belong.
          #
          # @api semipublic
          attr_reader :source

          # Creates a new Collection instance
          #
          # @param [DataMapper::Mongo::Resource] source
          #   The resource to which the contained EmbeddedResource instances
          #   belong.
          #
          # @api semipublic
          def initialize(source)
            @source = source
          end

          # Adds a new embedded resource to the collection
          #
          # @param [DataMapper::Mongo::EmbeddedResource] resource
          #   The embedded resource to be added.
          #
          # @api semipublic
          def <<(resource)
            resource.parent = source
            super(resource)
          end
        end

      end # OneToMany
    end # Embedments
  end # Mongo
end # DataMapper
