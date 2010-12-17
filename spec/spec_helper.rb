Bundler.require(:default, :development)
require 'rspec'
require 'lib/immortal'
require 'active_record'
require 'sqlite3'

RSpec.configure do |config|
  config.before(:each) do
    ActiveRecord::Base.connection.execute('delete from immortal_models')
  end

  config.after(:all) do
  end
end


ActiveRecord::Base.establish_connection(:adapter => "sqlite3", :database => ":memory:")

old_stdout = $stdout
$stdout = StringIO.new

begin
  ActiveRecord::Schema.define do
    create_table :immortal_models do |t|
      t.string :title
      t.integer :value
      t.boolean :deleted, :default => false
      t.timestamps
    end
  end
ensure
  $stdout = old_stdout
end

class ImmortalModel < ActiveRecord::Base
  include Immortal

  attr_accessor :before_d, :after_d, :before_u, :after_u

  before_destroy   :set_before
  after_destroy    :set_after
  before_update    :set_before_update
  after_update     :set_after_update

  private
  def set_before
    @before_d = true
  end

  def set_after
    @after_d = true
  end

  def set_after_update
    @after_u = true
  end

  def set_before_update
    @before_u = true
  end

end
