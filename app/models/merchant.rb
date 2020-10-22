class Merchant < ApplicationRecord
  has_many :items, :dependent => :delete_all
  has_many :invoices, :dependent => :delete_all
  has_many :invoice_items, through: :invoices
  has_many :transactions, through: :invoices

  validates_presence_of :name

  def self.single_finder(params)
    Merchant.where("LOWER(merchants.name) LIKE LOWER('%#{params[:name]}%')").limit(1).first
  end

  def self.multi_finder(params)
    Merchant.where("LOWER(merchants.name) LIKE LOWER('%#{params[:name]}%')")
  end

  def self.most_revenue(params)
    joins(invoices: [:invoice_items, :transactions])
      .select("merchants.id, merchants.name, sum(invoice_items.quantity * invoice_items.unit_price) AS revenue")
      .where("invoices.status = 'shipped' AND transactions.result = 'success'")
      .group("merchants.id")
      .order("revenue DESC")
      .limit(params[:quantity])
  end
end
