require 'immortal/belongs_to'
require 'immortal/relation'

ActiveRecord::Relation.send(:include, Immortal::Relation)

module Immortal

  def self.included(base)
    base.send :extend, ClassMethods
    base.send :include, InstanceMethods
    base.send :include, BelongsTo
    base.class_eval do
      class << self

        # In has_many :through => join_model we have to explicitly add
        # the 'not deleted' scope, otherwise it will take all the rows
        # from the join model
        def has_many_mortal(association_id, options = {}, &extension)
          has_many_immortal(association_id, options, &extension).tap do
            # FIXME This must be re-implemented after the ActiveRecord internals refactor in 3.1
          end
        end

        alias_method :has_many_immortal, :has_many
        alias_method :has_many, :has_many_mortal

        alias :mortal_delete_all :delete_all
        alias :delete_all :immortal_delete_all
      end
    end
  end

  module ClassMethods

    def immortal?
      self.included_modules.include?(::Immortal::InstanceMethods)
    end

    def exists?(id = false)
      where(:deleted => false).exists?(id)
    end

    def count_only_deleted(*args)
      where(:deleted => true).count(*args)
    end

    def find_only_deleted(*args)
      where(:deleted => true).find(*args)
    end

    def immortal_delete_all(conditions = nil)
      update_all({:deleted => 1}, conditions)
    end

    def delete_all!(*args)
      mortal_delete_all(*args)
    end

    def undeleted_clause_sql
      where(arel_table[:deleted].eq(nil).or(arel_table[:deleted].eq(false))).constraints.first.to_sql
    end

    def deleted_clause_sql
      where(arel_table[:deleted].eq(true)).constraints.first.to_sql
    end

  end

  module InstanceMethods
    def self.included(base)
      base.class_eval do
        # create a scope out of this and use that explicitly
        scope :without_deleted, where(arel_table[:deleted].eq(nil).or(arel_table[:deleted].eq(false))) if arel_table[:deleted]
        scope :only_deleted, where(:deleted => true) if arel_table[:deleted]

        alias :mortal_destroy :destroy
        alias :destroy :immortal_destroy

        # on association and class object.
        # :delete :delete_all, :destroy, :destroy_all
      end
    end

    def immortal_destroy
      run_callbacks :destroy do
        destroy_without_callbacks
      end
    end

    def destroy!
      mortal_destroy
    end

    def destroy_without_callbacks
      self.class.update_all({ :deleted => true }, "id = #{self.id}")
      reload
      freeze
    end

    def recover!
      self.class.update_all({ :deleted => false }, "id = #{self.id}")
      reload
    end

  end
end
