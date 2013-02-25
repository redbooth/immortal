require 'bundler/setup'
require 'rspec'
require 'active_record'
require 'sqlite3'
require 'logger'

require File.expand_path("../../lib/immortal", __FILE__)

ActiveRecord::Base.establish_connection(:adapter => "sqlite3", :database => ":memory:")
ActiveRecord::Base.logger = Logger.new(STDOUT) if ENV['DEBUG']
silence_stream(STDOUT) { require 'support/schema' }

require 'support/models'

RSpec.configure do |config|
  config.before { ActiveRecord::Base.connection.execute('DELETE FROM immortal_models') }
end
