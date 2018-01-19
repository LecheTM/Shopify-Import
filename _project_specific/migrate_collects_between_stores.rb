# Used to update products belonging to collection in one store, to belonging to collection in another store
# Created for helping to create staging stores
# A "Collect" is the Shopify object used to link a Product to a Manual Collection

require 'json'
require 'open-uri'
require 'shopify_api'
require 'yaml'

config = YAML.load_file('config.yml')
from_key = config['store_credentials']['key'] 
from_password = config['store_credentials']['password'] 
from_store = config['store_credentials']['name']
count = config['migrate_collects_between_stores']['product_count']
from_collection_id = config['migrate_collects_between_stores']['from_collection_id']

ShopifyAPI::Base.site = "https://#{from_key}:#{from_password}@#{from_store}.myshopify.com/admin"

page = 1
collects = []
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

to_collection_id = config['migrate_collects_between_stores']['to_collection_id']
to_key = config['migrate_collects_between_stores']['to_key'] 
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
