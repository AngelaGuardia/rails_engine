class Api::V1::Merchants::BusinessIntelligenceController < ApplicationController
  def most_revenue
    render json: MerchantSerializer.new(Merchant.most_revenue(params))
  end

  def most_items
    render json: MerchantSerializer.new(Merchant.most_items(params))
  end

  def revenue_over_range
    render json: RevenueSerializer.revenue(Merchant.revenue_over_range(params))
  end

  def total_revenue
    render json: RevenueSerializer.revenue(Merchant.total_revenue(params))
  end
end
