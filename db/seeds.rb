# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

require "faker"
require "open-uri"
require "json"

Province.seed_defaults!

Product.delete_all
# Faker::UniqueGenerator.clear

# seed by faker
# 100.times do |index|
#   Product.create!(
#     title: "#{Faker::Commerce.product_name}",
#     description: Faker::Lorem.paragraph(sentence_count: 3),
#     price: Faker::Commerce.price(range: 49.0..2999.0),
#     stock_quantity: Faker::Number.between(from: 0, to: 150),
#     category: categories.sample,
#     on_sale: Faker::Boolean.boolean(true_ratio: 25)
#   )
# end

# seed by api
url = "https://dummyjson.com/products?limit=200"
data = JSON.parse(URI.open(url).read)

data["products"].each do |item|
  category = Category.find_or_create_by(name: item["category"])

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

AdminUser.create!(email: 'admin@example.com', password: 'password', password_confirmation: 'password') if Rails.env.development?
