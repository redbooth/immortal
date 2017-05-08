require 'active_record'
require 'sqlite3'
require 'logger'

RSpec.configure do |config|
  config.before(:each) do
    ActiveRecord::Base.connection.execute('delete from immortal_models')
  end
end

ActiveRecord::Base
  .establish_connection(adapter: 'sqlite3', database: ':memory:')
ActiveRecord::Base.logger = Logger.new(STDOUT) if ENV['DEBUG']

old_stdout = $stdout
$stdout = StringIO.new

begin
  ActiveRecord::Schema.define do
    create_table :immortal_models do |t|
      t.string :title
      t.integer :value
      t.boolean :deleted, default: false, null: false
      t.timestamps
    end

    create_table :immortal_joins do |t|
      t.integer :immortal_model_id
      t.integer :immortal_node_id
      t.boolean :deleted, default: false, null: false
      t.timestamps
    end

    create_table :immortal_nodes do |t|
      t.integer :target_id
      t.string :target_type
      t.string :title
      t.integer :value
      t.boolean :deleted, default: false, null: false
      t.timestamps
    end

    create_table :immortal_some_targets do |t|
      t.string :title
      t.boolean :deleted, default: false, null: false
      t.timestamps
    end

    create_table :immortal_some_other_targets do |t|
      t.string :title
      t.boolean :deleted, default: false, null: false
      t.timestamps
    end

    create_table :immortal_nullable_deleteds do |t|
      t.string :title
      t.boolean :deleted, default: false
      t.timestamps
    end
  end
ensure
  $stdout = old_stdout
end


