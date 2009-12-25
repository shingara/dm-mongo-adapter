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
            target = load_target(source, target) if target.kind_of?(Hash)
            target.parent ||= source

            set!(source, target)
          end
        end
      end
    end
  end
end