require 'bundler/setup'
require 'rspec'
require 'active_record'
require 'sqlite3'
require 'logger'

require File.expand_path("../../lib/immortal", __FILE__)

connection_opts = case ENV.fetch('DB', "sqlite")
                    when "sqlite"
                      {adapter: "sqlite3", database: ":memory:"}
                    when "mysql"
                      {adapter: "mysql2", database: "immortal", username: "root", encoding: "utf8"}
                    when "postgres"
                      {adapter: "postgresql", database: "immortal", username: "postgres"}
                  end

ActiveRecord::Base.establish_connection(connection_opts)

ActiveRecord::Base.logger = Logger.new(STDOUT) if ENV['DEBUG']
silence_stream(STDOUT) { require 'support/schema' }

require 'support/models'

RSpec.configure do |config|
  config.before { ActiveRecord::Base.connection.execute('DELETE FROM immortal_models') }
end
