class ImmortalNode < ActiveRecord::Base
  include Immortal

  has_many :immortal_joins
  has_many :immortal_models, through: :immortal_joins

  has_many :joins, class_name: 'ImmortalJoin'
  has_many :models, through: :joins, source: :immortal_model

  belongs_to :target, polymorphic: true
end
