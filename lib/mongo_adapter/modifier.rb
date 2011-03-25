module DataMapper
  module Mongo
    module Modifier
      ##
      # Increment the property with a value define. By default an increment is
      # only by one
      #
      # @params[String] property the property you want increment
      # @params[Integer] value the value you want increment. This params is
      #   optional and define by 1 in default value
      #
      # @return[Boolean]
      #   if the increment success or not
      #
      # @api public
      def increment(property, value=1)
        attribute_set(property, attribute_get(property) + value)

        if modifier(:inc, property => value)
          self.persisted_state.original_attributes.clear
        end
      end

      ##
      # Decrement the property with a value define. By default a decrement is
      # only by one
      #
      # @params[String] property the property you want decrement
      # @params[Integer] value the value you want decrement. This params is
      #   optional and define by 1 in default value
      #
      # @return[Boolean]
      #   if the decrement success or not
      # @api public
      def decrement(property, value=1)
        increment(property, -value)
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
