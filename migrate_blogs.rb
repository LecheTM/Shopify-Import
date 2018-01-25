# migrates Blogs from origin store to destination store

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

# get all origin Blogs 
page = 1
origin_blogs = []
count = ShopifyAPI::Blog.count
puts "Number of blogs: #{count}"
if count > 0
  page += count.divmod(50).first
  while page > 0
    puts "Processing page #{page}"
    origin_blogs += ShopifyAPI::Blog.all(:params => {:page => page, :limit => 50})
    page -= 1
  end
end
puts "returning #{origin_blogs.length} Blogs"

# connect to destination store
destination_key = config['destination_key'] 
destination_password = config['destination_password'] 
destination_name = config['destination_name']
ShopifyAPI::Base.site = "https://#{destination_key}:#{destination_password}@#{destination_name}.myshopify.com/admin"

# create all destination Blogs and save to destination store
total_blogs_migrated = 0
origin_blogs.each { |origin_blog| 
  origin_hash = {}
  origin_blog.instance_variables.each {|var| origin_hash[var.to_s.delete("@")] = origin_blog.instance_variable_get(var)}
  origin_attributes = origin_hash['attributes']

  destination_attributes = {}
  origin_attributes.each do |key, value|
    unless key == 'id' 
      destination_attributes["#{key}"] = value
    end
  end
  destination_blog = ShopifyAPI::Blog.new(destination_attributes)
  success = destination_blog.save
  if success 
    total_blogs_migrated += 1
  else
    failed_blog_json = destination_blog.as_json
    p failed_blog_json
  end
}
puts "#{total_blogs_migrated} Blogs successfully migrated"
