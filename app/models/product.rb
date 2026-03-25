class Product < ApplicationRecord
  belongs_to :category
  has_many :order_items
  has_many :orders, through: :order_items

  has_one_attached :image

  def self.ransackable_attributes(auth_object = nil)
    ["category_id", "created_at", "description", "id", "id_value", "on_sale", "price", "stock_quantity", "title", "updated_at"]
  end

  def self.ransackable_associations(auth_object = nil)
    ["category", "image_attachment", "image_blob", "order_items", "orders"]
  end
end
