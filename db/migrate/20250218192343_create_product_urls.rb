class CreateProductUrls < ActiveRecord::Migration[7.1]
  def change
    create_table :product_urls do |t|
      t.text :url
      t.references :product, foreign_key: true
      t.timestamps
    end
  end
end
