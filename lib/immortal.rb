module Immortal
  def self.included(base)
    base.send :extend, ClassMethods
    base.send :include, InstanceMethods
    base.class_eval do
      class << self
        alias :mortal_delete_all :delete_all
        alias :delete_all :immortal_delete_all
      end
    end
  end

  module ClassMethods

    def with_deleted
      unscoped
    end

    def only_deleted
      unscoped.where(:deleted => true)
    end

    def count_with_deleted(*args)
      with_deleted.count(*args)
    end

    def count_only_deleted(*args)
      only_deleted.count(*args)
    end

    def find_with_deleted(*args)
      with_deleted.find(*args)
    end

    def find_only_deleted(*args)
      only_deleted.find(*args)
    end

    def immortal_delete_all(*args)
      unscoped.update_all :deleted => true
    end

    def delete_all!(*args)
      unscoped.mortal_delete_all
    end

    # In has_many :through => join_model we have to explicitly add
    # the 'not deleted' scope, otherwise it will take all the rows
    # from the join model
    def has_many(association_id, options = {}, &extension)
      if options.key?(:through)
        conditions = "#{options[:through].to_s.pluralize}.deleted IS NULL OR #{options[:through].to_s.pluralize}.deleted = ?"
        options[:conditions] = ["(" + [options[:conditions], conditions].compact.join(") AND (") + ")", false]
      end
      super
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

    def immortal_destroy(*args)
      run_callbacks :destroy do
        destroy_without_callbacks(*args)
      end
    end

    def destroy!(*args)
      mortal_destroy
    end

    def destroy_without_callbacks(*args)
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
