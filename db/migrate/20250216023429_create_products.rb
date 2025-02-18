class CreateProducts < ActiveRecord::Migration[7.1]
  def change
    create_table :products do |t|
      t.string :title
      t.text :description
      t.decimal :price
      t.text :image_url
      t.references :category, foreign_key: true
      t.timestamps
    end
  end
end
