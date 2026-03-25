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

  def on_sale_options
    [
      ["All Sale Status", nil],
      ["On Sale Only", "true"],
      ["Regular Price Only", "false"]
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
