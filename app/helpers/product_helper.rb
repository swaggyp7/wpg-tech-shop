module ProductHelper
  def breadcrumbs?
    @breadcrumbs.present?
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
