require 'active_record'
require 'immortal/singular_association'

module Immortal
  # Builds a +belongs_to+ association with +_with_deleted+ and +_only_deleted+
  # readers.
  class BelongsToBuilder < ::ActiveRecord::Associations::Builder::BelongsTo
    def self.define_accessors(mixin, reflection)
      super
      define_deletables(mixin, reflection)
    end

    def self.define_deletables(mixin, reflection)
      define_with_deleted_reader(mixin, reflection)
      define_only_deleted_reader(mixin, reflection)
    end
    private_class_method :define_deletables

    def self.define_with_deleted_reader(mixin, reflection)
      name = reflection.name

      mixin.redefine_method("#{name}_with_deleted") do |*params|
        assoc = association(name)
        assoc.send(:extend, SingularAssociation)
        assoc.with_deleted_reader(*params)
      end
    end
    private_class_method :define_with_deleted_reader

    def self.define_only_deleted_reader(mixin, reflection)
      name = reflection.name

      mixin.redefine_method("#{name}_only_deleted") do |*params|
        assoc = association(name)
        assoc.send(:extend, SingularAssociation)
        assoc.only_deleted_reader(*params)
      end
    end
    private_class_method :define_only_deleted_reader
  end
end
