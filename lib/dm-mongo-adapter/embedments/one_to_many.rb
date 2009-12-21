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
          def set(source, targets)
            assert_kind_of 'source',  source,  source_model
            assert_kind_of 'targets', targets, Array

            unless loaded?(source)
              set!(source, collection_for(source))
            end

            targets = targets.map { |t| target_model.new(t) if t.kind_of?(Hash) }
            targets.each { |t| t.parent = source }

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