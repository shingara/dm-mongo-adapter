module DataMapper
  module Mongo
    module Types
      class Discriminator < DataMapper::Types::Discriminator
        primitive String
        default   lambda { |resource, property| resource.model.to_s }
        
        def self.load(value, property)
          typecast(value, property)
        end

        def self.dump(value, property)
          value.name
        end

        def self.typecast(value, property)
          if value
            if value.is_a?(String)
              value.constantize
            else
              value
            end
          end
        end

        def self.==(other)
          other == DataMapper::Types::Discriminator || super
        end
      end
    end
  end
end
