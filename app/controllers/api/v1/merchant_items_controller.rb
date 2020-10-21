class Api::V1::MerchantItemsController < ApplicationController
  def index
    render json: ItemSerializer.new(Item.all.where(merchant_id: params[:merchant_id]))
  end
end
