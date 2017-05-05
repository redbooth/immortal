module Immortal
  module SingularAssociation
    attr_reader :with_deleted_target, :only_deleted_target

    def with_deleted_reader(force_reload = false)
      reader_with_deleted(force_reload)
    end

    def only_deleted_reader(force_reload = false)
      reader_only_deleted(force_reload)
    end

    private

    def supports_indetity_map?
      defined?(ActiveRecord::IdentityMap) && ActiveRecord::IdentityMap.enabled?
    end

    def reset_with_deleted
      @with_deleted_loaded = false
      ActiveRecord::IdentityMap.remove(with_deleted_target) if supports_indetity_map? && with_deleted_target
      @with_deleted_target = nil
    end

    def reset_only_deleted
      @only_deleted_loaded = false
      ActiveRecord::IdentityMap.remove(only_deleted_target) if supports_indetity_map? && only_deleted_target
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

    def with_deleted_loaded?
      @with_deleted_loaded
    end

    def only_deleted_loaded?
      @only_deleted_loaded
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
      self unless only_deleted_target.nil?
    end

    def reload_with_deleted
      reset_with_deleted
      reset_scope
      load_with_deleted_target
      self unless with_deleted_target.nil?
    end

    def find_with_deleted_target?
      !with_deleted_loaded? && (!owner.new_record? || foreign_key_present?) && klass
    end

    def find_only_deleted_target?
      !only_deleted_loaded? && (!owner.new_record? || foreign_key_present?) && klass
    end

    def load_with_deleted_target
      if find_with_deleted_target?
        begin
          if supports_indetity_map? && association_class && association_class.respond_to?(:base_class)
            @with_deleted_target = ActiveRecord::IdentityMap.get(association_class, owner[reflection.foreign_key])
          end
        rescue NameError
          nil
        ensure
          @with_deleted_target ||= find_with_deleted_target
        end
      end
      with_deleted_loaded! unless with_deleted_loaded?
      with_deleted_target
    rescue ActiveRecord::RecordNotFound
      with_deleted_reset
    end

    def load_only_deleted_target
      if find_only_deleted_target?
        begin
          if supports_indetity_map? && association_class && association_class.respond_to?(:base_class)
            @only_deleted_target = ActiveRecord::IdentityMap.get(association_class, owner[reflection.foreign_key])
          end
        rescue NameError
          nil
        ensure
          @only_deleted_target ||= find_only_deleted_target
        end
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
        scope.where(deleted: true).first.tap { |record| set_inverse_instance(record) }
      end
    end
  end
end
