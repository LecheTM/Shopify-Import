# Creates metafields export (export.metafeidls.YYYYMMDD.csv)

require 'csv'
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

date = Time.now.strftime("%Y%m%d")
CSV.open("csv/export_metafields.#{date}.csv", "wb") do |csv|

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
        nexternal_id = ""
        internal_memo = ""
        author =  ""

        mf_json.each do |mf|

          case mf['key']
          when "nexternal_id" 
            nexternal_id = mf['value']
          when "internal_memo" 
            internal_memo = mf['value']
          when "author" 
            author = mf['value']
          end

          #puts "#{product.handle} => #{mf['key']} :: #{mf['value']}"
        end
        #.first['value'] 
        #mf_hash = JSON.parse(mf_json)
        #puts mf_hash.inspect
        csv << [product_id, handle, nexternal_id, internal_memo, author]

      end
    }

  end
end
