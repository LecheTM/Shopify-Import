# Delete all products from a store

require 'fileutils'
require 'shopify_api'
require 'yaml'

config = YAML.load_file('config.yml')
private_app_key = config['store_credentials']['key'] 
private_app_password = config['store_credentials']['password'] 
store = config['store_credentials']['name']

ShopifyAPI::Base.site = "https://#{private_app_key}:#{private_app_password}@#{store}.myshopify.com/admin"

# Get a specific product
products = ShopifyAPI::Product.all

products.each do |product|
  #File.open("products", 'a') {|f| f.puts(product) }
  ShopifyAPI::Product.delete(product.id)
end
