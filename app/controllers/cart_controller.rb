class CartController < ApplicationController
  before_action :authenticate_customer!
  before_action :set_cart
  before_action :set_cart_item, only: :update_item

  def index
    @cart_items = @cart.cart_items.includes(product: [:category, { image_attachment: :blob }]).order(created_at: :desc)
    @breadcrumbs = [
      { label: "Home", path: root_path },
      { label: "Cart", path: nil }
    ]
  end

  def update_item
    quantity = params[:quantity].to_i

    if quantity < 1
      redirect_to cart_path, alert: "Quantity must be at least 1."
      return
    end

    if @cart_item.update(quantity: quantity)
      redirect_to cart_path, notice: "#{@cart_item.product.title} quantity updated."
    else
      redirect_to cart_path, alert: @cart_item.errors.full_messages.to_sentence.presence || "We couldn't update that item."
    end
  end

  private

  def set_cart
    @cart = current_customer.current_cart
  end

  def set_cart_item
    @cart_item = @cart.cart_items.find(params[:id])
  end
end
