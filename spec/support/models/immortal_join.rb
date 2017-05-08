class ImmortalJoin < ActiveRecord::Base
  include Immortal

  belongs_to :immortal_model
  belongs_to :immortal_node, dependent: :destroy
end


