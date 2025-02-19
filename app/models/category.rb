class Category < ApplicationRecord
  has_many :products, dependent: :nullify

  validates :title, presence: true, uniqueness: true
  # As category being fetched from webscraper, if a category already exists in db, then the product should belong so that category so uniqueness: true
end
