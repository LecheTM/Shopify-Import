require 'csv'
require 'fileutils'
require 'shopify_api'
require 'yaml'

config = YAML.load_file('config.yml')
private_app_key = config['store_credentials']['key'] 
private_app_password = config['store_credentials']['password'] 
store = config['store_credentials']['name']
collection_count = config['import_collections_from_csv']['collection_count']

ShopifyAPI::Base.site = "https://#{private_app_key}:#{private_app_password}@#{store}.myshopify.com/admin"

chunks = (collection_count / 25).ceil

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

  CSV.foreach('csv/export_categories.20170704.snippet.csv', headers: true).with_index(1) do |row, rowno|

    if rowno > lower_limit and rowno < upper_limit  

      # process the row
      new_collection = ShopifyAPI::SmartCollection.new
      new_collection.title = row['CATEGORY'] 
      new_collection.body_html = row['DESCRIPTION']
      thumbnail = row['THUMBNAIL']
      unless thumbnail.nil?
        new_collection.image  = { "src": "http://cdn.nexternal.com/rocksolid/images/#{thumbnail}" }
      end
      new_collection.rules =  [
                                {
                                  "column": "tag",
                                  "relation": "equals",
                                  "condition": row['CATEGORY'] 
                                }
                              ] 
      new_collection.save
    end
  end
end
