require 'immortal/belongs_to'

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

    def without_default_scope
      new_scope = self.unscoped
      our_scope = self.current_scope || self.unscoped

      non_immortal_constraints = our_scope.arel.constraints.select do |constraint|
        !constraint.to_sql.include?('deleted')
      end

      non_immortal_constraints_sql = non_immortal_constraints.to_a.map do |constraint|
        constraint.to_sql
      end.join(' AND ')

      new_scope = new_scope.merge(our_scope.except(:where))
      new_scope = new_scope.where(non_immortal_constraints_sql)

      unscoped do
        with_scope(new_scope) do
          yield
        end
      end
    end

    def exists?(id = false)
      where(:deleted => false).exists?(id)
    end

    def count_with_deleted(*args)
      without_default_scope do
        count(*args)
      end
    end

    def count_only_deleted(*args)
      without_default_scope do
        where(:deleted => true).count(*args)
      end
    end

    def find_with_deleted(*args)
      without_default_scope do
        find(*args)
      end
    end

    def find_only_deleted(*args)
      without_default_scope do
        where(:deleted => true).find(*args)
      end
    end

    def immortal_delete_all(conditions = nil)
      unscoped.update_all({:deleted => true}, conditions)
    end

    def delete_all!(*args)
      unscoped.mortal_delete_all(*args)
    end

    def undeleted_clause_sql
      unscoped.where(arel_table[:deleted].eq(nil).or(arel_table[:deleted].eq(false))).constraints.first.to_sql
    end

    def deleted_clause_sql
      unscoped.where(arel_table[:deleted].eq(true)).constraints.first.to_sql
    end

  end

  module InstanceMethods
    def self.included(base)
      base.class_eval do
        default_scope where(arel_table[:deleted].eq(nil).or(arel_table[:deleted].eq(false))) if arel_table[:deleted]
        alias :mortal_destroy :destroy
        alias :destroy :immortal_destroy
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
      self.class.unscoped.update_all({ :deleted => true }, "id = #{self.id}")
      reload
      freeze
    end

    def recover!
      self.class.unscoped.update_all({ :deleted => false }, "id = #{self.id}")
      reload
    end

  end
end
