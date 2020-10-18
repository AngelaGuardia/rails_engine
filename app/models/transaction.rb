class Transaction < ApplicationRecord
  belongs_to :invoice

  validates :credit_card_number, presence: true, numericality: true
  validates_presence_of :credit_card_expiration_date, :result
end
