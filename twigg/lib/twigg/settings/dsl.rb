require 'ostruct'

module Twigg
  class Settings
    module DSL
      # Hash subclass used as a book-keeping detail, which allows us to
      # differentiate settings hashes from hashes used to construct namespaces.
      class Namespace < Hash; end

      module ClassMethods
        attr_reader :overrides

      private

        def namespaces
          @namespaces ||= []
        end

        # DSL method for declaring settings underneath a namespace.
        #
        # Example:
        #
        #   namespace :app do
        #     setting :bind, default: '0.0.0.0'
        #   end
        #
        def namespace(scope, &block)
          namespaces.push scope
          yield
        ensure
          namespaces.pop
        end

        # DSL method which is used to create a reader for the setting `name`. If
        # the configuration file does not contain a value for the setting, return
        # `options[:default]` from the `options` hash.
        #
        # A block maybe provided to do checking of the supplied value prior to
        # returning; for an example, see the `repositories_directory` setting in
        # this file.
        #
        # Note that this method doesn't actually create any readers; it merely
        # records data about default values and validation which are then used at
        # initialization time to override the readers provided by OpenStruct
        # itself.
        def setting(name, options = {}, &block)
          options.merge!(block: block)
          @overrides ||= {}

          overrides = namespaces.inject(@overrides) do |overrides, namespace|
            overrides[namespace] ||= Namespace.new
          end

          overrides[name] = options
        end
      end

      module InstanceMethods
      private

        def initialize(hash = nil)
          super
          deep_open_structify!(self)
          override_methods!(self, self.class.overrides)
        end

        # Recursively replace nested hash values with OpenStructs.
        #
        # This enables us to make nice calls like `Config.foo.bar` instead of
        # the somewhat unsightly `Config.foo[:bar]`.
        def deep_open_structify!(instance)
          # call `to_a` here to avoid mutating the collection during iteration
          instance.each_pair.to_a.each do |key, value|
            if value.is_a?(Hash)
              deep_open_structify!(instance.[]=(key, OpenStruct.new(value)))
            end
          end
        end

        # Recurses through the `overrides` hash, overriding OpenStruct-supplied
        # methods with ones which handle defaults, perform validation, and memoize
        # their results.
        #
        # The `overrides` hash itself is built up using the DSL as this class file
        # is passed. This method is called at runtime, once the YAML file containing
        # the configuration has been loaded from disk.
        def override_methods!(instance, overrides, namespace = nil)
          return unless overrides

          overrides.each do |name, options|
            if options.is_a?(Namespace)
              process_namespace(instance, namespace, name, options) # recurses
            else
              define_getter(instance, namespace, name, options)
            end
          end
        end

        # Sets up the given `namespace` on `instance`, if not already set up,
        # and (recursively) calls {#override_methods!} to set up `name`.
        def process_namespace(instance, namespace, name, options)
          nested = instance.[](name)

          unless nested.is_a?(OpenStruct)
            instance.[]=(name, nested = OpenStruct.new)
          end

          override_methods!(nested, options, name)
        end

        # Defines a getter on the `instance` for setting `name` within
        # `namespace`.
        #
        # The getter:
        #
        #   - memoizes its result
        #   - raises an ArgumentError if the option is required by not
        #     configured
        #   - supplies a default value if the option is not configured and a
        #     default setting is available
        #   - optionally calls a supplied block to perform validation of the
        #     configured value
        #
        def define_getter(instance, namespace, name, options)
          instance.define_singleton_method name do
            value = instance_variable_get("@#{namespace}__#{name}")
            return value if value

            if options[:required] &&
              !instance.each_pair.to_a.map(&:first).include?(name)
              raise ArgumentError, "#{name} not set"
            end

            value = instance.[](name) || options[:default]

            options[:block].call(name, value) if options[:block]

            instance_variable_set("@#{namespace}__#{name}", value)
          end
        end
      end
    end
  end
end
