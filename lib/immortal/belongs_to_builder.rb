require 'active_record'
require 'immortal/singular_association'

module Immortal
  class BelongsToBuilder < ::ActiveRecord::Associations::Builder::BelongsTo

    def define_accessors
      super
      define_deletables
    end

    private

      def define_deletables
        define_without_deleted_reader
        define_only_deleted_reader
      end

      def define_without_deleted_reader
        name = self.name

        model.redefine_method("#{name}_without_deleted") do |*params|
          assoc = association(name)
          assoc.send(:extend, SingularAssociation)
          assoc.without_deleted_reader(*params)
        end
      end

      def define_only_deleted_reader
        name = self.name

        model.redefine_method("#{name}_only_deleted") do |*params|

          assoc = association(name)
          assoc.send(:extend, SingularAssociation)
          assoc.only_deleted_reader(*params)
        end
      end

      module InstanceMethods

      end #InstanceMethods

  end
end

