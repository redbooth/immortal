require 'active_record'
require 'immortal/singular_association'

module Immortal
  class BelongsToBuilder < ::ActiveRecord::Associations::Builder::BelongsTo

    def self.define_accessors(mixin, reflection)
      super
      define_deletables(mixin, reflection.name)
    end

    private

      def self.define_deletables(mixin, name)
        define_with_deleted_reader(mixin, name)
        define_only_deleted_reader(mixin, name)
      end

      def self.define_with_deleted_reader(model, name)
        model.redefine_method("#{name}_with_deleted") do |*params|
          assoc = association(name)
          assoc.send(:extend, SingularAssociation)
          assoc.with_deleted_reader(*params)
        end
      end

      def self.define_only_deleted_reader(model, name)
        model.redefine_method("#{name}_only_deleted") do |*params|
          assoc = association(name)
          assoc.send(:extend, SingularAssociation)
          assoc.only_deleted_reader(*params)
        end
      end
  end
end

