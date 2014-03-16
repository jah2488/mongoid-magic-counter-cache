require 'mongoid'
require 'mongoid/version'
module Mongoid #:nodoc:
  # The Counter Cache will yada yada
  #
  #    class Person
  #      include Mongoid::Document
  #
  #      field :name
  #      field :feeling_count
  #      has_many :feelings
  #    end
  #
  #    class Feeling
  #      include Mongoid::Document
  #      include Mongoid::MagicCounterCache
  #
  #      field :name
  #      belongs_to    :person
  #      counter_cache :person
  #    end
  #
  # Alternative Syntax
  #
  #    class Person
  #      include Mongoid::Document
  #
  #      field :name
  #      field :all_my_feels
  #      has_many :feelings
  #    end
  #
  #    class Feeling
  #      include Mongoid::Document
  #      include Mongoid::MagicCounterCache
  #
  #      field :name
  #      belongs_to    :person
  #      counter_cache :person, :field => "all_my_feels"
  #    end
  module MagicCounterCache
    extend ActiveSupport::Concern

    module LegacyCache
      def actual_model_name
        model_name
      end

      def increment_association(association, counter_name, inc)
        association.inc(counter_name, inc)
      end
    end

    module ModernCache
      def actual_model_name
        model_name.name
      end

      def increment_association(association, counter_name, inc)
        association.inc(counter_name => inc)
      end
    end

    module ClassMethods
      include (Mongoid::VERSION.to_i >= 4) ? ModernCache : LegacyCache

      def counter_cache(*args, &block)
        options       = args.extract_options!
        name          = options[:class] || args.first.to_s
        counter_name  = get_counter_name(options)
        condition     = options[:if]
        update_condition = options[:if_update]

        callback_proc = ->(doc, inc) do
          result = condition_result(condition, doc)
          return unless result
          if doc.embedded?
            parent = doc._parent
            if parent.respond_to?(counter_name)
              increment_association(parent, counter_name.to_sym, inc)
            end
          else
            relation = doc.send(name)
            if relation && relation.class.fields.keys.include?(counter_name)
              increment_association(relation, counter_name.to_sym, inc)
            end
          end
        end

        update_callback_proc = ->(doc) do
          return if condition.nil?
          return if update_condition.nil? # Don't execute if there is no update condition.
          return unless update_condition.call(doc) # Determine whether to execute update increment/decrements.

          inc = condition.call(doc) ? 1 : -1

          if doc.embedded?
            parent = doc._parent
            if parent.respond_to?(counter_name)
              increment_association(parent, counter_name.to_sym, inc)
            end
          else
            relation = doc.send(name)
            if relation && relation.class.fields.keys.include?(counter_name)
              increment_association(relation, counter_name.to_sym, inc)
            end
          end
        end

        after_create( ->(doc) { callback_proc.call(doc,  1) })
        after_destroy(->(doc) { callback_proc.call(doc, -1) })
        after_update( ->(doc) { update_callback_proc.call(doc) })

      end

      alias :magic_counter_cache :counter_cache

      private

      def get_counter_name(options)
        options.fetch(:field, "#{actual_model_name.demodulize.underscore}_count").to_s
      end

      def condition_result(condition, doc)
        return true if condition.nil?
        condition.call(doc)
      end
    end
  end
end
