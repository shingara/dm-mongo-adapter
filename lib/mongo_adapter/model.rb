module DataMapper
  module Mongo
    module Model
      def self.extended(model)
        model.extend Embedment
      end

      # Loads an instance of this Model, taking into account IdentityMap
      # lookup, inheritance columns(s) and Property typecasting. Also loads
      # the embedments on the Resource.
      #
      # @param [Enumerable<Object>] records
      #   An Array of Resource or Hashes to load a Resource with
      # @param [DataMapper::Query] query
      #   The query used to load the Resource
      #
      # @return [Resource]
      #   The loaded Resource instance
      #
      # @overrides DataMapper::Model#load
      #
      # @api semipublic
      def load(records, query)
        if discriminator = properties(query.repository.name).discriminator
          records.each do |record|
            discriminator_key   = discriminator.name.to_s
            discriminator_value = discriminator.type.load(record[discriminator_key], discriminator)

            record[discriminator_key] = discriminator_value
          end
        end

        resources = super

        # Load embedded resources
        resources.each_with_index do |resource, index|
          resource.model.embedments.each do |name, relationship|
            unless (targets = records[index][name.to_s]).blank?
              relationship.set(resource, targets, true)
            end
          end
        end

        resources
      end

    end # Model
  end # Mongo
end # DataMapper
