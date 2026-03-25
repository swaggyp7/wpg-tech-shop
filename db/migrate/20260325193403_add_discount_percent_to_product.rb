class AddDiscountPercentToProduct < ActiveRecord::Migration[7.1]
  def change
    add_column :products, :discount_percentage, :decimal
  end
end
