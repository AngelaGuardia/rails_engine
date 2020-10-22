class Api::V1::Merchants::BusinessIntelligenceController < ApplicationController
  def most_revenue
    render json: MerchantSerializer.new(Merchant.most_revenue(params))
  end

  def most_items
    render json: MerchantSerializer.new(Merchant.most_items(params))
  end
end
