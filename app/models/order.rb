class Order < ApplicationRecord
  include TaxCalculations

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

  def checkout_session_active?
    pending? && stripe_checkout_url.present? && checkout_session_expires_at.present? && checkout_session_expires_at.future?
  end

  def subtotal
    order_items.includes(:product).sum(&:line_total)
  end

  def tax_profile
    customer.province_record
  end

  def mark_paid!
    return if paid?

    transaction do
      update!(
        status: "paid",
        total_price: grand_total,
        order_date: order_date || Time.current
      )

      consume_customer_cart!
    end
  end

  def mark_cancelled!
    return unless pending?

    update!(status: "cancelled")
  end

  def self.ransackable_attributes(_auth_object = nil)
    ["created_at", "customer_id", "id", "order_date", "status", "total_price", "updated_at"]
  end

  def self.ransackable_associations(_auth_object = nil)
    ["customer", "order_items", "products"]
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
