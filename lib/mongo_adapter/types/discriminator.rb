module DataMapper
  class PropertySet
    def discriminator
      @discriminator ||= detect { |property| property.type == Mongo::Types::Discriminator }
    end
  end

  module Mongo
    module Types
      class Discriminator < DataMapper::Type
        primitive Class
        default   lambda { |resource, property| resource.model }
        required  true

        def self.dump(value, property)
          puts "DUMP #{value}"
          return nil unless value
          value.name
        end
  
        def self.load(value, property)
          puts "LOAD #{value}"
          value.name
        end

        def self.typecast(value, property)
          value
        end

        def self.bind(property)
          repository_name = property.repository_name
          model           = property.model

          #puts property.repository_name.inspect
          #puts property.model.inspect
          #puts model.descendants.inspect
          #puts property.name

          model.default_scope(repository_name).update(property.name => model.descendants)

          model.class_eval <<-RUBY, __FILE__, __LINE__ + 1
            extend Chainable

            extendable do
              def inherited(model)
                super  # setup self.descendants
                set_discriminator_scope_for(model)
              end

              def new(*args, &block)
                if args.size == 1 && args.first.kind_of?(Hash)
                  discriminator = properties(repository_name).discriminator
                  model         = discriminator.typecast(args.first[discriminator.name])
 
                  if model.kind_of?(Model) && !model.equal?(self)
                    return model.new(*args, &block)
                  end
                end
 
                super
              end
              
              private
 
              def set_discriminator_scope_for(model)
                model.default_scope(#{repository_name.inspect}).update(#{property.name.inspect} => model.descendants)
              end
            end
          RUBY
        end
      end
    end
  end
end
