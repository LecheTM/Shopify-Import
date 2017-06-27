# gem install shopify_api
# irb

require 'shopify_api'
require 'fileutils'

ShopifyAPI::Base.site = "https://8d416c2693e53fbc49466a3508469d7c:b3969458da8821c730af765b50d30838@leche-app-development.myshopify.com/admin"

# Get a specific product
products = ShopifyAPI::Product.all

products.each do |product|
  File.open("products", 'a') {|f| f.puts(product) }
  ShopifyAPI::Product.delete(product.id)
end
