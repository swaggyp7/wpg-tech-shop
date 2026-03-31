class Category < ApplicationRecord
  has_many :products

  def self.ransackable_attributes(_auth_object = nil)
    ["created_at", "id", "name", "updated_at"]
  end

  def self.ransackable_associations(_auth_object = nil)
    ["products"]
  end
end
