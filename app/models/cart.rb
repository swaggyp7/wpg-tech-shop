class Cart < ApplicationRecord
  belongs_to :customer
  has_many :cart_items, dependent: :destroy
  has_many :products, through: :cart_items

  validates :customer_id, uniqueness: true

  def add_product(product, quantity)
    quantity = quantity.to_i
    raise ArgumentError, "Quantity must be greater than zero" unless quantity.positive?

    cart_item = cart_items.find_or_initialize_by(product: product)
    cart_item.quantity = cart_item.quantity.to_i + quantity
    cart_item.save!
    cart_item
  end
end
