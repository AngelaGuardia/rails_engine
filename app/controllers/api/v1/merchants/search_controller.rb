class Api::V1::Merchants::SearchController < ApplicationController
  def index
    render json: MerchantSerializer.new(Merchant.multi_finder(params))
  end

  def show
    render json: MerchantSerializer.new(Merchant.single_finder(params))
  end
end
