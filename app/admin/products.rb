ActiveAdmin.register Product do

  # See permitted parameters documentation:
  # https://github.com/activeadmin/activeadmin/blob/master/docs/2-resource-customization.md#setting-up-strong-parameters
  #
  # Uncomment all parameters which should be permitted for assignment
  #
  permit_params :title, :description, :price, :stock_quantity, :category_id, :on_sale, :image
  
  filter :title
  filter :price
  filter :category

  index do
    selectable_column
    id_column
    column :title
    column :price
    column :stock_quantity
    column :category
    column :on_sale
    column :image do |product|
      if product.image.attached?
        image_tag url_for(product.image), style: "width: 100px;"
      end
    end
    actions
  end
  
  show do
    attributes_table do
      row :id
      row :title
      row :description
      row :price
      row :stock_quantity
      row :category
      row :on_sale
      row :image do |product|
        if product.image.attached?
          image_tag url_for(product.image), style: "max-width: 200px;"
        end
      end
    end 
  end

  form html: {multipart: true} do |f|
    f.inputs do
      f.input :title
      f.input :description
      f.input :price
      f.input :stock_quantity
      f.input :category
      f.input :on_sale
      f.input :image, as: :file
    end
    f.actions
  end

end
