module DataMapper
  module Mongo
    class Query
      # TODO: document
      module JavaScript
        class Operation
          attr_reader :initial

          # TODO: document
          # @api semipublic
          def initialize(fields)
            @initial = {}
            @reduce  = Reduce.new(fields)

            if @reduce.operations.values.include?(:avg)
              @finalize = Finalize.new(fields.select{ |field| field.operator == :avg })
            end

            fields.each do |field|
              field_name = field.target.name

              @initial[field_name] = 0

              if field.operator == :avg
                @initial["#{field_name}_count"] = 0
              end
            end
          end

          # TODO: document
          # @api semipublic
          def reduce
            @reduce.create
          end

          # TODO: document
          # @api semipublic
          def finalize
            @finalize ? @finalize.create : nil
          end
        end

        class Function
          attr_reader :operations

          # TODO: document
          # @api semipublic
          def initialize(fields)
            @operations = {}

            fields.each do |field|
              @operations[field.target.name] = field.operator
            end
          end

          # TODO: document
          # @api semipublic
          def create(*args, &block)
            @function ||= "function(#{args.join(', ')}) { #{yield.flatten.join(';')} }"
          end
        end

        class Reduce < Function
          # TODO: document
          # @api semipublic
          def create
            super('doc', 'out') do
              @operations.map do |field, operation|
                send(operation, field)
              end
            end
          end

          private

          # TODO: document
          # @api private
          def count(field)
            "out.#{field}++"
          end

          # TODO: document
          # @api private
          def min(field)
            <<-JS
              if (doc.#{field} < doc.#{field} || out.#{field} == 0) {
                out.#{field} = doc.#{field};
              }
            JS
          end

          # TODO: document
          # @api private
          def max(field)
            <<-JS
              if (doc.#{field} > out.#{field}) {
                out.#{field} = doc.#{field};
              }
            JS
          end

          # TODO: document
          # @api private
          def sum(field)
            <<-JS
              out.#{field} += doc.#{field}
            JS
          end

          # TODO: document
          # @api private
          def avg(field)
            [sum(field), count("#{field}_count")]
          end
        end

        class Finalize < Function
          # TODO: document
          # @api semipublic
          def create
            super('out') do
              @operations.map do |field, operation|
                send(operation, field)
              end
            end
          end

          private

          # TODO: document
          # @api private
          def avg(field)
            "out.#{field} = out.#{field} / out.#{field}_count"
          end
        end
      end # JavaScript
    end # Query
  end # Mongo
end # DataMapper