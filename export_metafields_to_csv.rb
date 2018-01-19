# Creates metafields export (export.metafeidls.YYYYMMDD.csv)

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

# chunking 
chunks = (product_count / 25).ceil
start_time = Time.now
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
# end chunking

date = Time.now.strftime("%Y%m%d")
CSV.open("csv/#{store}_export_metafields.#{date}.csv", "wb") do |csv|

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

    products.each_with_index {|product, index|

      if index > lower_limit and index < upper_limit  

        handle = product.handle
        product_id = product.id
        metafields = product.metafields
        mf_json = metafields.as_json

        # configure for particular store
        directions = ""
        disclaimer = ""
        ingredients = ""

        mf_json.each do |mf|

          if mf['namespace'] == "left-column" 
            puts mf
            puts "++++++++++++++++++"
            reviews = mf['value']
            puts handle + ": " + reviews
          end

          case mf['key']
          when "directions" 
            directions = mf['value']
          when "disclaimer" 
            disclaimer = mf['value']
          when "ingredients" 
            ingredients = mf['value']
          end

        end
        #.first['value'] 
        #mf_hash = JSON.parse(mf_json)
        #puts mf_hash.inspect
        csv << [product_id, handle, directions, disclaimer, ingredients]

      end
    }
  end
end
