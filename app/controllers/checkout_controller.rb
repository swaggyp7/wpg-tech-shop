class CheckoutController < ApplicationController
  before_action :authenticate_customer!
  before_action :ensure_stripe_checkout_configured!, only: %i[create success]

  def create
    cart = current_customer.current_cart
    order = cart.build_pending_order!

    session = Stripe::Checkout::Session.create(
      mode: "payment",
      client_reference_id: order.id.to_s,
      customer_email: current_customer.email,
      success_url: checkout_success_redirect_url,
      cancel_url: checkout_cancel_redirect_url(order),
      metadata: {
        order_id: order.id.to_s,
        customer_id: current_customer.id.to_s
      },
      line_items: stripe_line_items(order)
    )

    redirect_to session.url, allow_other_host: true, status: :see_other
  rescue ArgumentError => e
    redirect_to cart_path, alert: e.message
  rescue Stripe::StripeError => e
    order&.destroy if order&.persisted? && order.pending?
    redirect_to cart_path, alert: "Stripe checkout could not be started: #{e.message}"
  end

  def success
    @session = Stripe::Checkout::Session.retrieve(params[:session_id])
    @order = current_customer.orders.includes(order_items: :product).find(order_id_from_session(@session))

    @order.mark_paid! if @session.payment_status == "paid"
    @breadcrumbs = checkout_breadcrumbs("Checkout Complete")
  rescue ActiveRecord::RecordNotFound
    redirect_to cart_path, alert: "We couldn't find that order."
  rescue Stripe::StripeError => e
    redirect_to cart_path, alert: "Stripe checkout could not be verified: #{e.message}"
  end

  def cancel
    @order = current_customer.orders.includes(order_items: :product).find_by(id: params[:order_id])
    @order&.mark_cancelled!
    @breadcrumbs = checkout_breadcrumbs("Checkout Cancelled")
  end

  private

  def ensure_stripe_checkout_configured!
    return if stripe_checkout_configured?

    redirect_to cart_path, alert: "Stripe test keys are not configured yet."
  end

  def stripe_checkout_configured?
    Rails.configuration.x.stripe.secret_key.present?
  end

  def stripe_line_items(order)
    currency = Rails.configuration.x.stripe.currency

    order.order_items.map do |order_item|
      {
        quantity: order_item.quantity,
        price_data: {
          currency: currency,
          unit_amount: (order_item.price_at_purchase.to_d * 100).round(0).to_i,
          product_data: {
            name: order_item.product.title,
            description: order_item.product.description.to_s.truncate(120)
          }
        }
      }
    end
  end

  def checkout_success_redirect_url
    "#{request.base_url}#{checkout_success_path}?session_id={CHECKOUT_SESSION_ID}"
  end

  def checkout_cancel_redirect_url(order)
    "#{request.base_url}#{checkout_cancel_path}?order_id=#{order.id}"
  end

  def order_id_from_session(session)
    session.metadata&.[]("order_id").presence || session.client_reference_id
  end

  def checkout_breadcrumbs(label)
    [
      { label: "Home", path: root_path },
      { label: "Cart", path: cart_path },
      { label: label, path: nil }
    ]
  end
end
