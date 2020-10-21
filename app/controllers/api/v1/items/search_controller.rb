class Api::V1::Items::SearchController < ApplicationController
  def index
    render json: ItemSerializer.new(Item.multi_finder(params))
  end

  def show
    render json: ItemSerializer.new(Item.single_finder(params))
  end
end
