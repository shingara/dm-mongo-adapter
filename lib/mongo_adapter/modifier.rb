module DataMapper
  module Mongo
    module Modifier
      # TODO: document
      # @api public
      def increment(property, value)
        attribute_set(property, attribute_get(property) + value)

        if modifier(:inc, property => value)
          original_attributes.clear
        end
      end

      # TODO: document
      # @api public
      def decrement(property, value)
        attribute_set(property, attribute_get(property) - value)

        if modifier(:inc, property => -value.abs)
          original_attributes.clear
        end
      end

      # TODO: document
      # @api public
      def set(args)
        modifier(:set, args)

        args.keys.each do |key|
          attribute_set(key, args[key])
        end
      end

      # TODO: document
      # @api public
      def unset(*args)
        new_args = {}

        args.each do |arg|
          new_args[arg] = 1
        end

        modifier(:unset, new_args)
      end

      # TODO: document
      # @api public
      def push

      end

      # TODO: document
      # @api public
      def push_all

      end

      # TODO: document
      # @api public
      def pop

      end

      # TODO: document
      # @api public
      def pull

      end

      # TODO: document
      # @api public
      def pull_all

      end

      private

      # TODO: document
      # @api private
      def modifier(operation, properties)
        repository.adapter.execute([self], "$#{operation}" => properties)
      end
    end
  end
end
