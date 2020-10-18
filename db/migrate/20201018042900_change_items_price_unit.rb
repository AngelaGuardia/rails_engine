class ChangeItemsPriceUnit < ActiveRecord::Migration[5.2]
  def change
    rename_column :items, :price_unit, :unit_price
  end
end
