class StripeWebhooksController < ApplicationController
  skip_before_action :verify_authenticity_token

  def create
    webhook_secret = Rails.configuration.x.stripe.webhook_secret
    return head :service_unavailable if webhook_secret.blank?

    event = Stripe::Webhook.construct_event(
      request.raw_post,
      request.env["HTTP_STRIPE_SIGNATURE"],
      webhook_secret
    )

    handle_checkout_session_completed(event.data.object) if event.type == "checkout.session.completed"

    head :ok
  rescue JSON::ParserError, Stripe::SignatureVerificationError
    head :bad_request
  end

  private

  def handle_checkout_session_completed(session)
    return unless session.payment_status == "paid"

    order_id = session.metadata&.[]("order_id").presence || session.client_reference_id
    order = Order.find_by(id: order_id)
    return unless order

    order.mark_paid!
  end
end
