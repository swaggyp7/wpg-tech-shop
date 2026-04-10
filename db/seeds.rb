# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

require "open-uri"
require "json"

Province.seed_defaults!

seed_demo_data = ENV["SEED_DEMO_DATA"] == "1" || Rails.env.development?

if seed_demo_data
  Product.delete_all

  url = "https://dummyjson.com/products?limit=200"
  data = JSON.parse(URI.open(url).read)

  data["products"].each do |item|
    category = Category.find_or_create_by!(name: item["category"])

    product = Product.create!(
      title: item["title"],
      description: item["description"],
      price: item["price"],
      stock_quantity: item["stock"],
      discount_percentage: item["discountPercentage"],
      category: category,
      on_sale: item["discountPercentage"].to_f > 30
    )

    file = URI.open(item["images"].first)
    ext = File.extname(URI.parse(file.base_uri.to_s).path)
    product.image.attach(io: file, filename: "#{product.id}.#{ext}")
  end

  if Rails.env.development?
    AdminUser.find_or_create_by!(email: "admin@example.com") do |admin|
      admin.password = "password"
      admin.password_confirmation = "password"
    end
  end
end
