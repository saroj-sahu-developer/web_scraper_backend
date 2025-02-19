class Product < ApplicationRecord
  serialize :description, JSON
  # AS webscraper fetches the product description in json format, So the description is stored as json text in DB 

  belongs_to :category, optional: true
  # As if the webscraper will not be able to scrape the category from the webpage, so optional
  has_one :product_url, dependent: :destroy

  validates :title, presence: true
  validates :price, presence: true, numericality: true
end
