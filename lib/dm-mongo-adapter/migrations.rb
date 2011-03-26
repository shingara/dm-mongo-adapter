require 'dm-migrations/auto_migration'

module DataMapper
  module Mongo
    module Migrations
      def storage_exists?(storage_name)
        database.collections.map(&:name).include?(storage_name)
      end

      def create_model_storage(model)
        return false if storage_exists?(model.storage_name)
        database.create_collection(model.storage_name)
      end

      def upgrade_model_storage(model)
        create_model_storage(model)
      end

      def destroy_model_storage(model)
        database.drop_collection(model.storage_name)
      end

      module Model
        def auto_migrate!(repository_name = self.repository_name)
          adapter = repository(repository_name).adapter

          return unless adapter.kind_of?(Mongo::Adapter)

          adapter.destroy_model_storage(self)
          adapter.create_model_storage(self)
        end

        def auto_upgrade!(repository_name = self.repository_name)
          # noop
        end
      end
    end
  end
end
