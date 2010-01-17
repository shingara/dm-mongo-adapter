module DataMapper
  module Migrations
    module SingletonMethods
      private
      
      def repository_execute(method, repository_name)
        DataMapper::Model.descendants.each do |model|
          model.send(method, repository_name || model.default_repository_name) unless model == DataMapper::Mongo::EmbeddedResource
        end
      end
    end
  end

  module Model
    def properties_with_subclasses(repository_name = default_repository_name)
      puts "properties_with_subclasses #{repository_name}"
        properties = PropertySet.new
 
        descendants.each do |model|
          model.properties(repository_name).each do |property|
            properties[property.name] ||= property
          end
        end
 
        properties
      end
  end

  module Mongo
    module Migrations
      def self.included(base)  
        DataMapper.extend(DataMapper::Migrations::SingletonMethods)
 
        [ :Repository, :Model ].each do |name|
          DataMapper.const_get(name).send(:include, DataMapper::Migrations.const_get(name))
        end
      end

      def storage_exists?(storage_name)
        puts "storage exists"
        database.collections.map(&:name).include?(storage_name)
      end

      def create_model_storage(model)
        puts "create model storage"
        name       = model.name.to_sym
        properties = model.properties_with_subclasses(name)

        return false if storage_exists?(model.storage_name(name))
        return false if properties.empty?
        puts "create before"
        p database.collections.map(&:name)
        database.create_collection(model.storage_name(name))
        p database.collections.map(&:name)
        puts "create after"
      end

      def upgrade_model_storage(model)
        puts "upgrade"
        name       = self.name
        properties = model.properties_with_subclasses(name)
 
        if success = create_model_storage(model)
          return properties
        end

        
      end

      def destroy_model_storage(model)
        puts "destroy #{model.storage_name(name).inspect}"
        p database.collections.map(&:name)
        database.drop_collection(model.storage_name(name))
        p database.collections.map(&:name)
        puts "destroyed"
      end

     end
  end
end

DataMapper::Mongo.send(:include, DataMapper::Mongo::Migrations)
