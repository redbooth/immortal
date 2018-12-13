require 'immortal/belongs_to'

# Include +Immortal+ module to activate soft delete on your model.
module Immortal
  COLUMN_NAME = 'deleted'.freeze

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
      where_clause = (current_scope || unscoped).where_values_hash.except(COLUMN_NAME)

      unscoped.where(where_clause).scoping do
        yield
      end
    end

    def exists?(id = false)
      mortal.exists?(id)
    end

    def count_with_deleted(*args)
      without_default_scope do
        count(*args)
      end
    end

    def count_only_deleted(*args)
      without_default_scope do
        immortal.count(*args)
      end
    end

    def where_with_deleted(conditions)
      without_default_scope do
        where(conditions)
      end
    end

    def where_only_deleted(conditions)
      without_default_scope do
        immortal.where(conditions)
      end
    end

    def immortal_delete_all(conditions = nil)
      unscoped.where(conditions).update_all(COLUMN_NAME => 1)
    end

    def delete_all!(*args)
      unscoped.mortal_delete_all(*args)
    end

    def undeleted_clause_sql
      unscoped.mortal.constraints.first.to_sql
    end

    def deleted_clause_sql
      unscoped.where(arel_table[COLUMN_NAME].eq(true)).constraints.first.to_sql
    end
  end

  module InstanceMethods
    def self.included(base)
      unless base.table_exists? && base.columns_hash[COLUMN_NAME] && !base.columns_hash[COLUMN_NAME].null
        Kernel.warn(
          "[Immortal] The '#{COLUMN_NAME}' column in #{base} is nullable, " \
          'change the column to not accept NULL values'
        )
      end

      base.class_eval do
        scope(:mortal, -> { where(COLUMN_NAME => false) })
        scope(:immortal, -> { where(COLUMN_NAME => true) })

        default_scope { -> { mortal } } if arel_table[COLUMN_NAME]

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
      scoped_record.update_all(
        COLUMN_NAME => true,
        updated_at: current_time_from_proper_timezone
      )

      @destroyed = true
      reload
      freeze
    end

    def recover!
      scoped_record.update_all(
        COLUMN_NAME => false,
        updated_at: current_time_from_proper_timezone
      )

      @destroyed = false
      reload
    end

    private

    # @return [ActiveRecord::Relation]
    def scoped_record
      self.class.unscoped.where(id: id)
    end

    def current_time_from_proper_timezone
      ActiveRecord::Base.default_timezone == :utc ? Time.now.utc : Time.current
    end
  end
end
