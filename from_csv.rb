# Get credentials: https://help.shopify.com/api/getting-started/authentication/private-authentication
# # gem install shopify_api
# # irb

#CYCLE = 0.5

require 'shopify_api'
require 'csv'
require 'fileutils'

ShopifyAPI::Base.site = "https://8d416c2693e53fbc49466a3508469d7c:b3969458da8821c730af765b50d30838@leche-app-development.myshopify.com/admin"

product_count = 3851
puts "Total product count: #{product_count}" 
chunks = (product_count / 50).ceil

# Initializing.
start_time = Time.now

# While we still have products.
1.upto(chunks) do |chunk|

  unless chunk == 1
    stop_time = Time.now
    puts "Last batch processing started at #{start_time.strftime('%I:%M%p')}"
    puts "The time is now #{stop_time.strftime('%I:%M%p')}"
    processing_duration = stop_time - start_time
    puts "The processing lasted #{processing_duration.to_i} seconds."
    wait_time = 20
    #wait_time = (CYCLE - processing_duration).ceil
    puts "We will wait 20 seconds then we will resume."
    #puts "We have to wait #{wait_time} seconds then we will resume."
    sleep wait_time 
    #sleep wait_time if wait_time > 0
    start_time = Time.now
  end

  puts "Doing chunk #{chunk}/#{chunks}..."

  upper_limit = (chunk * 50) + 1
  lower_limit = (chunk * 50) - 50

  CSV.foreach('export_products_edited.csv', headers: true).with_index(1) do |row, rowno|
    if rowno > lower_limit and rowno < upper_limit  

      # process the row
      new_product = ShopifyAPI::Product.new
      new_product.body_html = row['LONG_DESCRIPTION']
      new_product.tags = row['CATEGORY']
      new_product.title = row['PRODUCT_NAME']
      new_product.variant = {
                              "barcode": row['ISBN'],
                              "compare_at_price": row['PRICE'],
                              "metafields_global_title_tag": row['HTML_TITLE'],
                              "metafields_global_description_tag": row['META_DESCRIPTION'],
                              "sku": row['SKU'],
                              "weight": row['WEIGHT'],
                              "weight_unit": "lb"
                            }
      new_product.vendor = row['VENDOR']
      new_product.save

      # Add Internal Memo (metafield) to new_product
      internal_memo = ShopifyAPI::Metafield.new(namespace: 'rock_solid', key: 'internal_memo', value: row['INTERNAL_MEMO'], value_type: 'string')
      new_product.add_metafield(internal_memo)

    end
  end
end

# Process shopping.csv
#CSV.foreach('shopping.csv', headers: true) do |row|
#  new_product = ShopifyAPI::Product.new
#  new_product.title = row['Product Name']
#  #new_product.product_type = "Snowboard"
#  new_product.vendor = "Burton"
#  new_product.save
#end
