module DataMapper
  module Mongo
    module Embedments
      class Relationship
        include Extlib::Assertions
        
        attr_reader :name
        attr_reader :target_model
        attr_reader :source_model
        attr_reader :options
        attr_reader :instance_variable_name
        attr_reader :query
        attr_reader :reader_visibility
        attr_reader :writer_visibility

        # @api semipublic
        def get(resource, other_query = nil)
          raise NotImplementedError, "#{self.class}#get not implemented"
        end

        # @api semipublic
        def get!(resource)
          resource.instance_variable_get(instance_variable_name)
        end

        # @api semipublic
        def set(resource, association)
          raise NotImplementedError, "#{self.class}#set not implemented"
        end

        # @api semipublic
        def set!(resource, association)
          resource.instance_variable_set(instance_variable_name, association)
        end

        # @api semipublic
        def loaded?(resource)
          assert_kind_of 'resource', resource, source_model

          resource.instance_variable_defined?(instance_variable_name)
        end

        def load_target(attributes)
          target = target_model.allocate

          target_model.properties do |property|
            property.set!(target, attributes[property.field])
          end

          target
        end

        def query_for(source, other_query = nil)
          Query.new
        end
        
        private
        
        def initialize(name, target_model, source_model, options={})
          @name = name
          @instance_variable_name = "@#{@name}".freeze
          @target_model = target_model
          @source_model = source_model
          @options = options.dup.freeze
          @reader_visibility = @options.fetch(:reader_visibility, :public)
          @writer_visibility = @options.fetch(:writer_visibility, :public)
        end
      end
    end
  end
end
