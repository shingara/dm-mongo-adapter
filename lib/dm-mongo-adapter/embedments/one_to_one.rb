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
          def set(source, target, loading=false)
            target.kind_of?(Hash) ? target = load_target(source, target, loading) : target.parent = source

            set_original_attributes(source, target) unless loading

            set!(source, target)
          end
        end
      end
    end
  end
end