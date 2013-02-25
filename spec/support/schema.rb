ActiveRecord::Schema.define do
  create_table :immortal_models do |t|
    t.string :title
    t.integer :value
    t.boolean :deleted, :default => false
    t.timestamps
  end

  create_table :immortal_joins do |t|
    t.integer :immortal_model_id
    t.integer :immortal_node_id
    t.boolean :deleted, :default => false
    t.timestamps
  end

  create_table :immortal_nodes do |t|
    t.integer :target_id
    t.string :target_type
    t.string :title
    t.integer :value
    t.boolean :deleted, :default => false
    t.timestamps
  end

  create_table :immortal_some_targets do |t|
    t.string :title
    t.boolean :deleted, :default => false
    t.timestamps
  end

  create_table :immortal_some_other_targets do |t|
    t.string :title
    t.boolean :deleted, :default => false
    t.timestamps
  end
end