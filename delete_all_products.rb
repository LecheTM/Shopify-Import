# gem install shopify_api
# irb

require 'fileutils'
require 'shopify_api'
require 'yaml'

config = YAML.load_file('config.yml')
development = config['development']

private_app_key = development['key'] 
private_app_password = development['password'] 
store = development['store']

ShopifyAPI::Base.site = "https://#{private_app_key}:#{private_app_password}@#{store}.myshopify.com/admin"

# Get a specific product
products = ShopifyAPI::Product.all

products.each do |product|
  File.open("products", 'a') {|f| f.puts(product) }
  ShopifyAPI::Product.delete(product.id)
end
