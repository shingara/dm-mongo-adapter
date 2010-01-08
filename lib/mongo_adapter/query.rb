module DataMapper
  module Mongo
    # This class is responsible for taking Query instances from DataMapper and
    # formatting the query such that it can be performed by the Mongo library.
    class Query
      include Extlib::Assertions
      include DataMapper::Query::Conditions

      # Creates a new Query instance
      #
      # @param [Mongo::Collection] collection
      # @param [DataMapper::Query] query
      #
      # @api semipublic
      def initialize(collection, query)
        assert_kind_of 'collection', collection, ::Mongo::Collection
        assert_kind_of 'query', query, DataMapper::Query

        @collection = collection
        @query      = query
        @statements = {}
        @conditions = Conditions.new(query.conditions)
      end

      # Applies the query to the collection
      #
      # Reads the query options, fetches the resources matching the query
      # statements and filters according to the conditions.
      #
      # @return [Mongo::Collection]
      #
      # @api semipublic
      def read
        options         = {}
        options[:limit] = @query.limit if @query.limit
        options[:sort]  = sort_statement(@query.order) unless @query.order.empty?

        conditions_statement(@query.conditions)

        records = @conditions.filter_collection!(@collection.find(@statements, options).to_a)
        records.map{|record| typecast_record(record)}
      end

      private


      # Typecasts Date and DateTime properties in a record
      #
      # @param [Resource, Hash] record
      #   A DataMapper resource, or a hash containing fields and values.
      #
      # @return [Resource, Hash]
      #
      # @api private
      def typecast_record(record)
        @query.model.properties.each do |property|
          type  = property.primitive

          key   = property.name.to_s
          value = record[key]

          unless value.nil?
            if type == DateTime
              record[key] = value.to_datetime
            elsif type == Date
              record[key] = Date.parse(value.to_s)
            end
          end
        end

        record
      end

      # Takes a condition and returns a Mongo-compatible hash
      #
      # @param [DataMapper::Query::Conditions::AbstractOperation, DataMapper::Query::Conditions::AbstractComparison] operation
      #   An operation to be made suitable for use with Mongo
      # @param [Boolean] affirmative
      #   Are we looking for resources which match the condition (true), or
      #   those which do not match (false)
      #
      # @return [Hash]
      #
      # @api private
      def conditions_statement(conditions, affirmative = true)
        case conditions
        when AbstractOperation  then operation_statement(conditions, affirmative)
        when AbstractComparison then comparison_statement(conditions, affirmative)
        end
      end

      # Takes a Operation condition and returns a Mongo-compatible hash
      #
      # @param [DataMapper::Query::Conditions::Operation] operation
      #   An operation to be made suitable for use with Mongo
      # @param [Boolean] affirmative
      #   Are we looking for resources which match the condition (true), or
      #   those which do not match (false)
      #
      # @return [Hash]
      #
      # @api private
      def operation_statement(operation, affirmative = true)
        case operation
        when NotOperation then conditions_statement(operation.first, !affirmative)
        when AndOperation then operation.each{|op| conditions_statement(op, affirmative)}
        when OrOperation  then operation.each{|op| conditions_statement(op, affirmative)}
        end
      end

      # Takes a Comparison condition and returns a Mongo-compatible hash
      #
      # @param [DataMapper::Query::Conditions::Comparison] comparison
      #   An comparison to be made suitable for use with Mongo
      # @param [Boolean] affirmative
      #   Are we looking for resources which match the condition (true), or
      #   those which do not match (false)
      #
      # @return [Hash]
      #
      # @api private
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
            when InclusionComparison            then inclusion_comparison_operator(comparison, value)
            when RegexpComparison               then value
            when LikeComparison                 then comparison.send(:expected)
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

      # Creates Mongo's equivalent of an IN() condition
      #
      # @param [DataMapper::Query::Conditions::Comparison] comparison
      #   An comparison to be made suitable for use with Mongo
      # @param [Object] value
      #   The value to match against.
      #
      # @return [Hash]
      #
      # @api private
      def inclusion_comparison_operator(comparison, value)
        if value.kind_of?(Range)
          {'$gte' => value.first, value.exclude_end? ? '$lt' : '$lte' => value.last}
        elsif comparison.kind_of?(InclusionComparison) && value.size == 1
          value.first
        elsif comparison.subject.type == DataMapper::Mongo::Types::EmbeddedArray
          value
        else
          {'$in'  => value}
        end
      end

      # Constructs a sort statement which can be used by the Mongo library
      #
      # Mongo::Collection#find requires that sort statements consist of an
      # array where each element is another array containing the field name
      # and the sort order.
      #
      # @param [Enumerable<DataMapper::Query::Direction>]
      #
      # @return [Array<Array>]
      #
      # @api private
      def sort_statement(conditions)
        conditions.inject([]) do |sort_arr, condition|
          sort_arr << [condition.target.field, condition.operator == :asc ? 'ascending' : 'descending']
        end
      end

    end # Query
  end # Mongo
end # DataMapper
