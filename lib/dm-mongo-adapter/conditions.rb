module DataMapper
  module Mongo
    class Conditions
      def initialize
        @comparisons = []
        @conditions  = []
      end

      def to_statement
        { '$where' => @conditions.join(' || ') }
      end
      
      def empty?
        @conditions.empty?
      end

      def filter_collection!(canditates)
        canditates if @comparisons.empty?

        collection = []
        canditates.each do |record|
          collection << record if @comparisons.all? do |filter|
            !record[filter.subject.field].nil? &&
            filter.negated? ? !filter.matches?(record) : filter.matches?(record)
          end
        end
        collection
      end

      def add(comparison, affirmative)
        field = comparison.subject.field
        value = comparison.value

        operator = if affirmative
          case comparison
          when DataMapper::Query::Conditions::EqualToComparison then
            "this.#{field} == #{value}"
          when DataMapper::Query::Conditions::GreaterThanComparison then
            "this.#{field} > #{value}"
          when DataMapper::Query::Conditions::LessThanComparison then
            "this.#{field} < #{value}"
          when DataMapper::Query::Conditions::GreaterThanOrEqualToComparison then
            "this.#{field} >= #{value}"
          when DataMapper::Query::Conditions::LessThanOrEqualToComparison then
            "this.#{field} <= #{value}"
          when DataMapper::Query::Conditions::InclusionComparison then
            range_comparison(field, value) if value.kind_of?(Range)
          when DataMapper::Query::Conditions::RegexpComparison then
            "this.#{field} =~ /#{value.source}/"
          when DataMapper::Query::Conditions::LikeComparison then
            "this.#{field} =~ /#{comparison.send(:expected_value).source}/"
          end
        else
          case comparison
          when DataMapper::Query::Conditions::InclusionComparison then
            range_comparison(field, value, false) if value.kind_of?(Range)
          end
        end

        if operator
          @conditions.push(operator)
        elsif !value.blank?
          @comparisons.push(comparison)
        end
      end

      private

      def range_comparison(field, range, affirmative=true)
        if affirmative
          "(this.#{field} >= #{range.first} && this.#{field} #{range.exclude_end? ? '<' : '<='} #{range.last})"
        else
          "(this.#{field} < #{range.first} || this.#{field} #{range.exclude_end? ? '>=' : '>'} #{range.last})"
        end
      end
    end
  end
end