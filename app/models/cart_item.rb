class CartItem < ApplicationRecord
  belongs_to :cart
  belongs_to :product

  validates :quantity, presence: true, numericality: { only_integer: true, greater_than: 0 }
  validates :product_id, uniqueness: { scope: :cart_id }

  def discounted?
    product.on_sale? && product.discount_percentage.present? && product.discount_percentage.to_d.positive?
  end

  def unit_price
    return product.price unless discounted?

    product.price * (1 - (product.discount_percentage.to_d / 100))
  end

  def line_total
    unit_price * quantity.to_i
  end
end
