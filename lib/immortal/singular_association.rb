module Immortal
  module SingularAssociation

    def with_deleted_reader(force_reload = false)
      deleted_reader('with', force_reload)
    end

    def only_deleted_reader(force_reload = false)
      deleted_reader('only', force_reload)
    end

    private

        def deleted_reader(how, force_reload = false)
          reset
          reset_scope

          klass.uncached do
            send(:"find_#{how}_deleted_target")
          end
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

  end
end
