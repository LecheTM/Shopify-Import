# retrieves smart collections, creates corresponding smart collections with rules in another store

require 'json'
require 'open-uri'
require 'shopify_api'
require 'yaml'

config = YAML.load_file('config.yml')

# connect to origin store
origin_key = config['key'] 
origin_password = config['password'] 
origin_name = config['name']
ShopifyAPI::Base.site = "https://#{origin_key}:#{origin_password}@#{origin_name}.myshopify.com/admin"

# get all origin SmartCollection
page = 1
origin_pages = []
count = ShopifyAPI::Page.count
puts "Number of Pages: #{count}"
if count > 0
  page += count.divmod(50).first
  while page > 0
    puts "Processing page #{page}"
    origin_pages += ShopifyAPI::Page.all(:params => {:page => page, :limit => 50})
    page -= 1
  end
end
puts "returning #{origin_pages.length} Pages"

# connect to destination store
destination_key = config['destination_key'] 
destination_password = config['destination_password'] 
destination_name = config['destination_name']
ShopifyAPI::Base.site = "https://#{destination_key}:#{destination_password}@#{destination_name}.myshopify.com/admin"

# create all destination SmartCollection and save to destination store
total_pages_migrated = 0
origin_pages.each { |origin_page| 
  origin_hash = {}
  origin_page.instance_variables.each {|var| origin_hash[var.to_s.delete("@")] = origin_page.instance_variable_get(var)}
  origin_attributes = origin_hash['attributes']

  destination_attributes = {}
  rules = []
  imeage = {}
  origin_attributes.each do |key, value|
    unless ['id','shop_id'].include? key 
      destination_attributes["#{key}"] = value
    end
  end
  destination_page = ShopifyAPI::Page.new(destination_attributes)
  success = destination_page.save
  if success 
    total_pages_migrated += 1
  else
    failed_page_json =  destination_page.as_json
    p failed_page_json
  end
}
p "#{total_pages_migrated} successfully migrated"
