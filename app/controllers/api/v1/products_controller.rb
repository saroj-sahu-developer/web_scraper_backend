require 'uri'
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

        if existing_product
          # If product already fetched from this url, instaed of creating a new record, update the existing product
          if existing_product.update(product_params(product_data))
            render json: {
              data: existing_product
            }, status: :ok
          else
            Rails.logger.error("Error: #{existing_product.errors.full_messages}")
            render json: {
              error: "Some error occured" 
            }, status: :bad_gateway
          end
          return
        end

        product = Product.new(product_params(product_data))

        begin
          category = Category.find_or_create_by!(
                       title: category_title(product_data)
                    )
          
          product.category = category
        rescue => e
          Rails.logger.error("Error: #{e.message}")
          # If category is not saved & assigned to product, then also product can be saved without category
        end

        success = false
        begin
          ActiveRecord::Base.transaction do
            product.save!
            ProductUrl.create!(url: url, product_id: product.id)
            success = true
          end
        rescue ActiveRecord::RecordInvalid => e
          Rails.logger.error("Transaction failed: #{e.message}")
        end        

        if success
          render json: {
            data: product
          }, status: :ok
        else
          Rails.logger.error("Error: #{product.errors.full_messages}")
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
        url = params[:url].to_s.strip
        uri = URI.parse(url)
        clean_url = "#{uri.scheme}://#{uri.host}#{uri.path}"
        clean_url
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

      def existing_product
        @_existing_product ||= begin
          product_url = ProductUrl.find_by(url: url)
          product_url&.product
        end
      end
    end
  end
end