ActiveAdmin.register Category do
  permit_params :name

  filter :name
  filter :created_at
  filter :updated_at

  index do
    selectable_column
    id_column
    column :name
    column("Products") { |category| category.products.size }
    column :created_at
    actions
  end

  show do
    attributes_table do
      row :id
      row :name
      row("Products") { |category| category.products.count }
      row :created_at
      row :updated_at
    end

    panel "Products" do
      if resource.products.exists?
        table_for resource.products.order(:title) do
          column :id
          column :title
          column :price
          column :stock_quantity
          column :on_sale
        end
      else
        para "No products in this category yet."
      end
    end
  end

  form do |f|
    f.inputs do
      f.input :name
    end
    f.actions
  end

  controller do
    def scoped_collection
      super.includes(:products)
    end

    def destroy
      if resource.products.exists?
        redirect_to admin_category_path(resource), alert: "Cannot delete a category that still has products."
      else
        super
      end
    end
  end
end
