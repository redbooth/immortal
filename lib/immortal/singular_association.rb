module Immortal
  module SingularAssociation
    attr_reader :deleted_target

    def with_deleted_reader(force_reload = false)
      deleted_reader('with', force_reload)
    end

    def only_deleted_reader(force_reload = false)
      deleted_reader('only', force_reload)
    end

    private

        def deleted_reader(how, force_reload = false)
          klass.uncached do
            send(:"reload_#{how}_deleted")
          end

          deleted_target
        end

        def reload_with_deleted
          reset
          reset_scope
          load_deleted_target('with')
          self unless deleted_target.nil?
        end

        def reload_only_deleted
          reset
          reset_scope
          load_deleted_target('only')
          self unless deleted_target.nil?
        end

        def find_with_deleted_target
          klass.unscoped do
            scoped.first.tap { |record| set_inverse_instance(record) }
          end
        end

        def find_only_deleted_target
          klass.unscoped do
            scoped.where(:deleted => true).first.tap { |record| set_inverse_instance(record) }
          end
        end

        def load_deleted_target(how)
          @deleted_target ||= send(:"find_#{how}_deleted_target")
          deleted_target
        rescue ActiveRecord::RecordNotFound
          reset
        end

  end
end
