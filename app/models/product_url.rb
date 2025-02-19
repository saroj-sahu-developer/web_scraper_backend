class ProductUrl < ApplicationRecord
  belongs_to :product

  validates :url, presence: true, uniqueness: true
end
