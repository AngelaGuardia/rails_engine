class Item < ApplicationRecord
  belongs_to :merchant
  has_many :invoice_items
  has_many :invoices, through: :invoice_items

  validates_presence_of :name, :description, :price_unit
  validates_numericality_of :price_unit, greater_than: 0
end
