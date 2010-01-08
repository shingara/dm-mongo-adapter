module DataMapper
  module Mongo
    class Adapter < DataMapper::Adapters::AbstractAdapter
      def create(resources)
        resources.map do |resource|
          with_collection(resource.model) do |collection|
            resource.model.key.set(resource, [collection.insert(attributes_as_fields(resource))])
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
        resource.model.key(name).map{ |key| [key.field, key.value(resource.__send__(key.name))] }.to_hash
      end

      # TODO: split this into separate methods
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

      # TODO: document
      # @api private
      def with_collection(model)
        begin
          with_db { |db| yield db.collection(model.storage_name(name)) }
        rescue Exception => exception
          DataMapper.logger.error(exception.to_s)
          raise exception
        end
      end

      # TODO: document
      # @api private
      def with_db
        begin
          connection = open_connection
          yield connection.db(@options[:database]) # TODO: :pk => @options[:pk]
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
        connection = connection_stack.last || ::Mongo::Connection.new(*@options.values_at(:host, :port))
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
