module Api
  module V1
    class ProductsController < ApplicationController
      def scrape
        product_scraper = ProductScraper.new(url)
        product_data = product_scraper.scrape

        if product_data[:error]
          render json: product_data, status: :bad_gateway
          return
        end

        product = Product.new(product_params(product_data))

        begin
          category = Category.find_or_create_by!(
                       title: category_title(product_data)
                    )
          
          product.category = category
        rescue => e
          puts "Error: #{e.message}"
          # If category is not saved & assigned to product, then also product can be saved without category
        end

        if product.save
          render json: {
            data: product
          }, status: :ok
        else
          puts product.errors.full_messages
          render json: {
            error: "Some error occured" 
          }, status: :bad_gateway
        end
      end

      def index
        if params[:category_id] && params[:search_by]
          data = ::Products::GetProducts.get_by_product_name_and_category(
            order_by: order_by, 
            order: order, 
            pagination: paginate?, 
            page: page, 
            per_page: per_page,
            category: category,
            search_by: search_by
          )
        elsif params[:category_id]
          data = ::Products::GetProducts.get_by_category(
            order_by: order_by, 
            order: order, 
            pagination: paginate?, 
            page: page, 
            per_page: per_page,
            category: category
          )
        elsif params[:search_by]
          data = ::Products::GetProducts.get_by_product_name(
            order_by: order_by, 
            order: order, 
            pagination: paginate?, 
            page: page, 
            per_page: per_page,
            search_by: search_by
          )
        else
          data = ::Products::GetProducts.get(
            order_by: order_by, 
            order: order, 
            pagination: paginate?, 
            page: page, 
            per_page: per_page
          )
        end        
        
        render json: {
          data: data
        }, status: :ok
      end

      def show
        render json: {
          data: product
        }, status: :ok
      end

      private

      def url
        params[:url]
      end

      def product_params(product_data)
        data = product_data[:data].slice(:title, :price, :description, :image_url)
        data[:price] = data[:price].gsub(/[^\d.]/, '').to_f
        data
      end

      def category_title(product_data)
        product_data[:data][:category]
      end

      def order
        order = params['order'].to_s.downcase
        if order == 'asc'
          order
        else
          'desc'
        end
      end

      def order_by
        order_by = params['order_by'].to_s.downcase
        if Product.column_names.include?(order_by)
          order_by
        else
          'id'
        end
      end

      def per_page
        params[:per_page].to_i
      end

      def page
        params[:page].to_i
      end

      def paginate?
        page > 0 && per_page > 0
      end

      def category
        @_category ||= Category.find(params[:category_id])
      end

      def search_by
        params[:search_by].to_s
      end

      def product
        @_product = Product.find(params[:id])
      end
    end
  end
end