require 'csv'
require 'fileutils'
require 'shopify_api'
require 'yaml'

config = YAML.load_file('config.yml')
private_app_key = config['store_credentials']['key'] 
private_app_password = config['store_credentials']['password'] 
store = config['store_credentials']['name']
product_count = config['import_metafields_from_csv']['product_count']

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

  CSV.foreach('csv/import_metafields.20170710.clean.csv', headers: true).with_index(1) do |row, rowno|

    if rowno > lower_limit and rowno < upper_limit  

      # process the row
      product = ShopifyAPI::Product.find(row['id'])
      price = row['price']
      variant_id = product.variants.first.id
      variant = ShopifyAPI::Variant.find(variant_id)
      variant.price = price
      variant.save

      # Add Nexternal ID (metafield) to product
      nexternal_id = ShopifyAPI::Metafield.new(namespace: 'rock-solid', key: 'nexternal_id', value: row['nexternal_id'], value_type: 'string')
      product.add_metafield(nexternal_id)

      # Add Internal Memo (metafield) to product
      internal_memo = ShopifyAPI::Metafield.new(namespace: 'rock-solid', key: 'internal_memo', value: row['internal_memo'], value_type: 'string')
      product.add_metafield(internal_memo)

      # Add Author (metafield) to product
      author = ShopifyAPI::Metafield.new(namespace: 'rock-solid', key: 'author', value: row['author'], value_type: 'string')
      product.add_metafield(author)

      # Add Related IDs (metafield) to product
      related_handles = ShopifyAPI::Metafield.new(namespace: 'rock-solid', key: 'related_handles', value: row['related_handles'], value_type: 'string')
      puts row['related_handles']
      product.add_metafield(related_handles)

    end
  end
end
