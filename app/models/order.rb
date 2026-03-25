class Order < ApplicationRecord
  belongs_to :customer
  has_many :order_items, dependent: :destroy
  has_many :products, through: :order_items

  validates :order_date, presence: true
  validates :status, presence: true

  enum status: {
    pending: "pending",
    paid: "paid",
    shipped: "shipped",
    cancelled: "cancelled"
  }

  def subtotal
    order_items.includes(:product).sum(&:line_total)
  end

  def mark_paid!
    return if paid?

    transaction do
      update!(
        status: "paid",
        total_price: subtotal,
        order_date: order_date || Time.current
      )

      consume_customer_cart!
    end
  end

  def mark_cancelled!
    return unless pending?

    update!(status: "cancelled")
  end

  private

  def consume_customer_cart!
    cart = customer.cart
    return unless cart

    order_items.includes(:product).each do |order_item|
      cart_item = cart.cart_items.find_by(product_id: order_item.product_id)
      next unless cart_item

      remaining_quantity = cart_item.quantity.to_i - order_item.quantity.to_i

      if remaining_quantity.positive?
        cart_item.update!(quantity: remaining_quantity)
      else
        cart_item.destroy!
      end
    end
  end
end
