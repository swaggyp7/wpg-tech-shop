class Order < ApplicationRecord
  belongs_to :customer

  validates :order_date, presence: true

  enum status: {
    pending: "pending",
    paid: "paid",
    shipped: "shipped",
    cancelled: "cancelled"
  }
end
