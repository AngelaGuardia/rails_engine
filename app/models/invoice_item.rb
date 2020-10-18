class InvoiceItem < ApplicationRecord
  belongs_to :item
  belongs_to :invoice

  validates_presence_of :quantity, :unit_price
  validates_numericality_of :quantity, :unit_price, greater_than: 0
end
