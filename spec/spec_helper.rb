Bundler.require(:default, :development)
require 'rspec'
require File.expand_path("../../lib/immortal", __FILE__)
require 'active_record'
require 'sqlite3'
require 'logger'

RSpec.configure do |config|
  config.before(:each) do
    ActiveRecord::Base.connection.execute('delete from immortal_models')
  end

  config.after(:all) do
  end
end


ActiveRecord::Base.establish_connection(:adapter => "sqlite3", :database => ":memory:")
ActiveRecord::Base.logger = Logger.new(STDOUT) if ENV['DEBUG']

old_stdout = $stdout
$stdout = StringIO.new

begin
  ActiveRecord::Schema.define do
    create_table :immortal_models do |t|
      t.string :title
      t.integer :value
      t.boolean :deleted, :default => false, :null => false
      t.timestamps
    end
    create_table :immortal_joins do |t|
      t.integer :immortal_model_id
      t.integer :immortal_node_id
      t.boolean :deleted, :default => false, :null => false
      t.timestamps
    end
    create_table :immortal_nodes do |t|
      t.integer :target_id
      t.string :target_type
      t.string :title
      t.integer :value
      t.boolean :deleted, :default => false, :null => false
      t.timestamps
    end

    create_table :immortal_some_targets do |t|
      t.string :title
      t.boolean :deleted, :default => false, :null => false
      t.timestamps
    end

    create_table :immortal_some_other_targets do |t|
      t.string :title
      t.boolean :deleted, :default => false, :null => false
      t.timestamps
    end

    create_table :immortal_nullable_deleteds do |t|
      t.string :title
      t.boolean :deleted, :default => false
      t.timestamps
    end
  end
ensure
  $stdout = old_stdout
end

class ImmortalJoin < ActiveRecord::Base
  include Immortal

  belongs_to :immortal_model
  belongs_to :immortal_node, :dependent => :destroy
end

class ImmortalNode < ActiveRecord::Base
  include Immortal

  has_many :immortal_joins
  has_many :immortal_models, :through => :immortal_joins

  has_many :joins, :class_name => 'ImmortalJoin'
  has_many :models, :through => :joins, :source => :immortal_model

  belongs_to :target, :polymorphic => true
end

class ImmortalSomeTarget < ActiveRecord::Base
  include Immortal

  has_many :immortal_nodes, :as => :target
end

class ImmortalSomeOtherTarget < ActiveRecord::Base
  include Immortal

  has_many :immortal_nodes, :as => :target
end


class ImmortalModel < ActiveRecord::Base
  include Immortal

  has_many :immortal_nodes, :through => :immortal_joins, :dependent => :destroy
  has_many :immortal_joins, :dependent => :delete_all

  has_many :joins, :class_name => 'ImmortalJoin', :dependent => :delete_all
  has_many :nodes, :through => :joins, :source => :immortal_node, :dependent => :destroy

  attr_accessor :before_d, :after_d, :before_u, :after_u, :after_c, :after_commit, :before_return

  before_destroy   :set_before
  after_destroy    :set_after
  after_create     :set_after_create
  before_update    :set_before_update
  after_update     :set_after_update
  after_commit     :set_after_commit, on: :destroy

  private

  def set_before
    @before_d = true
    @before_return
  end

  def set_after
    @after_d = true
  end

  def set_after_update
    @after_u = true
  end

  def set_after_commit
    @after_commit = true
  end

  def set_before_update
    @before_u = true
  end

  def set_after_create
    @after_c = true
  end
end

class ImmortalNullableDeleted < ActiveRecord::Base
end

