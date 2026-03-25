module ApplicationHelper
  def breadcrumb_link_classes(index)
    return "breadcrumb-item active" if index == @breadcrumbs.size - 1

    "breadcrumb-item"
  end

  def customer_display_name(customer)
    customer.name.presence || customer.email
  end

  def current_cart_item_count
    return 0 unless customer_signed_in?

    current_customer.cart&.total_quantity.to_i
  end

  def stripe_checkout_configured?
    Rails.configuration.x.stripe.secret_key.present?
  end
end
