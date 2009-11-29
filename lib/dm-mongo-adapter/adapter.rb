module DataMapper
  module Mongo
    class Adapter < DataMapper::Adapters::AbstractAdapter
      def create(resources)
        resources.map do |resource|
          with_collection(resource.model) do |collection|
            resource.model.key.set!(resource, [collection.insert(attributes_as_fields(resource))])
          end
        end.size
      end

      def read(query)
        with_collection(query.model) do |collection|
          Query.new(collection, query).read
        end
      end

      def update(attributes, resources)
        with_collection(resources.query.model) do |collection|
          resources.each do |resource|
            collection.update(key(resource), 
              attributes_as_fields(resource).merge(attributes_as_fields(attributes)))
          end.size
        end
      end

      def delete(resources)
        with_collection(resources.query.model) do |collection|
          resources.each do |resource|
            collection.remove(key(resource))
          end.size
        end
      end

      private
      
      def key(resource)
        resource.model.key(name).map(&:field).zip(resource.key).to_hash
      end

      def attributes_as_fields(record)
        return super(record) unless record.is_a?(DataMapper::Resource)

        attributes = {}
        
        record.model.properties.each do |property|
          name = property.name
          if record.model.public_method_defined?(name)
            attributes[property.field] = record.__send__(name)
          end
        end

        if record.respond_to?(:embedments)
          record.embedments.keys.each do |name|
            if record.model.public_method_defined?(name)
              attributes[name] = attributes_as_fields(record.__send__(name))
            end
          end
        end

        attributes.except('_id')
      end

      # TODO: document
      # @api private
      def with_connection
        begin
          yield connection = open_connection
        rescue Exception => exception
          DataMapper.logger.error(exception.to_s)
          raise exception
        ensure
          close_connection(connection) if connection
        end
      end

      # TODO: document
      # @api private
      def with_collection(model)
        begin
          with_connection do |connection|
            yield connection.collection(model.storage_name(name))
          end
        rescue Exception => exception
          DataMapper.logger.error(exception.to_s)
          raise exception
        end
      end

      # TODO: document
      # @api private
      def open_connection
        connection = connection_stack.last || ::Mongo::Connection.new(
          *@options.values_at(:host, :port)).db(@options.fetch(:path, @options[:database])) # TODO: :pk => @options[:pk]
        connection_stack << connection
        connection
      end

      # TODO: document
      # @api private
      def close_connection(connection)
        connection_stack.pop
        connection.close if connection_stack.empty?
      end

      # TODO: document
      # @api private
      def connection_stack
        connection_stack_for = Thread.current[:dm_mongo_connection_stack] ||= {}
        connection_stack_for[self] ||= []
      end
    end # Adapter
  end # Mongo

  Adapters::MongoAdapter = DataMapper::Mongo::Adapter
  Adapters.const_added(:MongoAdapter)
end # DataMapper

