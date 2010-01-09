module DataMapper
  module Mongo
    module Modifier
      def increment(property, value)
        modifier(:inc, {property => value})
        attribute_set(property, attribute_get(property) + value)
      end

      def decrement(property, value)
        modifier(:inc, {property => -value.abs})
        attribute_set(property, attribute_get(property) - value)
      end

      def set(args)
        modifier(:set, args)
        args.keys.each do |key|
          attribute_set(key, args[key])
        end
      end

      def unset(*args)
        new_args = {}
        args.each do |arg|
          new_args[arg] = 1
        end

        modifier(:unset, new_args)
      end

      def push
      end

      def push_all
      end

      def pop
      end

      def pull
      end

      def pull_all
      end

      def modifier(operation, properties)
        operation = :pushAll if operation == :push_all
        operation = :pullAll if operation == :pull_all
        
        operation = "$#{operation}"
        document = {operation => properties}

        repository.adapter.execute([self], {:_id => ::Mongo::ObjectID.from_string(self.id)}, document)
      end
    end
  end
end

DataMapper::Resource.send(:include, DataMapper::Mongo::Modifier)
