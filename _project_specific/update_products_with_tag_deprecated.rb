# Updates product titles with hardcoded collection name
# both product titls are retreived from a CSV (update_by_titles.csv)
# TODO: evalute whether this or update_products_with_tag_verbose.rb should be used

require 'csv'
require 'fileutils'
require 'shopify_api'
require 'yaml'

config = YAML.load_file('config.yml')
private_app_key = config['store_credentials']['key'] 
private_app_password = config['store_credentials']['password'] 
store = config['store_credentials']['name']
product_count = config['update_products_with_tag']['product_count']

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


product_titles = []
tag = ''
csv = CSV.read('csv/update_by_titles.csv')

csv.each.with_index do |row, i|

  if i == 0 
    tag += row[1]
    puts "Updating products with tag: #{tag}"
  end
  product_title = row[0]
  product_titles.push(product_title)

end

count = 0
products.each do |product| 
  clean_title = product.title.split.join(" ")
  if product_titles.include?(clean_title)
    count += 1
    tags = product.tags
    tags << ", #{tag}"
    product.title = clean_title
    product.tags = tags
    product.save
  end 
end
puts "#{count} Products Updated"
