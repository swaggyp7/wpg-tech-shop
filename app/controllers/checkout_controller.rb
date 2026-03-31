class CheckoutController < ApplicationController
  before_action :authenticate_customer!
  before_action :ensure_stripe_checkout_configured!, only: %i[create success]
  before_action :ensure_customer_province_selected!, only: :create

  def create
    cart = current_customer.current_cart
    cart_signature = cart.checkout_signature
    order = reusable_pending_order(cart_signature)

    if order&.checkout_session_active?
      redirect_to order.stripe_checkout_url, allow_other_host: true, status: :see_other
      return
    end

    cancel_other_pending_orders(order)
    order&.mark_cancelled!
    order = cart.build_pending_order!(cart_signature: cart_signature)

    session = Stripe::Checkout::Session.create(
      {
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
      },
      {
        idempotency_key: "checkout-order-#{order.id}"
      }
    )

    order.update!(
      stripe_checkout_session_id: session.id,
      stripe_checkout_url: session.url,
      checkout_session_expires_at: checkout_session_expiration(session)
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

  def ensure_customer_province_selected!
    return if current_customer.province_record.present?

    redirect_to edit_customer_registration_path,
                alert: "Select a valid Canadian province or territory in My Account before checkout."
  end

  def stripe_checkout_configured?
    Rails.configuration.x.stripe.secret_key.present?
  end

  def stripe_line_items(order)
    currency = Rails.configuration.x.stripe.currency

    line_items = order.order_items.map do |order_item|
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

    return line_items unless order.tax_amount.positive?

    line_items << {
      quantity: 1,
      price_data: {
        currency: currency,
        unit_amount: (order.tax_amount * 100).round(0).to_i,
        product_data: {
          name: order.tax_label,
          description: "Calculated on the order subtotal at checkout"
        }
      }
    }

    line_items
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

  def reusable_pending_order(cart_signature)
    current_customer.orders.pending.order(created_at: :desc).find_by(cart_signature: cart_signature)
  end

  def cancel_other_pending_orders(reused_order)
    scope = current_customer.orders.pending
    scope = scope.where.not(id: reused_order.id) if reused_order.present?
    scope.find_each(&:mark_cancelled!)
  end

  def checkout_session_expiration(session)
    return unless session.respond_to?(:expires_at) && session.expires_at.present?

    Time.zone.at(session.expires_at.to_i)
  end

  def checkout_breadcrumbs(label)
    [
      { label: "Home", path: root_path },
      { label: "Cart", path: cart_path },
      { label: label, path: nil }
    ]
  end
end
