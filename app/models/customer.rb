class Customer < ApplicationRecord
  has_many :orders

  validates :name, presence: true
  validates :email, presence: true
end
