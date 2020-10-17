class Item < ApplicationRecord
  belongs_to :merchant

  validates_presence_of :name, :description, :price_unit
  validates_numericality_of :price_unit, greater_than: 0
end
