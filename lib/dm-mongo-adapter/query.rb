module DataMapper
  module Mongo
    class Query
      include Extlib::Assertions
      include DataMapper::Query::Conditions

      def initialize(collection, query)
        assert_kind_of 'collection', collection, ::Mongo::Collection
        assert_kind_of 'query', query, DataMapper::Query
        @collection, @query, @statements = collection, query, {}
      end

      def read
        options         = {}
        options[:limit] = @query.limit if @query.limit
        options[:sort]  = sort_statement(@query.order) unless @query.order.empty?

        conditions_statement(@query.conditions)

        @collection.find(@statements, options).to_a
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
            when OrOperation  then raise NotImplementedError
          end
        end

        #--
        # TODO: Rather than raise an error do what we can in a $where operation or in memory.
        def comparison_statement(comparison, affirmative = true)
          if comparison.relationship?
            return conditions_statement(comparison.foreign_key_mapping, affirmative)
          end

          field = comparison.subject.field
          value = comparison.value

          operator = if affirmative
            case comparison
              when EqualToComparison              then value
              when GreaterThanComparison          then {'$gt'  => value}
              when LessThanComparison             then {'$lt'  => value}
              when GreaterThanOrEqualToComparison then {'$gte' => value}
              when LessThanOrEqualToComparison    then {'$lte' => value}
              when InclusionComparison            then value.kind_of?(Range) ? range_comparison(field, value) : {'$in'  => value}
              when RegexpComparison               then value
              when LikeComparison                 then like_comparison_regexp(value)
              else raise NotImplementedError
            end
          else
            case comparison
              when EqualToComparison              then {'$ne'  => value}
              when InclusionComparison            then value.kind_of?(Range) ? range_comparison(field, value, false) : {'$nin' => value}
              else raise NotImplementedError
            end
          end

          statement = operator.is_a?(Hash) && operator.has_key?('$where') ? operator : {field.to_sym => operator}

          @statements.update(statement)
        end

        def sort_statement(conditions)
          conditions.inject([]) do |sort_arr, condition|
           sort_arr << [condition.target.field, condition.operator == :asc ? 'ascending' : 'descending']
          end
        end

        def like_comparison_regexp(value)
          # TODO: %% isn't supported. It isn't in LikeComparison's matches? fyi.
          Regexp.new(value.to_s.gsub(/^([^%])/, '^\\1').gsub(/([^%])$/, '\\1$').gsub(/%/, '.*').gsub('_', '.'))
        end

        def range_comparison(field, range, affirmative=true)
          if affirmative
            {'$gte' => range.first, range.exclude_end? ? '$lt' : '$lte' => range.last}
          else
            {'$where' => "this.#{field} < #{range.first} || this.#{field} #{range.exclude_end? ? '>=' : '>'} #{range.last}"}
          end
        end
    end # Query
  end # Mongo
end # DataMapper