module DataMapper
  module Mongo
    class Adapter < DataMapper::Adapters::AbstractAdapter
      # Persists one or more new resources
      #
      # @example
      #   adapter.create(collection)  # => 1
      #
      # @param [Enumerable<Resource>] resources
      #   The list of resources (model instances) to create
      #
      # @return [Integer]
      #   The number of records that were actually saved into the data-store
      #
      # @api semipublic
      def create(resources)
        resources.map do |resource|
          with_collection(resource.model) do |collection|
            resource.model.key.set(resource, [collection.insert(attributes_as_fields(resource))])
          end
        end.size
      end

      # Reads one or many resources from a datastore
      #
      # @example
      #   adapter.read(query)  # => [ { 'name' => 'Dan Kubb' } ]
      #
      # @param [Query] query
      #   The query to match resources in the datastore
      #
      # @return [Enumerable<Hash>]
      #   An array of hashes to become resources
      #
      # @api semipublic
      def read(query)
        with_collection(query.model) do |collection|
          Query.new(collection, query).read
        end
      end

      # Updates one or many existing resources
      #
      # @example
      #   adapter.update(attributes, collection)  # => 1
      #
      # @param [Hash(Property => Object)] attributes
      #   Hash of attribute values to set, keyed by Property
      # @param [Collection] resources
      #   Collection of records to be updated
      #
      # @return [Integer]
      #   The number of records updated
      #
      # @api semipublic
      def update(attributes, resources)
        with_collection(resources.query.model) do |collection|
          resources.each do |resource|
            collection.update(key(resource),
              attributes_as_fields(resource).merge(attributes_as_fields(attributes)))
          end.size
        end
      end

      # Deletes one or many existing resources
      #
      # @example
      #   adapter.delete(collection)  # => 1
      #
      # @param [Collection] resources
      #   Collection of records to be deleted
      #
      # @return [Integer]
      #   The number of records deleted
      #
      # @api semipublic
      def delete(resources)
        with_collection(resources.query.model) do |collection|
          resources.each do |resource|
            collection.remove(key(resource))
          end.size
        end
      end

      private

      # Retrieves the key for a given resource as a hash.
      #
      # @param [Resource] resource
      #   The resource whose key is to be retrieved
      #
      # @return [Hash{Symbol => Object}]
      #   Returns a hash where each hash key/value corresponds to a key name
      #   and value on the resource.
      #
      # @api private
      def key(resource)
        resource.model.key(name).map{ |key| [key.field, key.value(resource.__send__(key.name))] }.to_hash
      end

      # Retrieves all of a records attributes and returns them as a Hash.
      #
      # The resulting hash can then be used with the Mongo library for
      # inserting new -- and updating existing -- documents in the database.
      #
      # @param [Resource, Hash] record
      #   A DataMapper resource, or a hash containing fields and values.
      #
      # @return [Hash]
      #   Returns a hash containing the values for each of the fields in the
      #   given resource as raw (dumped) values suitable for use with the
      #   Mongo library.
      #
      # @todo split this into separate methods
      #
      # @api private
      def attributes_as_fields(record)
        attributes = {}

        case record
          when DataMapper::Resource
            model = record.model

            model.properties.each do |property|
              name = property.name
              if model.public_method_defined?(name)
                attributes[property.field] = record.__send__(name)
              end
            end

            if model.respond_to?(:embedments)
              model.embedments.each do |name, embedment|
                value = record.__send__(name)
                if embedment.kind_of?(Embedments::OneToMany::Relationship)
                  attributes[name] = value.map{ |resource| resource.attributes(:field) }
                elsif value
                  attributes[name] = attributes_as_fields(value)
                end
              end
            end
          when Hash
            if record.keys.any? { |k| k.kind_of?(Embedments::Relationship) }
              record.each do |key, value|
                case key
                when DataMapper::Property
                  attributes[key.field] = value.is_a?(Class) ? value.to_s : value
                when Embedments::Relationship
                  attributes[key.name] = super(value)
                end
              end
            else
              attributes = super(record)
            end
          end

        # TODO: make this prettier and off on its own method
        attributes.each do |k, v|
          case v
            when Class    then attributes[k] = v.to_s
            when DateTime then attributes[k] = v.to_time
            when Date     then attributes[k] = Time.utc(v.year, v.month, v.day)
          end
          attributes[k] = ::Mongo::ObjectID.from_string(v) if v.is_a?(String) && !k.grep(/_id$/).empty? && k != "_id"
        end

        attributes.except('_id')
      end

      # Runs the given block within the context of a Mongo collection.
      #
      # @param [Model] model
      #   The model whose collection is to be scoped.
      #
      # @yieldparam [Mongo::Collection]
      #   The Mongo::Collection instance for the given model
      #
      # @api private
      def with_collection(model)
        begin
          yield database.collection(model.storage_name(name))
        rescue Exception => exception
          DataMapper.logger.error(exception.to_s)
          raise exception
        end
      end

      # Returns the Mongo::DB instance for this process.
      #
      # @return [Mongo::DB]
      #
      # @api semipublic
      def database
        @database ||= connection.db(@options[:database])
      end

      # Returns the Mongo::Connection instance for this process
      #
      # @todo Reconnect if the connection has timed out, or if the process has
      #       been forked.
      #
      # @return [Mongo::Connection]
      #
      # @api semipublic
      def connection
        @connection ||= ::Mongo::Connection.new(*@options.values_at(:host, :port))
      end
    end # Adapter
  end # Mongo

  Adapters::MongoAdapter = DataMapper::Mongo::Adapter
  Adapters.const_added(:MongoAdapter)
end # DataMapper
