class Merchant < ApplicationRecord
  has_many :items, :dependent => :delete_all
  has_many :invoices, :dependent => :delete_all

  validates_presence_of :name
end
