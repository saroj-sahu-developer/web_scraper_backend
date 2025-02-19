class UpdateOldProductsJob < ApplicationJob
  queue_as :default

  def perform(*args)
    products = Product.where("updated_at <= ?", 7.days.ago)
    
    products.each do |product|
      product.scrape_again
    end
  end
end
