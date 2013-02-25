ActiveRecord::Schema.define do
  create_table :immortal_models do |t|
    t.string :title
    t.integer :value
    t.boolean :deleted, default: false
    t.timestamps
  end

  create_table :immortal_joins do |t|
    t.belongs_to :immortal_model
    t.belongs_to :immortal_node
    t.boolean :deleted, default: false
    t.timestamps
  end

  create_table :immortal_nodes do |t|
    t.belongs_to :target, polymorphic: true
    t.belongs_to :immortal_model
    t.string :title
    t.integer :value
    t.boolean :deleted, default: false
    t.timestamps
  end

  create_table :immortal_some_targets do |t|
    t.string :title
    t.boolean :deleted, default: false
    t.timestamps
  end

  create_table :immortal_some_other_targets do |t|
    t.string :title
    t.boolean :deleted, default: false
    t.timestamps
  end
end