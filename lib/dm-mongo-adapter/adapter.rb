module DataMapper
  module Mongo
    class Adapter < DataMapper::Adapters::AbstractAdapter
      def create(resources)
        resources.map do |resource|
          with_connection(resource.model) do |connection|
            connection.insert(resource.attributes(:field).to_mash.symbolize_keys)
          end
        end.size
      end

      def read(query)
        with_connection(query.model) do |connection|
          Query.new(connection, query).read
        end
      end

      def update(attributes, collection)
        with_connection(collection.query.model) do |connection|
          collection.each do |resource|
            connection.update(key(resource), resource.attributes(:field).merge(attributes_as_fields(attributes)))
          end.size
        end
      end

      def delete(collection)
        with_connection(collection.query.model) do |connection|
          collection.each do |resource|
            connection.remove(key(resource))
          end.size
        end
      end

      private
        def key(resource)
          resource.model.key(name).map(&:field).zip(resource.key).to_mash.symbolize_keys
        end

        def attributes_as_fields(attributes)
          super.to_mash.symbolize_keys
        end

        # TODO: document
        # @api private
        def with_connection(model)
          begin
            connection = open_connection
            yield connection.collection(model.storage_name(name))
          rescue Exception => exception
            DataMapper.logger.error(exception.to_s)
            raise exception
          ensure
            close_connection(connection) if connection
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

