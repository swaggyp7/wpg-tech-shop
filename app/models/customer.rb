class Customer < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable
  has_many :orders

  has_one :cart, dependent: :destroy
  has_many :cart_items, through: :cart

  validates :name, presence: true
  validates :email, presence: true

  def current_cart
    cart || create_cart!
  end

  def province_record
    Province.find_by_lookup(province)
  end

  def province_selection_value
    province_record&.code || province
  end

  def self.ransackable_attributes(_auth_object = nil)
    ["city", "created_at", "email", "id", "name", "postal_code", "province", "updated_at"]
  end

  def self.ransackable_associations(_auth_object = nil)
    ["cart", "cart_items", "orders"]
  end
end
