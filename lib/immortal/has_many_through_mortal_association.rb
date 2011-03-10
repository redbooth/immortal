require 'active_record'

module Immortal

  class HasManyThroughMortalAssociation < ActiveRecord::Associations::HasManyThroughAssociation
    protected

      def construct_conditions
        klass = @reflection.through_reflection.klass
        return super unless klass.respond_to?(:immortal?) && klass.immortal?
        table_name = @reflection.through_reflection.quoted_table_name
        conditions = construct_quoted_owner_attributes(@reflection.through_reflection).map do |attr, value|
          "#{table_name}.#{attr} = #{value}"
        end

        deleted_conditions = ["#{table_name}.deleted IS NULL OR #{table_name}.deleted = ?", false]
        conditions << klass.send(:sanitize_sql, deleted_conditions)
        conditions << sql_conditions if sql_conditions
        "(" + conditions.join(') AND (') + ")"
      end
  end

end
