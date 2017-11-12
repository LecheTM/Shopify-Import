# Used to migrate Smart Collections and Products from one store to another

require 'json'
require 'open-uri'
require 'shopify_api'
require 'yaml'

config = YAML.load_file('config.yml')
namespace = config['namespace']

from_collection_id = config[namespace]['from_collection_id']
from_key = config[namespace]['from_key'] 
from_password = config[namespace]['from_password'] 
from_store = config[namespace]['from_store']
ShopifyAPI::Base.site = "https://#{from_key}:#{from_password}@#{from_store}.myshopify.com/admin"

page = 1
collects = []
count = config[namespace]['product_count']
puts "Number of Products #{count}"
if count > 0
  page += count.divmod(50).first
  while page > 0
    puts "Processing page #{page}"
    collects += ShopifyAPI::Collect.all(:params => {:page => page, :limit => 50, :collection_id => from_collection_id})
    page -= 1
  end
end
puts "returning #{collects.length} collects"

from_handles = Array.new
collects.each { |collect| 
  from_product = ShopifyAPI::Product.find(collect.product_id)
  from_handles << from_product.handle
  puts "Adding #{from_product.handle} to from_handles"
  sleep 1 
}

to_collection_id = config[namespace]['to_collection_id']
to_key = config[namespace]['to_key'] 
to_password = config[namespace]['to_password'] 
to_store = config[namespace]['to_store']
ShopifyAPI::Base.site = "https://#{to_key}:#{to_password}@#{to_store}.myshopify.com/admin"

from_handles.each { |from_handle|
  puts "Saving new collect for #{from_handle}"
  to_product = ShopifyAPI::Product.find(:all, :params => {:handle => from_handle})
  unless to_product.first.nil? 
    to_collect = ShopifyAPI::Collect.new(product_id: to_product.first.id, collection_id: to_collection_id)
    to_collect.save
  end
  sleep 1 
}
