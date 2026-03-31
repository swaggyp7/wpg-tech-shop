class Cart < ApplicationRecord
  include TaxCalculations

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

  def total_quantity
    cart_items.sum(:quantity)
  end

  def subtotal
    cart_items.includes(:product).sum(&:line_total)
  end

  def tax_profile
    customer.province_record
  end

  def checkout_signature
    cart_items.includes(:product).sort_by(&:product_id).map do |cart_item|
      [
        cart_item.product_id,
        cart_item.quantity,
        cart_item.unit_price.to_d.to_s("F")
      ].join(":")
    end.join("|")
  end

  def build_pending_order!(cart_signature: checkout_signature)
    raise ArgumentError, "Your cart is empty." if cart_items.empty?

    transaction do
      province = customer.province_record
      order = customer.orders.create!(
        order_date: Time.current,
        total_price: grand_total,
        status: "pending",
        cart_signature: cart_signature,
        province_code_snapshot: province&.code,
        gst_rate_snapshot: province&.gst_rate || 0,
        pst_rate_snapshot: province&.pst_rate || 0,
        hst_rate_snapshot: province&.hst_rate || 0,
        provincial_tax_name_snapshot: province&.provincial_tax_name
      )

      cart_items.includes(:product).find_each do |cart_item|
        order.order_items.create!(
          product: cart_item.product,
          quantity: cart_item.quantity,
          price_at_purchase: cart_item.unit_price
        )
      end

      order
    end
  end
end
