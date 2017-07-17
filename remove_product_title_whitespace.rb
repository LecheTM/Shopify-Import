require 'fileutils'
require 'shopify_api'
require 'yaml'

config = YAML.load_file('config.yml')
namespace = config['namespace']

private_app_key = config[namespace]['key'] 
private_app_password = config[namespace]['password'] 
product_count = config[namespace]['product_count']
store = config[namespace]['store']

ShopifyAPI::Base.site = "https://#{private_app_key}:#{private_app_password}@#{store}.myshopify.com/admin"

page = 1
products = []
count = ShopifyAPI::Product.count
puts "Number of Products #{count}"
if count > 0
  page += count.divmod(250).first
  while page > 0
    puts "Processing page #{page}"
    products += ShopifyAPI::Product.all(:params => {:page => page, :limit => 250})
    page -= 1
  end
end
puts "returning #{products.length} products"

products.each do |product| 

  title = product.title

  if title.match("  ")
    puts title
    title.tr!("  ", " ") 
    product.title = title
    product.save
  end
end
