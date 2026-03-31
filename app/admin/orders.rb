ActiveAdmin.register Order do
  actions :index, :show

  includes :customer, order_items: :product

  filter :status, as: :select, collection: -> { Order.statuses.keys.map { |status| [status.humanize, status] } }
  filter :customer, as: :select, collection: -> { Customer.order(:email).map { |customer| [customer.email, customer.id] } }
  filter :order_date
  filter :created_at

  index do
    selectable_column
    id_column
    column :order_date
    column("Customer") { |order| order.customer.email }
    column("Products") do |order|
      ul do
        order.order_items.each do |order_item|
          li "#{order_item.product.title} x#{order_item.quantity}"
        end
      end
    end
    column("Subtotal") { |order| number_to_currency(order.subtotal) }
    column("Tax") { |order| number_to_currency(order.tax_amount) }
    column("Grand Total") { |order| number_to_currency(order.grand_total) }
    column :status
  end

  show do
    attributes_table do
      row :id
      row :order_date
      row("Customer") { |order| order.customer.email }
      row :status
      row("Subtotal") { |order| number_to_currency(order.subtotal) }
      row("Tax") { |order| number_to_currency(order.tax_amount) }
      row("Grand Total") { |order| number_to_currency(order.grand_total) }
    end

    panel "Products" do
      table_for resource.order_items do
        column("Product") { |order_item| order_item.product.title }
        column :quantity
        column("Unit Price") { |order_item| number_to_currency(order_item.price_at_purchase) }
        column("Line Total") { |order_item| number_to_currency(order_item.line_total) }
      end
    end
  end

  controller do
    def scoped_collection
      super.includes(:customer, order_items: :product)
    end
  end
end
