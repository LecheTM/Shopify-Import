require 'csv'
require 'fileutils'
require 'shopify_api'
require 'yaml'

config = YAML.load_file('config.yml')
private_app_key = config['key'] 
private_app_password = config['password'] 
store = config['name']
product_count = config['product_count']

ShopifyAPI::Base.site = "https://#{private_app_key}:#{private_app_password}@#{store}.myshopify.com/admin"

chunks = (product_count / 10).ceil

start_time = Time.now

1.upto(chunks) do |chunk|

  unless chunk == 1
    stop_time = Time.now
    puts "Last batch processing started at #{start_time.strftime('%I:%M%p')}"
    puts "The time is now #{stop_time.strftime('%I:%M%p')}"
    processing_duration = stop_time - start_time
    puts "The processing lasted #{processing_duration.to_i} seconds."
    wait_time = 15 
    puts "We will wait 15 seconds then we will resume."
    sleep wait_time 
    start_time = Time.now
  end

  puts "Doing chunk #{chunk}/#{chunks}..."

  upper_limit = (chunk * 10) + 1
  lower_limit = (chunk * 10) - 10

  CSV.foreach('csv/dr-michael-ruscio-staging_export_metafields.20171226.csv', headers: true).with_index(1) do |row, rowno|

    if rowno > lower_limit and rowno < upper_limit  

      handle = row['handle']
      puts handle
      # process the row
      products = ShopifyAPI::Product.find(:all, :params => {:handle => handle })
      product = products.first
      puts product
      #price = row['price']
      #variant_id = product.variants.first.id
      #variant = ShopifyAPI::Variant.find(variant_id)
      #variant.price = price
      #variant.save

      # Add Directions (metafield) to product
      directions = ShopifyAPI::Metafield.new(namespace: 'left-column', key: 'directions', value: row['directions'], value_type: 'string')
      product.add_metafield(directions)

      # Add Disclaimer (metafield) to product
      disclaimer = ShopifyAPI::Metafield.new(namespace: 'left-column', key: 'disclaimer', value: row['disclaimer'], value_type: 'string')
      product.add_metafield(disclaimer)

      # Add Ingredients (metafield) to product
      ingredients = ShopifyAPI::Metafield.new(namespace: 'left-column', key: 'ingredients', value: row['ingredients'], value_type: 'string')
      product.add_metafield(ingredients)

    end
  end
end
