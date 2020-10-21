class Merchant < ApplicationRecord
  has_many :items, :dependent => :delete_all
  has_many :invoices, :dependent => :delete_all

  validates_presence_of :name

  def self.single_finder(params)
    Merchant.where("LOWER(merchants.name) LIKE LOWER('%#{params[:name]}%')").limit(1)
  end
end
