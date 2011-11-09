require 'active_record/identity_map'

module Immortal
  module Relation

    def self.included(base)
      base.class_eval do
        alias_method_chain :delete_all, :immortal
      end
    end

    def delete_all_with_immortal(conditions = nil)
      ActiveRecord::IdentityMap.repository[symbolized_base_class] = {} if ActiveRecord::IdentityMap.enabled?
      if conditions
        where(conditions).delete_all
      else
        # This method is called in various places e.g
        # both by AR::Base#destroy and by AR::CollectionAssociation#delete_or_destroy
        # which handles deletion of dependant collections.
        #
        # In the latter case, when this method is called the
        # association has already been marked as deleted.
        # 
        # Without this code (and without the previous immortal default_scope)
        # the default behaviour was to delete the records directly via the db.
        # 
        # When we had the immortal default_scope,
        # load_target (a sub method used AR::CollectionAssociation#delete) would
        # not load the associations to be deleted as they were already marked as
        # deleted and thus filtered out by the default scope.
        #
        # So we have to filter AR::Relation.delete_all by only non-deleted records.
        #
        # The perhaps unwanted side-effect of this is
        # you can NEVER #delete_all #destroy any records that have been
        # marked as deleted. I don't see this as a huge issue though.
        #
        # In the former case, the initial implementation of this method was:
        #
        #     update_all({:deleted => true})
        #
        # which is not what AR::Base#destroy is expected to do so hence
        # this code.
        statement = self.where(arel_table[:deleted].eq(nil).or(arel_table[:deleted].eq(false))).arel.compile_delete
        affected = @klass.connection.delete(statement, 'SQL', bind_values)

        reset
        affected
      end
    end

  end
end
