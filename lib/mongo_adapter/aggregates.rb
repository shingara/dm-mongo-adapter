module DataMapper
  module Mongo
    module Aggregates
      # TODO: document
      # @api semipublic
      def aggregate(query)
        operator = query.fields.first.operator

        unless Query.instance_methods.include?(operator.to_s)
          raise NotImplementedError.new("Mongo Adapter doesn't support ##{operator} yet.")
        end

        with_collection(query.model) do |collection|
          [Query.new(collection, query).send(operator)]
        end
      end
    end # class Aggregates
  end # module Mongo

  Aggregates::MongoAdapter = DataMapper::Mongo::Aggregates
end # module DataMapper
