module Immortal
  # Mixin to provide the singular association readers for +_only_deleted+ and
  # +_with_deleted+.
  module SingularAssociation
    attr_reader :with_deleted_target, :only_deleted_target

    def with_deleted_reader(force_reload = false)
      reader_with_deleted(force_reload)
    end

    def only_deleted_reader(force_reload = false)
      reader_only_deleted(force_reload)
    end

    private

    attr_reader :with_deleted_loaded, :only_deleted_loaded
    alias with_deleted_loaded? with_deleted_loaded
    alias only_deleted_loaded? only_deleted_loaded

    def reset_with_deleted
      @with_deleted_loaded = false
      @with_deleted_target = nil
    end

    def reset_only_deleted
      @only_deleted_loaded = false
      @only_deleted_target = nil
    end

    def with_deleted_loaded!
      @with_deleted_loaded      = true
      @with_deleted_stale_state = stale_state
    end

    def only_deleted_loaded!
      @only_deleted_loaded      = true
      @only_deleted_stale_state = stale_state
    end

    def stale_with_deleted_target?
      with_deleted_loaded? && @with_deleted_stale_state != stale_state
    end

    def stale_only_deleted_target?
      only_deleted_loaded? && @only_deleted_stale_state != stale_state
    end

    def reload_only_deleted
      reset_only_deleted
      reset_scope
      load_only_deleted_target
      self if only_deleted_target
    end

    def reload_with_deleted
      reset_with_deleted
      reset_scope
      load_with_deleted_target
      self if with_deleted_target
    end

    def find_with_deleted_target?
      !with_deleted_loaded? &&
        (!owner.new_record? || foreign_key_present?) &&
        klass
    end

    def find_only_deleted_target?
      !only_deleted_loaded? &&
        (!owner.new_record? || foreign_key_present?) &&
        klass
    end

    def load_with_deleted_target
      if find_with_deleted_target?
        @with_deleted_target ||= find_with_deleted_target
      end

      with_deleted_loaded! unless with_deleted_loaded?
      with_deleted_target
    rescue ActiveRecord::RecordNotFound
      with_deleted_reset
    end

    def load_only_deleted_target
      if find_only_deleted_target?
        @only_deleted_target ||= find_only_deleted_target
      end

      only_deleted_loaded! unless only_deleted_loaded?
      only_deleted_target
    rescue ActiveRecord::RecordNotFound
      only_deleted_reset
    end

    def reader_with_deleted(force_reload = false)
      if force_reload
        klass.uncached { reload_with_deleted } if klass
      elsif !with_deleted_loaded? || stale_with_deleted_target?
        reload_with_deleted
      end

      with_deleted_target
    end

    def reader_only_deleted(force_reload = false)
      if force_reload
        klass.uncached { reload_only_deleted } if klass
      elsif !only_deleted_loaded? || stale_only_deleted_target?
        reload_only_deleted
      end

      only_deleted_target
    end

    def find_with_deleted_target
      return nil unless klass
      klass.unscoped do
        scope.first.tap { |record| set_inverse_instance(record) }
      end
    end

    def find_only_deleted_target
      return nil unless klass
      klass.unscoped do
        scope.where(deleted: true).first.tap do |record|
          set_inverse_instance(record)
        end
      end
    end
  end
end
