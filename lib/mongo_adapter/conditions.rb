module DataMapper
  module Mongo
    # Used to filter records from Mongo::Collection according to the
    # conditions defined in a DataMapper::Query. Warns when attempting to use
    # operations which aren't supported by MongoDB.
    class Conditions
      include DataMapper::Query::Conditions

      # Returns the query operation
      #
      # @return [DataMapper::Query::AbstractOperation]
      #   The operation which will be used to filter the collection.
      #
      # @api semipublic
      attr_reader :operation

      # Creates a new Conditions instance
      #
      # @param [DataMapper::Query::AbstractOperation] query_operation
      #   The top-level operation from DataMapper::Query#conditions
      #
      # @api private
      def initialize(query_operation)
        @operation = verify_operation(query_operation)
      end

      # Filters a collection according to the Conditions
      #
      # @param [Enumerable<Hash>] collection
      #   A collection of hashes which correspond to resource values
      #
      # @return [Enumerable<Hash>]
      #   Returns the collection without modification if the condition has no
      #   operations, otherwise it returns a copy of the collection with only
      #   the matching records.
      #
      # @api private
      def filter_collection!(collection)
        @operation.operands.empty? ? collection : collection.delete_if {|record| !@operation.matches?(record)}
      end

      private

      # Returns a copy of the operation, removing _from the original_ any
      # operands which are incompatible with MongoDB.
      #
      # @param [DataMapper::Query::AbstractOperation] query_operation
      #   The top-level operation from DataMapper::Query#conditions
      #
      # @return [DataMapper::Query::AbstractOperation]
      #
      # @api private
      def verify_operation(query_operation)
        operation = query_operation.dup.clear

        query_operation.each do |operand|
          if not_supported?(operand)
            query_operation.operands.delete(operand)
            operation << operand
          elsif operand.kind_of?(AbstractOperation)
            operation << verify_operation(operand)
          end
        end

        operation
      end

      # Checks if a given operand is supported by MongoDB.
      #
      # Comparisons not current supported are:
      #
      #   * $nin with range
      #   * negated regexp comparison (see: http://jira.mongodb.org/browse/SERVER-251)
      #
      # @param [DataMapper::Query::Conditions::AbstractOperation, DataMapper::Query::Conditions::AbstractComparison] operand
      #   An operation to be made suitable for use with Mongo
      #
      # @return [Boolean]
      #
      # @api private
      def not_supported?(operand)
        case operand
        when OrOperation
          true
        when RegexpComparison
          if operand.negated?
            true
          end
        when InclusionComparison
          if operand.negated?
            true
          end
        else
          false
        end
      end

    end # Conditions
  end # Mongo
end # DataMapper
