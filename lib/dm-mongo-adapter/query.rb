module DataMapper
  module Mongo
    class Query
      include Extlib::Assertions
      include DataMapper::Query::Conditions

      def initialize(collection, query)
        assert_kind_of 'collection', collection, ::Mongo::Collection
        assert_kind_of 'query', query, DataMapper::Query
        @collection, @query, @statements, @conditions = collection, query, {}, Conditions.new
      end

      def read
        options         = {}
        options[:limit] = @query.limit if @query.limit
        options[:sort]  = sort_statement(@query.order) unless @query.order.empty?

        conditions_statement(@query.conditions)

        @statements.merge!(@conditions.to_statement) unless @conditions.empty?

        @conditions.filter_collection!(@collection.find(@statements, options).to_a)
      end

      private
      
      def conditions_statement(conditions, affirmative = true)
        case conditions
        when AbstractOperation  then operation_statement(conditions, affirmative)
        when AbstractComparison then comparison_statement(conditions, affirmative)
        end
      end

      def operation_statement(operation, affirmative = true)
        case operation
        when NotOperation then conditions_statement(operation.first, !affirmative)
        when AndOperation then operation.each{|op| conditions_statement(op, affirmative)}
        when OrOperation  then operation.each{|op| @conditions.add(op, affirmative)}
        end
      end

      def comparison_statement(comparison, affirmative = true)
        if comparison.relationship?
          return conditions_statement(comparison.foreign_key_mapping, affirmative)
        end

        field = comparison.subject.field
        value = comparison.value

        # these comparisons should be handled by the conditions object, because:
        #
        # * $nin with range requires $where clause
        # * negated regexp comparison is currently not supported by mongo, see: http://jira.mongodb.org/browse/SERVER-251
       if (comparison.kind_of?(InclusionComparison) && value.kind_of?(Range) && !affirmative) ||
          (comparison.kind_of?(RegexpComparison) && !affirmative)
          @conditions.add(comparison, affirmative)
          return
        end

        operator = if affirmative
          case comparison
            when EqualToComparison              then value
            when GreaterThanComparison          then {'$gt'  => value}
            when LessThanComparison             then {'$lt'  => value}
            when GreaterThanOrEqualToComparison then {'$gte' => value}
            when LessThanOrEqualToComparison    then {'$lte' => value}
            when InclusionComparison            then value.kind_of?(Range) ?
              {'$gte' => value.first, value.exclude_end? ? '$lt' : '$lte' => value.last}  : {'$in'  => value}
            when RegexpComparison               then value
            when LikeComparison                 then comparison.send(:expected_value)
          else
            raise NotImplementedError
          end
        else
          case comparison
            when EqualToComparison              then {'$ne'  => value}
            when InclusionComparison            then {'$nin' => value}
          else
            raise NotImplementedError
          end
        end

        operator.is_a?(Hash) ?
          (@statements[field.to_sym] ||= {}).merge!(operator) : @statements[field.to_sym] = operator
      end

      def sort_statement(conditions)
        conditions.inject([]) do |sort_arr, condition|
          sort_arr << [condition.target.field, condition.operator == :asc ? 'ascending' : 'descending']
        end
      end
    end # Query
  end # Mongo
end # DataMapper
