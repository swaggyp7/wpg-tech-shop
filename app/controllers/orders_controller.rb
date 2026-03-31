class OrdersController < ApplicationController
  before_action :authenticate_customer!

  def index
    @orders = current_customer.orders
                           .includes(order_items: :product)
                           .order(order_date: :desc, created_at: :desc)
    @breadcrumbs = [
      { label: "Home", path: root_path },
      { label: "My Orders", path: nil }
    ]
  end
end
