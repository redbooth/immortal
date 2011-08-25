module Immortal

  def self.included(base)
    base.send :extend, ClassMethods
    base.send :include, InstanceMethods
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

    def with_deleted
      except(:where).where(filter_undeleted_where_clauses.join(' AND '))
    end

    def only_deleted
      deleted_clause = arel_table[:deleted].eq(true)
      where_sql_clauses = filter_undeleted_where_clauses
      where_sql_clauses.concat unscoped.where(deleted_clause).wheres.collect(&:value)

      except(:where).where(where_sql_clauses.join(" AND "))
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

    def immortal_delete_all(conditions = nil)
      unscoped.update_all({:deleted => 1}, conditions)
    end

    def delete_all!(*args)
      unscoped.mortal_delete_all(*args)
    end

    def undeleted_clause_sql
      unscoped.where(arel_table[:deleted].eq(nil).or(arel_table[:deleted].eq(false))).where_clauses.first
    end

    def deleted_clause_sql
      unscoped.where(arel_table[:deleted].eq(true)).where_clauses.first
    end

    private

    def filter_undeleted_where_clauses
      where_clauses = scoped.arel.wheres.collect(&:value)

      #Yes it's an ugly hack but I couldn't find a cleaner way of doing this
      filtered_clauses = where_clauses.dup.map do |clause| 
        clause.gsub(/(\s+AND\s+)?\("?`?(\w+)`?"?."?`?deleted`?"?\sIS\sNULL[^\)]+\)/, '')
      end.map {|cl| cl.gsub("()", '')}.select {|cl| !cl.empty?}

      filtered_clauses
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
