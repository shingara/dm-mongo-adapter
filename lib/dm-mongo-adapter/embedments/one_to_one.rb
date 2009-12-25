module DataMapper
  module Mongo
    module Embedments
      module OneToOne
        class Relationship < Embedments::Relationship
          # @api semipublic
          def get(source, other_query = nil)
            get!(source)
          end

          # @api semipublic
          def set(source, target)
            target = load_target(target) if target.kind_of?(Hash)

            set!(source, target)
            
            target.parent = source
          end
        end
      end
    end
  end
end