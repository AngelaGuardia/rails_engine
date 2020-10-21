class Item < ApplicationRecord
  belongs_to :merchant
  has_many :invoice_items
  has_many :invoices, through: :invoice_items
  has_many :transactions, through: :invoices

  validates_presence_of :name, :description, :unit_price
  validates_numericality_of :unit_price, greater_than: 0

  def self.single_finder(params)
    params.each do |attribute, value|
      if ["name", "description"].include? attribute.to_s
        return Item.where("LOWER(items.#{attribute}) LIKE LOWER('%#{value}%')").limit(1).first
      else
        return Item.where("items.#{attribute} = #{value}").limit(1).first
      end
    end
  end

  def self.multi_finder(params)
    params.each do |attribute, value|
      if ["name", "description"].include? attribute.to_s
        return Item.where("LOWER(items.#{attribute}) LIKE LOWER('%#{value}%')")
      else
        return Item.where("items.#{attribute} = #{value}")
      end
    end
  end
end
