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

  attr_accessor :before_d, :after_d, :before_u, :after_u

  before_destroy :set_before
  after_destroy :set_after
  before_update :set_before_update
  after_update :set_after_update

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