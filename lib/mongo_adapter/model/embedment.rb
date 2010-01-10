module DataMapper
  module Mongo
    module Model
      # Embedment extends Mongo-based resources to allow resources to be
      # embedded within a document, while providing relationship-like `has 1`
      # and `has n` functionality.
      #
      # @example
      #   class User
      #     include DataMapper::Mongo::Resource
      #
      #     property :id,   ObjectID
      #     property :name, String
      #
      #     embeds n, :addresses, :model => Address
      #   end
      #
      #   class Address
      #     include DataMapper::Mongo::EmbeddedResource
      #
      #     property :street,    String
      #     property :post_code, String
      #   end
      #
      module Embedment
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

        # Returns the embedments on this model
        #
        # @return [Hash]
        #   Embedments on this model, where each hash key is the embedment
        #   name, and each value is the Embedments::Relationship instance.
        #
        # @api semipublic
        def embedments
          @embedments ||= {}
        end

        # A short-hand, clear syntax for defining one-to-one and one-to-many
        # embedments -- where an embedded resource is held within the parent
        # document in the database.
        #
        # @example
        #   embed 1,    :friend         # one friend
        #   embed n,    :friends        # many friends
        #   embed 1..3, :friends        # many friends (at least 1, at most 3)
        #   embed 3,    :friends        # many friends (exactly 3)
        #   embed 1,    :friend, 'User' # one friend with the class User
        #
        # @param cardinality [Integer, Range, Infinity]
        #   Cardinality that defines the embedment type and constraints
        # @param name [Symbol]
        #   The name that the embedment will be referenced by
        # @param model [Model, #to_str]
        #   The target model of the embedment
        # @param opts [Hash]
        #   An options hash
        #
        # @option :model[Model, String] The name of the class to associate
        #   with, if omitted then the model class name is assumed to match the
        #   (optional) third parameter, or the embedment name.
        #
        # @return [Embedment::Relationship]
        #   The embedment that was created to reflect either a one-to-one or
        #   one-to-many embedment.
        #
        # @raise [ArgumentError]
        #   If the cardinality was not understood. Should be a Integer, Range
        #   or Infinity(n)
        #
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

        # @todo Investigate as a candidate for removal.
        #   Added 26ae98e1 as an equivelent of belongs_to but _probably_ isn't
        #   of much use in embedded resources (since it would be perfectly
        #   acceptable for an embedment to be used in multiple models). My
        #   opinion is that embedments should always be declared from the
        #   parent side (DM::M::Resource), rather the child side
        #   (DM::M::EmbeddedResource).
        #
        #   ~antw
        #
        # @api public
        def embedded_in(name, *args)
          return NotImplementedError
        end

        # Dynamically defines a reader method
        #
        # Creates a public method matching the name of the embedment which can
        # be used to access the embedded resource(s).
        #
        # @param [Embedment::Relationship] embedment
        #   The embedment for which a reader should be created
        #
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

        # Dynamically defines a writer method
        #
        # Creates a public method matching the name of the embedment which can
        # be used to set the embedded resource(s).
        #
        # @param [Embedment::Relationship] embedment
        #   The embedment for which a writer should be created
        #
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

    end # Model
  end # Mongo
end # DataMapper
