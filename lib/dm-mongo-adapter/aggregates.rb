module DataMapper
  module Mongo
    module Aggregates
      # TODO: document
      # @api semipublic
      def aggregate(query)
        operator = if query.fields.size == 1 && query.fields.first.target == :all
          :count
        else
          :group
        end

        with_collection(query.model) do |collection|
          Query.new(collection, query).send(operator)
        end
      end
    end # class Aggregates
  end # module Mongo

  Aggregates::MongoAdapter = DataMapper::Mongo::Aggregates
end # module DataMapper
