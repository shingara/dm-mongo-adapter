module DataMapper
  module Mongo
    module Embedments
      class Relationship
        attr_reader :name
        attr_reader :child_model
        attr_reader :parent_model
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
        
        private
        
        def initialize(name, child_model, parent_model, options={})
          @name = name
          @instance_variable_name = "@#{@name}".freeze
          @child_model = child_model
          @parent_model = parent_model
          @options = options.dup.freeze
          @reader_visibility = @options.fetch(:reader_visibility, :public)
          @writer_visibility = @options.fetch(:writer_visibility, :public)
        end
      end
    end
  end
end
