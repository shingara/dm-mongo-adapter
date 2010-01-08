module DataMapper
  module Model
    module Embedment
      include DataMapper::Mongo
      include DataMapper::Model::Relationship

      extend Chainable

      # @api private
      def self.extended(model)
        model.instance_variable_set(:@embedments, {})
      end

      chainable do
        # @api private
        def inherited(model)
          model.instance_variable_set(:@embedments, {})

          @embedments.each { |name, embedment| model.embedments[name] ||= embedment }

          super
        end
      end

      # @api public
      def embedments
        @embedments ||= {}
      end

      # @api public
      def embeds(cardinality, name, *args)
        assert_kind_of 'cardinality', cardinality, Integer, Range, Infinity.class
        assert_kind_of 'name',        name,        Symbol

        model   = extract_model(args)
        options = extract_options(args)

        min, max = extract_min_max(cardinality)
        options.update(:min => min, :max => max)

        assert_valid_options(options)

        if options.key?(:model) && model
          raise ArgumentError, 'should not specify options[:model] if passing the model in the third argument'
        end

        model ||= options.delete(:model) || Object.const_get(Extlib::Inflection.classify(name.to_s.singular))

        klass = if max > 1
          Embedments::OneToMany::Relationship
        else
          Embedments::OneToOne::Relationship
        end

        embedment = embedments[name] = klass.new(name, model, self, options)

        descendants.each do |descendant|
          descendant.embedments[name] ||= embedment
        end

        create_embedment_reader(embedment)
        create_embedment_writer(embedment)

        embedment
      end

      # @api public
      def embedded_in(name, *args)
        assert_kind_of 'name', name, Symbol


      end

      # @api private
      def create_embedment_reader(embedment)
        name        = embedment.name
        reader_name = name.to_s

        return if resource_method_defined?(reader_name)

        reader_visibility = embedment.reader_visibility

        class_eval <<-RUBY, __FILE__, __LINE__ + 1
          #{reader_visibility}                               # public
          def #{reader_name}(query = nil)                    # def author(query = nil)
            embedments[#{name.inspect}].get(self, query)     #   embedment[:author].get(self, query)
          end                                                # end
        RUBY
      end

      # @api private
      def create_embedment_writer(embedment)
        name        = embedment.name
        writer_name = "#{name}="

        return if resource_method_defined?(writer_name)

        writer_visibility = embedment.writer_visibility

        class_eval <<-RUBY, __FILE__, __LINE__ + 1
          #{writer_visibility}                                # public
          def #{writer_name}(target)                          # def author=(target)
            embedments[#{name.inspect}].set(self, target)      #   embedment[:author].set(self, target)
          end                                                 # end
        RUBY
      end
    end

    Model.append_extensions(Embedment)
  end
end
