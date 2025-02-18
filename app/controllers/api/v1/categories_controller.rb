module Api
  module V1
    class CategoriesController < ApplicationController
      def index
        categories = Category.all

        render json: {
          data: categories
        }, status: :ok
      end
    end
  end
end