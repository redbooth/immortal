class ImmortalModel < ActiveRecord::Base
  include Immortal

  has_many :immortal_nodes, through: :immortal_joins, dependent: :destroy
  has_many :immortal_joins, dependent: :delete_all

  has_many :joins, class_name: 'ImmortalJoin', dependent: :delete_all
  has_many :nodes, through: :joins, source: :immortal_node, dependent: :destroy

  attr_reader :before_destroy_probe, :after_destroy_probe,
    :before_update_probe, :after_update_probe, :after_commit_probe

  attr_accessor :before_return

  before_destroy   :set_before_destroy
  after_destroy    :set_after_destroy
  before_update    :set_before_update
  after_update     :set_after_update
  after_commit     :set_after_commit, on: :destroy

  private

  def set_before_destroy
    @before_destroy_probe = true
    before_return if defined?(@before_return)
  end

  def set_after_destroy
    @after_destroy_probe = true
  end

  def set_after_update
    @after_update_probe = true
  end

  def set_after_commit
    @after_commit_probe = true
  end

  def set_before_update
    @before_update_probe = true
  end
end
