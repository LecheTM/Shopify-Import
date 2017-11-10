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
origin_smart_collections = []
count = ShopifyAPI::SmartCollection.count
puts "Number of SmartCollections: #{count}"
if count > 0
  page += count.divmod(50).first
  while page > 0
    puts "Processing page #{page}"
    origin_smart_collections += ShopifyAPI::SmartCollection.all(:params => {:page => page, :limit => 50})
    page -= 1
  end
end
puts "returning #{origin_smart_collections.length} SmartCollections"

# connect to destination store
destination_key = config['destination_key'] 
destination_password = config['destination_password'] 
destination_name = config['destination_name']
ShopifyAPI::Base.site = "https://#{destination_key}:#{destination_password}@#{destination_name}.myshopify.com/admin"

# create all destination SmartCollection and save to destination store
total_smart_collections_migrated = 0
origin_smart_collections.each { |origin_smart_collection| 
  origin_hash = {}
  origin_smart_collection.instance_variables.each {|var| origin_hash[var.to_s.delete("@")] = origin_smart_collection.instance_variable_get(var)}
  origin_attributes = origin_hash['attributes']

  destination_attributes = {}
  rules = []
  imeage = {}
  origin_attributes.each do |key, value|
    unless ['id','rules','image'].include? key 
      destination_attributes["#{key}"] = value
    else 
      if key == 'rules'
        value.each { |rule|
          rule_hash = {}
          rule.instance_variables.each {|var| rule_hash[var.to_s.delete("@")] = rule.instance_variable_get(var)}
          rule_attributes = rule_hash['attributes']
          rules.push(rule_attributes)
        }
        destination_attributes["rules"] = rules
      elsif key == 'image'
        image_hash = {}
        value.instance_variables.each {|var| image_hash[var.to_s.delete("@")] = value.instance_variable_get(var)}
        image_attributes = image_hash['attributes']
        destination_attributes["image"] = image_attributes 
      end
    end
  end
  destination_smart_collection = ShopifyAPI::SmartCollection.new(destination_attributes)
  success = destination_smart_collection.save
  if success 
    total_smart_collections_migrated += 1
  else
    failed_smart_collection_json =  destination_smart_collection.as_json
    p failed_smart_collection_json
    #p "#{destination_smart_collection} failed to migrate"
  end
}
p "#{total_smart_collections_migrated} successfully migrated"
