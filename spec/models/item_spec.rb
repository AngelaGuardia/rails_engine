require 'rails_helper'

RSpec.describe Item, type: :model do
  describe "validations" do
    it { should validate_presence_of :name }
    it { should validate_presence_of :description }
    it { should validate_presence_of :price_unit }
    it { should validate_numericality_of(:price_unit).is_greater_than(0) }
  end

  describe 'relationships' do
    it { should belong_to :merchant }
  end
end
