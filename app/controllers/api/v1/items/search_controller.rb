class Api::V1::Items::SearchController < ApplicationController
  def show
    render json: ItemSerializer.new(Item.single_finder(params))
  end
end
