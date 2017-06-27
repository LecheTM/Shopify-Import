# Shopify Import
A Ruby Shopify API console intration to help importing data for migrations from other systems

## TODO
* come up with a more dymaic wait to handle pausing (https://help.shopify.com/api/getting-started/api-call-limit) 
* have csv count lines to determine chunks of processing / get rid of hardcoding at 50 rows / products
* generate wait intervals instead of hardcoding to 20 seconds 
