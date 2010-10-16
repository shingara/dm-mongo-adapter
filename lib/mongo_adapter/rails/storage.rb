module Rails
  module DataMapper
    class Storage
      class Mongo < Storage
        def _create
          # noop
        end

        def _drop
          # noop
        end
      end
    end
  end
end
