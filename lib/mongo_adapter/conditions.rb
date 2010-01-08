module DataMapper
  module Mongo
    class Conditions
      include DataMapper::Query::Conditions

      attr_reader :operation

      def initialize(query_operation)
        @operation = verify_operation(query_operation)
      end

      def filter_collection!(collection)
        @operation.operands.empty? ? collection : collection.delete_if {|record| !@operation.matches?(record)}
      end

      private

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

      # Currently not supported comparisons are:
      #
      #   * $nin with range
      #   * negated regexp comparison (see: http://jira.mongodb.org/browse/SERVER-251)
      #
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
    end
  end
end
