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

    module ClassMethods

      def counter_cache(*args, &block)
        options       = args.extract_options!
        name          = options[:class] || args.first.to_s
        version       = (Mongoid::VERSION.to_i >= 4) ? true : false
        counter_name  = get_counter_name(options, version)
        condition     = options[:if]

        callback_proc = ->(doc, inc) do
          result = condition_result(condition, doc)
          return unless result
          if doc.embedded?
            parent = doc._parent
            if parent.respond_to?(counter_name)
              increment_association(parent, counter_name.to_sym, inc, version)
            end
          else
            relation = doc.send(name)
            if relation && relation.class.fields.keys.include?(counter_name)
              increment_association(relation, counter_name.to_sym, inc, version)
            end
          end
        end

        after_create( ->(doc) { callback_proc.call(doc,  1) })
        after_destroy(->(doc) { callback_proc.call(doc, -1) })

      end

      alias :magic_counter_cache :counter_cache

      private

      def get_counter_name(options, version)
        return "#{options[:field].to_s}" if options[:field]
        "#{actual_model_name(version).demodulize.underscore}_count"
      end

      def actual_model_name(version)
        return model_name.name if version
        model_name
      end

      def condition_result(condition, doc)
        return true if condition.nil?
        condition.call(doc)
      end

      def increment_association(association, counter_name, inc, version)
        association.inc(counter_name => inc) if version
        association.inc(counter_name, inc)
      end
    end
  end
end
