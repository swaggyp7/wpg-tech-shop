class ProductController < ApplicationController
  before_action :set_product, only: :show

  def index
    @categories = Category.order(:name)
    @search_query = params[:query].to_s.strip
    @selected_category = Category.find_by(id: params[:category_id]) if params[:category_id].present?
    @selected_on_sale = params[:on_sale] if %w[true false].include?(params[:on_sale])
    @selected_sort = permitted_sort
    @min_price = normalized_price_param(:min_price)
    @max_price = normalized_price_param(:max_price)

    @products = Product.includes(:category, image_attachment: :blob)
    @products = apply_query_filter(@products)
    @products = @products.where(category: @selected_category) if @selected_category.present?
    @products = @products.where(on_sale: ActiveModel::Type::Boolean.new.cast(@selected_on_sale)) if @selected_on_sale.present?
    @products = @products.where("products.price >= ?", @min_price) if @min_price.present?
    @products = @products.where("products.price <= ?", @max_price) if @max_price.present?
    @products = @products.order(sort_order).page(params[:page]).per(12)
    @breadcrumbs = build_index_breadcrumbs
  end

  def show
    @quantity = 1
    @breadcrumbs = build_show_breadcrumbs
  end

  private

  def set_product
    @product = Product.includes(:category, image_attachment: :blob).find(params[:id])
  end

  def apply_query_filter(products)
    return products if @search_query.blank?

    keyword = "%#{ActiveRecord::Base.sanitize_sql_like(@search_query.downcase)}%"
    products.where("LOWER(products.title) LIKE ?", keyword)
  end

  def build_index_breadcrumbs
    [
      { label: "Home", path: root_path },
      { label: "Products", path: products_path }
    ]
  end

  def build_show_breadcrumbs
    [
      { label: "Home", path: root_path },
      { label: "Products", path: products_path },
      { label: @product.title, path: nil }
    ]
  end

  def permitted_sort
    return if params[:sort].blank?

    allowed_sorts = %w[price_asc price_desc]
    params[:sort] if allowed_sorts.include?(params[:sort])
  end

  def normalized_price_param(key)
    return if params[key].blank?

    value = BigDecimal(params[key].to_s)
    value if value >= 0
  rescue ArgumentError
    nil
  end

  def sort_order
    case @selected_sort
    when "price_asc"
      { price: :asc, created_at: :desc }
    when "price_desc"
      { price: :desc, created_at: :desc }
    else
      { created_at: :desc }
    end
  end
end
