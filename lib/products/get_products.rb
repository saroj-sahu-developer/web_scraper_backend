module Products
  class GetProducts
    class << self
      def get(
          order_by: default_order_by, 
          order: default_order, 
          pagination: true, 
          page: default_page, 
          per_page: default_limit
        )

        if pagination
          products = Product.order(order_by => order).page(page).per(per_page)
        else
          products = Product.order(order_by => order)
        end 

        products
      end

      def get_by_category(
        order_by: default_order_by, 
        order: default_order, 
        pagination: true, 
        page: default_page, 
        per_page: default_limit,
        category:
      )

        if pagination
          products = category.products.order(order_by => order).page(page).per(per_page)
        else
          products = category.products.order(order_by => order)
        end 

        products
      end

      def get_by_product_name(
        order_by: default_order_by, 
        order: default_order, 
        pagination: true, 
        page: default_page, 
        per_page: default_limit,
        search_by:
      )

        if pagination
          products = Product.where("title LIKE ?", "%#{search_by}%").order(order_by => order).page(page).per(per_page)
        else
          products = Product.where("title LIKE ?", "%#{search_by}%").order(order_by => order)
        end 

        products
      end

      def get_by_product_name_and_category(
        order_by: default_order_by, 
        order: default_order, 
        pagination: true, 
        page: default_page, 
        per_page: default_limit,
        search_by:,
        category:
      )

        if pagination
          products = category.products.where("title LIKE ?", "%#{search_by}%").order(order_by => order).page(page).per(per_page)
        else
          products = category.products.where("title LIKE ?", "%#{search_by}%").order(order_by => order)
        end 

        products
      end

      def default_order_by
        'id'
      end

      def default_order
        'asc'
      end

      def default_limit
        10
      end

      def default_page
        1
      end
    end
  end
end