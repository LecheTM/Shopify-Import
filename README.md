# Shopify Import
A Ruby Shopify API console intration to help importing data for migrations from other systems

## TODO
* come up with a more dymaic wait to handle pausing (https://help.shopify.com/api/getting-started/api-call-limit) 
* have csv count lines to determine chunks of processing / get rid of hardcoding at 50 rows / products
* generate wait intervals instead of hardcoding to 20 seconds 

#---------------------- #
MIGRATIFY - config.yml 
#---------------------- #
:: store-credentials ::
MINIMUM REQUIREMENTS FOR EACH FEATURE BELOW
* See Feature Descriptions for additional needed params

PARAMS
key: the api key for the store being used, or in the case of migration, the "from" store
password: the api password for the store being used, or in the case of migration, the "from" store
name: name of the store, the '.myshopify.com' is implied (name.myshopify.com)

#------------------ #
FEATURES
#------------------ #
:: delete_products ::
* the delete_products function needs only the store_credentials

#------------------
:: export_metafields_to_csv ::
* parses a csv and posts metafields to Shopify API

PARAMS
product_count: total number of products being exported used to keep api calls from exceeding threshold

#------------------ #
:: impoprt_collections_from_csv ::
* parses a csv and posts collections to Shopify API

PARAMS
collection_count: total number of collections (rows) being imported used to keep api calls from exceeding threshold

#------------------ #
:: impoprt_metafields_from_csv ::
* parses a csv and posts metatfields to Shopify API
* TODO: needs params verified

PARAMS
collection_count: total number of collections (rows) being imported used to keep api calls from exceeding threshold

#------------------
:: impoprt_products_from_csv ::
parses csv and posts products to Shopify API

PARAMS
product_count: total number of collections (rows) being imported used to keep api calls from exceeding threshold

#------------------
:: migrate_collections_between_stores ::
* key, password, and name params for this feature mean "the store from which collections are being migrated"
* 20171109 - only does one collection at time 

PARAMS
product_count: total number of collections (rows) being imported used to keep api calls from exceeding threshold
to_collection_id: collection id of collection being migrated to
to_key: api key of private app in store being migrated to
to_password: api password of private app in store being migrated to
to_name: name of store being migrated to

#------------------
:: migrate_collects_between_stores ::
* retrieves collects corresponding to a single collection id and product titles from one store and creates corresponding 
* collects for configured collection id and product titles in another store

PARAMS
product: total number of collections (rows) being imported used to keep api calls from exceeding threshold

#------------------
:: update_products_with_tags :: 
* parses a csv and updates products by title with a single tag

PARAMS
product: total number of collections (rows) being imported used to keep api calls from exceeding threshold

#------------------
