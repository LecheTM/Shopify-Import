# marry data exported from origin db / ecomm / cvs (nexternal) to import for shopify
# import_metafields.YYYYMMDD.csv

require 'csv'
require 'fileutils'

# open / create destination csv for final import 
CSV.open("csv/import_metafields.20170710.csv", "wb") do |csv_out|

  CSV.foreach('csv/shopping.20160706.compare.csv', :headers => true) do |row|

    nexternal_id = row['Unique Merchant SKU']
    price = row['Current Price']
    related_ids_nexternal = row['Related Products']

    related_ids_nexternal_arr = []
    unless related_ids_nexternal.nil? 
      related_ids_nexternal_arr = related_ids_nexternal.split(",")
    end
    related_handles_shopify_arr = []

    # related_products nexternal to shopify id conversion
    related_ids_nexternal_arr.each { |related_id|
      related_id_clean = related_id.strip
      CSV.foreach('csv/export_metafields.20170709.csv', :headers => true).with_index do |import_row, i|
        nid = import_row['nexternal_id']
        if import_row['nexternal_id'] == related_id_clean
          related_handles_shopify_arr.push(import_row['handle'])
        end
      end
    }

    # append actual price and related (shopify) ids to import_metafields.YYYYMMDD.csv
    found = 0
    CSV.foreach('csv/export_metafields.20170709.csv', :headers => true).with_index do |import_row, i|
      if import_row['nexternal_id'] == nexternal_id 
        found = 1
	import_row['price'] = price
        related_handles_shopify = related_handles_shopify_arr.join(",")
        import_row['related_handles'] = related_handles_shopify
	csv_out << import_row
      end
    end
    if found == 0
      puts "didn't find match for #{nexternal_id}"
    end
  end

end
