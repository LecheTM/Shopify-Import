# migrates Articles from origin store to destination store

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
origin_blog_page = 1
origin_blogs = []
origin_blog_count = ShopifyAPI::Blog.count
puts "Number of origin Blogs: #{origin_blog_count}"
if origin_blog_count > 0
  origin_blog_page += origin_blog_count.divmod(50).first
  while origin_blog_page > 0
    puts "Processing blog page #{origin_blog_page}"
    origin_blogs += ShopifyAPI::Blog.all(:params => {:page => origin_blog_page, :limit => 50})
    origin_blog_page -= 1
  end
end
puts "returning #{origin_blogs.length} origin Blogs"

# get all origin Articles
article_page = 1
origin_articles = []
article_count = ShopifyAPI::Article.count
puts "Number of Articles: #{article_count}"
if article_count > 0
  article_page += article_count.divmod(50).first
  while article_page > 0
    puts "Processing article page #{article_page}"
    origin_articles += ShopifyAPI::Article.all(:params => {:page => article_page, :limit => 50})
    article_page -= 1
  end
end
puts "returning #{origin_articles.length} Articles"

# connect to destination store
destination_key = config['destination_key']
destination_password = config['destination_password']
destination_name = config['destination_name']
ShopifyAPI::Base.site = "https://#{destination_key}:#{destination_password}@#{destination_name}.myshopify.com/admin"

# get all destination Blogs 
destination_blog_page = 1
destination_blogs = []
destination_blog_count = ShopifyAPI::Blog.count
puts "Number of destination Blogs: #{destination_blog_count}"
if destination_blog_count > 0
  destination_blog_page += destination_blog_count.divmod(50).first
  while destination_blog_page > 0
    puts "Processing blog page #{destination_blog_page}"
    destination_blogs += ShopifyAPI::Blog.all(:params => {:page => destination_blog_page, :limit => 50})
    destination_blog_page -= 1
  end
end
puts "returning #{destination_blogs.length} destination Blogs"

# create an resolution array for origin blog-id and destingation blog-id
# TODO currently only works if blogs migrated first, lock this in with overwrite / update that will come with controllers and front end
blog_ids_resolution = {}
origin_blogs.each { |origin_blog|
  destination_blog_handle_match = destination_blogs.select { |destination_blog| 
    destination_blog.handle == origin_blog.handle 
  } 
  blog_ids_resolution[origin_blog.id] = destination_blog_handle_match[0].id #select returns arrary, not object so the object is at 0
}

# create all destination Articles and save to destination store
total_articles_migrated = 0
origin_articles.each { |origin_article| 
  origin_hash = {}
  origin_article.instance_variables.each {|var| origin_hash[var.to_s.delete("@")] = origin_article.instance_variable_get(var)}
  origin_attributes = origin_hash['attributes']
  origin_blog_id = origin_hash['prefix_options'][:blog_id]

  destination_attributes = {}
  image = {}

  # handle article attributes
  destination_attributes["blog_id"] = blog_ids_resolution[origin_blog_id]
  origin_attributes.each do |key, value|
    unless ['id','image','user_id'].include? key 
      destination_attributes["#{key}"] = value
    else
      if key == 'image'
        image_hash = {}
        value.instance_variables.each {|var| image_hash[var.to_s.delete("@")] = value.instance_variable_get(var)}
        image_attributes = image_hash['attributes']
        destination_attributes["image"] = image_attributes 
      end
    end
  end
  destination_article = ShopifyAPI::Article.new(destination_attributes)
  success = destination_article.save
  if success 
    total_articles_migrated += 1
  else
    failed_article_json =  destination_article.as_json
    p failed_article_json
  end
}
puts "#{total_articles_migrated} Articles successfully migrated"
