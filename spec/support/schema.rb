require 'active_record'
require 'logger'

if ENV['CONFIG_MYSQL']
  require 'mysql2'

  db_host = ENV.fetch('DB_HOST', 'localhost')
  db_user = ENV.fetch('DB_USERNAME', 'root')
  db_pass = ENV.fetch('DB_PASSWORD', '')
  db_name = ENV.fetch('DB_NAME', 'immortal_test')
  db_port = ENV['DB_PORT']

  client = Mysql2::Client.new(host: db_host, username: db_user, password: db_pass, port: db_port)
  client.query("DROP DATABASE IF EXISTS #{db_name}")
  client.query("CREATE DATABASE #{db_name}")

  if db_port.nil?
    ActiveRecord::Base.establish_connection(adapter: 'mysql2', database: db_name)
  else
    ActiveRecord::Base.establish_connection(
      adapter: 'mysql2',
      database: db_name,
      host: db_host,
      username: db_user,
      password: db_pass,
      port: db_port
    )
  end
else
  require 'sqlite3'

  ActiveRecord::Base.establish_connection(adapter: 'sqlite3', database: ':memory:')
end

RSpec.configure do |config|
  config.before(:each) { ActiveRecord::Base.connection.execute('delete from immortal_models') }
  if ENV['CONFIG_MYSQL']
    config.after(:suite) { client.close }
  end
end

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
