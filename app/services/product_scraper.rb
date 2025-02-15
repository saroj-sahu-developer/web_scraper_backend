require 'httparty'
require 'nokogiri'

class ProductScraper
  def initialize(url)
    @url = url
  end

  def scrape
    begin
      response = HTTParty.get(@url)

      return { error: "Failed to fetch the page" } unless response.success?

      parsed_page = Nokogiri::HTML(response.body)

      product_data = formatted_data(parsed_page)

      {
        data: product_data
      }
    rescue => e
      return { error: "Failed to fetch the page" }
    end
  end

  private

  def formatted_data(parsed_page)
    {
      title: parsed_page.css('span.VU-ZEz')&.text&.strip,
      price: parsed_page.css('div.Nx9bqj')&.text&.strip,
      image_url: parsed_page.at_css('div.gqcSqV.YGE0gZ img._53J4C-')&.[]('src'),
      description: fetch_description(parsed_page),
      category: fetch_category(parsed_page)
    }
  end

  def fetch_description(parsed_page)
    description = {}

    parsed_page.css('.sBVJqn._8vsVX1 .row').each do |row|
      key_element = row.at_css('.col-3-12._9NUIO9')
      value_element = row.at_css('.col-9-12.-gXFvC')

      next unless key_element && value_element

      key = key_element.text.strip
      value = value_element.text.strip

      next if key.blank? || value.blank?

      description[key] = value
    end

    description
  end

  def fetch_category(parsed_page)
    breadcrumbs = parsed_page.css('div.r2CdBx a.R0cyWM')
    breadcrumbs[1]&.text&.strip
  end
end