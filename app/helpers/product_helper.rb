module ProductHelper
  def breadcrumbs?
    @breadcrumbs.present?
  end

  def discounted_price(product)
    return product.price unless product.on_sale? && product.discount_percentage.present?

    product.price * (1 - (product.discount_percentage.to_d / 100))
  end

  def show_discount_price?(product)
    product.on_sale? && product.discount_percentage.present? && product.discount_percentage.to_d.positive?
  end

  def new_product?(product)
    product.created_at.present? && product.created_at >= 3.days.ago
  end

  def status_options
    [
      ["All", nil],
      ["On Sale", "on_sale"],
      ["Recently Updated", "recently_updated"]
    ]
  end

  def price_sort_options
    [
      ["Newest First", nil],
      ["Price: Low to High", "price_asc"],
      ["Price: High to Low", "price_desc"]
    ]
  end
end
