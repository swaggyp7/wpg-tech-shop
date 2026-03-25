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

category_names = [
  "Laptops",
  "Smartphones",
  "Accessories",
  "Gaming",
  "Audio",
  "Smart Home"
]

categories = category_names.map do |name|
  Category.find_or_create_by!(name: name)
end

Product.delete_all
Faker::UniqueGenerator.clear

# seed by faker
100.times do |index|
  Product.create!(
    title: "#{Faker::Commerce.product_name} #{index + 1}",
    description: Faker::Lorem.paragraph(sentence_count: 3),
    price: Faker::Commerce.price(range: 49.0..2999.0),
    stock_quantity: Faker::Number.between(from: 0, to: 150),
    category: categories.sample,
    on_sale: Faker::Boolean.boolean(true_ratio: 25)
  )
end


