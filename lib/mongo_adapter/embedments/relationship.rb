module DataMapper
  module Mongo
    module Embedments
      # Base class for embedment relationships. Each type of relationship
      # (1 to 1, 1 to n) implements a subclass of this class with methods like
      # get and set overridden.
      class Relationship
        include Extlib::Assertions

        # Relationship name
        #
        # @example for :parent relationship in
        #
        #   class VersionControl::Commit
        #     # ...
        #     belongs_to :parent
        #   end
        #
        #   name is :parent
        #
        # @api semipublic
        attr_reader :name

        # Returns the model class used by the child side of the relationship
        #
        # @return [Resource]
        #   Model for relationship child
        #
        # @api semipublic
        attr_reader :target_model

        # Returns the model class used by the parent side of the relationship
        #
        # @return [Resource]
        #   Model for relationship parent
        #
        # @api semipublic
        attr_reader :source_model

        # Options used to set up this relationship
        #
        # @example for :author relationship in
        #
        #   class VersionControl::Commit
        #     # ...
        #
        #     belongs_to :author, :model => 'Person'
        #   end
        #
        #   options is a hash with a single key, :model
        #
        # @api semipublic
        attr_reader :options

        # The name of the variable used to store the relationship
        #
        # @example for :commits relationship in
        #
        #   class VersionControl::Branch
        #     # ...
        #
        #     has n, :commits
        #   end
        #
        #   instance variable name for source will be @commits
        #
        # @api semipublic
        attr_reader :instance_variable_name

        # Returns query options for relationship.
        #
        # For this base class, always returns query options has been
        # initialized with. Overridden in subclasses.
        #
        # @api private
        attr_reader :query

        # Returns the visibility for the source accessor
        #
        # @return [Symbol]
        #   the visibility for the accessor added to the source
        #
        # @api semipublic
        attr_reader :reader_visibility

        # Returns the visibility for the source accessor
        #
        # @return [Symbol]
        #   the visibility for the accessor added to the source
        #
        # @api semipublic
        attr_reader :writer_visibility

        # Loads and returns "other end" of the embedment
        #
        # Must be implemented in subclasses.
        #
        # @api semipublic
        def get(resource, other_query = nil)
          raise NotImplementedError, "#{self.class}#get not implemented"
        end

        # Gets "other end" of the embedment directly
        #
        # @api semipublic
        def get!(resource)
          resource.instance_variable_get(instance_variable_name)
        end

        # Sets value of the "other end" of the embedment on given resource
        #
        # Must be implemented in subclasses.
        #
        # @api semipublic
        def set(resource, association)
          raise NotImplementedError, "#{self.class}#set not implemented"
        end

        # Sets "other end" of the embedment directly.
        #
        # @api semipublic
        def set!(resource, association)
          resource.instance_variable_set(instance_variable_name, association)
        end

        # @api semipublic
        def set_original_attributes(resource, association)
          Array(association).each do |association|
            resource.original_attributes[self] = association.original_attributes if association.dirty?
          end
        end

        # Checks if "other end" of the embedment is loaded on given resource
        #
        # @api semipublic
        def loaded?(resource)
          assert_kind_of 'resource', resource, source_model

          resource.instance_variable_defined?(instance_variable_name)
        end

        # Creates an instance of the target model with its attributes
        #
        # @param [DataMapper::Mongo::Resource] source
        #   The source model to which the target belongs.
        # @param [Hash, #to_mash] attributes
        #   The attributes to be set on the embedded resource.
        # @param [Boolean] loading
        #   Do the attributes have to be loaded before being set? Setting
        #   this to true will typecase the attributes, and set the
        #   original_values on the resource.
        #
        # @return [DataMapper::Mongo::EmbeddedResource]
        #   The initialized embedded resource instance.
        #
        # @api semipublic
        def load_target(source, attributes, loading=false)
          target = target_model.allocate
          target.parent = source

          attributes = attributes.to_mash

          target_model.properties.each do |property|
            property.send(loading ? :set! : :set, target, attributes[property.field])
          end

          target
        end

        # Creates and returns Query instance that represents the embedment
        #
        # The returned query can be used to fetch target resource(s)
        # (ex.: articles) for given target resource (ex.: author).
        #
        # @return [DataMapper::Mongo::Query]
        #
        # @api semipublic
        def query_for(source, other_query = nil)
          Query.new
        end

        # Creates a hash of attributes for the relationship.
        #
        # @api semipublic
        def value(relationship)
          relationship.model.properties.map { |property| [property, property.get(relationship)] }.to_hash
        end

        # Test the resource to see if it is a valid target
        #
        # @param [Object] relationship
        #   The resource or collection to be tested
        #
        # @return [Boolean]
        #   True if the resource is valid
        #
        # @api semipublic
        def valid?(relationship)
          relationship.kind_of?(target_model)
        end

        private

        # Creates a new Relationship instance
        #
        # @param [DataMapper::Mongo::EmbeddedModel] target_model
        #   The child side of the relationship.
        # @param [DataMapper::Mongo::Model] source_model
        #   The parent side of the relationship.
        # @param [Hash] options
        #   Options for customising the relationship.
        #
        # @option options [Symbol] :reader_visibility
        #   The visibility of the reader method created on the source model;
        #   one of public, protected or private.
        # @option options [Symbol] :writer_visibility
        #   The visibility of the writer method created on the source model;
        #   one of public, protected or private.
        #
        def initialize(name, target_model, source_model, options={})
          @name = name
          @instance_variable_name = "@#{@name}".freeze
          @target_model = target_model
          @source_model = source_model
          @options = options.dup.freeze
          @reader_visibility = @options.fetch(:reader_visibility, :public)
          @writer_visibility = @options.fetch(:writer_visibility, :public)
        end

      end # Relationship
    end # Embedments
  end # Mongo
end # DataMapper
