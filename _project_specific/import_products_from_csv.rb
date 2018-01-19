require 'csv'
require 'fileutils'
require 'shopify_api'
require 'yaml'

config = YAML.load_file('config.yml')
private_app_key = config['store_credentials']['key'] 
private_app_password = config['store_credentials']['password'] 
store = config['store_credentials']['name']
product_count = config['import_products_from_csv']['product_count']

ShopifyAPI::Base.site = "https://#{private_app_key}:#{private_app_password}@#{store}.myshopify.com/admin"

chunks = (product_count / 25).ceil

start_time = Time.now

1.upto(chunks) do |chunk|

  unless chunk == 1
    stop_time = Time.now
    puts "Last batch processing started at #{start_time.strftime('%I:%M%p')}"
    puts "The time is now #{stop_time.strftime('%I:%M%p')}"
    processing_duration = stop_time - start_time
    puts "The processing lasted #{processing_duration.to_i} seconds."
    wait_time = 10
    puts "We will wait 10 seconds then we will resume."
    sleep wait_time 
    start_time = Time.now
  end

  puts "Doing chunk #{chunk}/#{chunks}..."

  upper_limit = (chunk * 25) + 1
  lower_limit = (chunk * 25) - 25 

  # TODO: Abstract csv name and location
  CSV.foreach('csv/export_products.20170627.csv', headers: true).with_index(1) do |row, rowno|
    if rowno > lower_limit and rowno < upper_limit  

      # process the row
      new_product = ShopifyAPI::Product.new
      new_product.body_html = row['LONG_DESCRIPTION']
      main_image = row['MAIN_IMAGE']
      unless main_image.nil?
        new_product.images  = [ 
                                "src": "http://cdn.nexternal.com/rocksolid/images/#{main_image}",
                                "metafields": [
                                  {
                                    "namespace": "tags",
                                    "key": "alt",
                                    "value": row['ALT_TAG'],
                                    "value_type": "string"
                                  }
                                ]
                              ]
      end
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

      # Add Metafields below
      # Currently, the metafields listed are specific to R.O.C.K Solid (Nexternal) project
      #
      # Add Nexternal ID (metafield) to new_product
      nexternal_id = ShopifyAPI::Metafield.new(namespace: 'leche-app-store', key: 'nexternal_id', value: row['PRODUCT_NO'], value_type: 'string')
      new_product.add_metafield(nexternal_id)

      # Add Internal Memo (metafield) to new_product
      internal_memo = ShopifyAPI::Metafield.new(namespace: 'leche-app-store', key: 'internal_memo', value: row['INTERNAL_MEMO'], value_type: 'string')
      new_product.add_metafield(internal_memo)

      # Add Author (metafield) to new_product
      author = ShopifyAPI::Metafield.new(namespace: 'leche-app-store', key: 'author', value: row['CUSTOM_FIELD1'], value_type: 'string')
      new_product.add_metafield(author)

    end
  end
end
