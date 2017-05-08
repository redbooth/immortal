require 'immortal/belongs_to'

module Immortal
  def self.included(base)
    base.send :extend, ClassMethods
    base.send :include, InstanceMethods
    base.send :include, BelongsTo
    base.class_eval do
      class << self
        alias_method :mortal_delete_all, :delete_all
        alias_method :delete_all, :immortal_delete_all
      end
    end
  end

  module ClassMethods
    # @return [Boolean] whether the model supports immortal or not
    def immortal?
      included_modules.include?(::Immortal::InstanceMethods)
    end

    def without_default_scope
      new_scope = unscoped
      our_scope = current_scope || unscoped

      non_immortal_constraints_sql = our_scope.arel.constraints.to_a.map do |constraint|
        constraint.to_sql.split('AND').reject { |clause| clause.include?('deleted') }
      end.flatten.join(' AND ')

      new_scope = new_scope.merge(our_scope.except(:where))
      new_scope = new_scope.where(non_immortal_constraints_sql)

      unscoped
        .merge(new_scope)
        .scoping do
        yield
      end
    end

    def exists?(id = false)
      where(deleted: false).exists?(id)
    end

    def count_with_deleted(*args)
      without_default_scope do
        count(*args)
      end
    end

    def count_only_deleted(*args)
      without_default_scope do
        where(deleted: true).count(*args)
      end
    end

    def where_with_deleted(conditions)
      without_default_scope do
        where(conditions)
      end
    end

    def find_with_deleted(*args)
      ActiveSupport::Deprecation.warn('[immortal] we are deprecating #find_with_deleted use where_with_deleted instead')
      without_default_scope do
        find(*args)
      end
    end

    def where_only_deleted(conditions)
      without_default_scope do
        where(deleted: true).where(conditions)
      end
    end

    def find_only_deleted(*args)
      ActiveSupport::Deprecation.warn('[immortal] we are deprecating #find_only_deleted use where_only_deleted instead')
      without_default_scope do
        where(deleted: true).find(*args)
      end
    end

    def immortal_delete_all(conditions = nil)
      unscoped.where(conditions).update_all(deleted: 1)
    end

    def delete_all!(*args)
      unscoped.mortal_delete_all(*args)
    end

    def undeleted_clause_sql
      unscoped.where(deleted: false).constraints.first.to_sql
    end

    def deleted_clause_sql
      unscoped.where(arel_table[:deleted].eq(true)).constraints.first.to_sql
    end
  end

  module InstanceMethods
    def self.included(base)
      unless base.table_exists? && base.columns_hash['deleted'] && !base.columns_hash['deleted'].null
        Kernel.warn "[Immortal] The 'deleted' column in #{base} is nullable, change the column to not accept NULL values"
      end

      base.class_eval do
        default_scope { -> { where(deleted: false) } } if arel_table[:deleted]

        alias_method :mortal_destroy, :destroy
        alias_method :destroy, :immortal_destroy
      end
    end

    def immortal_destroy
      with_transaction_returning_status do
        run_callbacks :destroy do
          destroy_without_callbacks
        end
      end
    end

    def destroy!
      mortal_destroy
    end

    def destroy_without_callbacks
      self.class.unscoped.where(id: id).update_all(deleted: true, updated_at: current_time_from_proper_timezone)
      @destroyed = true
      reload
      freeze
    end

    def recover!
      self.class.unscoped.where(id: id).update_all(deleted: false, updated_at: current_time_from_proper_timezone)
      @destroyed = false
      reload
    end

    private

    def current_time_from_proper_timezone
      ActiveRecord::Base.default_timezone == :utc ? Time.now.utc : Time.now
    end
  end
end
