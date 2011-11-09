module Immortal
  module SingularAssociation
    attr_reader :without_deleted_target, :only_deleted_target

    def without_deleted_reader(force_reload = false)
      reader_without_deleted(force_reload)
    end

    def only_deleted_reader(force_reload = false)
      reader_only_deleted(force_reload)
    end

    private

      def reset_without_deleted
        @without_deleted_loaded = false
        ActiveRecord::IdentityMap.remove(without_deleted_target) if ActiveRecord::IdentityMap.enabled? && without_deleted_target
        @without_deleted_target = nil
      end

      def reset_only_deleted
        @only_deleted_loaded = false
        ActiveRecord::IdentityMap.remove(only_deleted_target) if ActiveRecord::IdentityMap.enabled? && only_deleted_target
        @only_deleted_target = nil
      end

      def without_deleted_loaded!
        @without_deleted_loaded      = true
        @without_deleted_stale_state = stale_state
      end

      def only_deleted_loaded!
        @only_deleted_loaded      = true
        @only_deleted_stale_state = stale_state
      end

      def without_deleted_loaded?
        @without_deleted_loaded
      end

      def only_deleted_loaded?
        @only_deleted_loaded
      end

      def stale_without_deleted_target?
        without_deleted_loaded? && @without_deleted_stale_state != stale_state
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

      def reload_without_deleted
        reset_without_deleted
        reset_scope
        load_without_deleted_target
        self unless without_deleted_target.nil?
      end

      def find_without_deleted_target?
        !without_deleted_loaded? && (!owner.new_record? || foreign_key_present?) && klass
      end

      def find_only_deleted_target?
        !only_deleted_loaded? && (!owner.new_record? || foreign_key_present?) && klass
      end

      def load_without_deleted_target
        if find_without_deleted_target?
          begin
            if ActiveRecord::IdentityMap.enabled? && association_class && association_class.respond_to?(:base_class)
              @without_deleted_target = ActiveRecord::IdentityMap.get(association_class, owner[reflection.foreign_key])
            end
          rescue NameError
            nil
          ensure
            @without_deleted_target ||= find_without_deleted_target
          end
        end
        without_deleted_loaded! unless without_deleted_loaded?
        without_deleted_target
      rescue ActiveRecord::RecordNotFound
        without_deleted_reset
      end

      def load_only_deleted_target
        if find_only_deleted_target?
          begin
            if ActiveRecord::IdentityMap.enabled? && association_class && association_class.respond_to?(:base_class)
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

      def reader_without_deleted(force_reload = false)
        if force_reload
          klass.uncached { reload_without_deleted } if klass
        elsif !without_deleted_loaded? || stale_without_deleted_target?
          reload_without_deleted
        end

        without_deleted_target
      end

      def reader_only_deleted(force_reload = false)

        if force_reload
          klass.uncached { reload_only_deleted } if klass
        elsif !only_deleted_loaded? || stale_only_deleted_target?
          reload_only_deleted
        end

        only_deleted_target
      end

      def find_without_deleted_target
        return nil unless klass
        scoped.where(klass.arel_table[:deleted].eq(nil).or(klass.arel_table[:deleted].eq(false))).first.tap { |record| set_inverse_instance(record) }
      end

      def find_only_deleted_target
        return nil unless klass
        scoped.where(:deleted => true).first.tap { |record| set_inverse_instance(record) }
      end

  end
end
