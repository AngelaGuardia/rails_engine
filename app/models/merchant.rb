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

  def self.most_items(params)
    joins(invoices: [:invoice_items, :transactions])
      .select("merchants.id, merchants.name, sum(invoice_items.quantity) AS total")
      .where("invoices.status = 'shipped' AND transactions.result = 'success'")
      .group("merchants.id")
      .order("total DESC")
      .limit(params[:quantity])
  end

  def self.revenue_over_range(params)
    InvoiceItem.joins(:transactions)
      .where("invoices.status = 'shipped' AND transactions.result = 'success' AND invoices.created_at >=  '#{params[:start].to_datetime.beginning_of_day}' AND invoices.created_at <=  '#{params[:end].to_datetime.end_of_day}'").sum("invoice_items.quantity * invoice_items.unit_price")
  end

  def self.total_revenue(params)
    joins(invoices: [:invoice_items, :transactions])
      .where("invoices.status = 'shipped' AND transactions.result = 'success' AND merchants.id = #{params[:merchant_id]}")
      .sum("invoice_items.quantity * invoice_items.unit_price")
  end
end
