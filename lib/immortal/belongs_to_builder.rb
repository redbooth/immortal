require 'active_record'
require 'immortal/singular_association'

module Immortal
  class BelongsToBuilder < ::ActiveRecord::Associations::Builder::BelongsTo
    def self.define_accessors(mixin, reflection)
      super
      define_deletables(mixin, reflection)
    end

    private

    def self.define_deletables(mixin, reflection)
      define_with_deleted_reader(mixin, reflection)
      define_only_deleted_reader(mixin, reflection)
    end

    def self.define_with_deleted_reader(mixin, reflection)
      mixin.redefine_method("#{reflection.name}_with_deleted") do |*params|
        assoc = association(reflection.name)
        assoc.send(:extend, SingularAssociation)
        assoc.with_deleted_reader(*params)
      end
    end

    def self.define_only_deleted_reader(mixin, reflection)
      mixin.redefine_method("#{reflection.name}_only_deleted") do |*params|
        assoc = association(reflection.name)
        assoc.send(:extend, SingularAssociation)
        assoc.only_deleted_reader(*params)
      end
    end
  end
end
