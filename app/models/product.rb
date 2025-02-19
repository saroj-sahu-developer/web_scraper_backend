class Product < ApplicationRecord
  serialize :description, JSON
  # AS webscraper fetches the product description in json format, So the description is stored as json text in DB 

  belongs_to :category, optional: true
  # As if the webscraper will not be able to scrape the category from the webpage, so optional
  has_one :product_url, dependent: :destroy

  validates :title, presence: true
  validates :price, presence: true, numericality: true

  def scrape_again
    url = self.product_url.url
    product_scraper = ProductScraper.new(url)
    product_data = product_scraper.scrape
    self.update(product_params(product_data))
  end

  private

  def product_params(product_data)
    data = product_data[:data].slice(:title, :price, :description, :image_url)
    data[:price] = data[:price].gsub(/[^\d.]/, '').to_f
    data
  end
end
