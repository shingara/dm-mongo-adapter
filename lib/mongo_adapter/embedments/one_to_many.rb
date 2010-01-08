module DataMapper
  module Mongo
    module Embedments
      module OneToMany
        class Relationship < Embedments::Relationship
          # @api semipublic
          def get(source, other_query = nil)
            assert_kind_of 'source', source, source_model

            unless loaded?(source)
              set!(source, collection_for(source, other_query))
            end

            get!(source)
          end

          # @api semipublic
          def set(source, targets, loading=false)
            assert_kind_of 'source',  source,  source_model
            assert_kind_of 'targets', targets, Array

            targets = targets.map{|t| t.kind_of?(Hash) ? load_target(source, t) : t.parent = source}

            set_original_attributes(source, targets) unless loading

            unless loaded?(source)
              set!(source, collection_for(source))
            end

            get!(source).replace(targets)
          end

          private

          # @api private
          def collection_for(source, other_query=nil)
            Collection.new(source)
          end
        end

        class Collection < Array
          attr_reader :source

          def initialize(source)
            @source = source
          end

          def <<(resource)
            resource.parent = source
            super(resource)
          end
        end
      end
    end
  end
end
