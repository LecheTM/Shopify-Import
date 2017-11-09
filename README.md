# Migrate + Shopify = MigratifyM #
A Ruby Shopify API console intration to help importing data for migrations from other systems

- - - -
## TODO ##
- - - -
- [] delete\_products - add a dummy check / opt-in so as not to just delete all of a stores products
- [] import\_metafields\_from\_csv - add a dummy check / opt-in so as not to just delete all of a stores products
- [] come up with a more dymaic wait to handle pausing (https://help.shopify.com/api/getting-started/api-call-limit) 
- [] have csv count lines to determine chunks of processing / get rid of hardcoding at 50 rows / products
- [] generate wait intervals instead of hardcoding to 20 seconds 

- - - -
## MIGRATIFY - config.yml ##
- - - -

### PARAMS REQUIRED BY ALL FEATURES ###
- - - -
#### store-credentials #### 
**See Feature Descriptions for additional needed params**
* PARAMS
  * key: the api key for the store being used, or in the case of migration, the "from" store
  * password: the api password for the store being used, or in the case of migration, the "from" store
  * name: name of the store, the '.myshopify.com' is implied (name.myshopify.com)

### ADDITIONAL PARAMS REQUIRED BY EACH FEATURE ###
- - - -
#### delete\_products ####
**this feature only requires the store credentials so BE CAREFUL**

#### export\_metafields\_to\_csv ####
**parses a csv and posts metafields to Shopify API**
* PARAMS
  * product\_count: total number of products being exported used to keep api calls from exceeding threshold

#### impoprt\_collections\_from\_csv ####
**parses a csv and posts collections to Shopify API**
* PARAMS
  * collection\_count: total number of collections (rows) being imported used to keep api calls from exceeding threshold

#### impoprt\_metafields\_from\_csv #### 
**parses a csv and posts metatfields to Shopify API**
* PARAMS
  * collection\_count: total number of collections (rows) being imported used to keep api calls from exceeding threshold

#### impoprt\_products\_from\_csv #### 
**parses csv and posts products to Shopify API**
* PARAMS
  * product\_count: total number of collections (rows) being imported used to keep api calls from exceeding threshold

#### migrate\_collections\_between\_stores ::
**retrieves products within a single collection from one store and adds tags to smart collection in another store**
__key, password, and name params for this feature mean "the store from which collections are being migrated"__
* PARAMS
  * product\_count: total number of collections (rows) being imported used to keep api calls from exceeding threshold
  * to\_collection\_id: collection id of collection being migrated to
  * to\_key: api key of private app in store being migrated to
  * to\_password: api password of private app in store being migrated to
  * to\_name: name of store being migrated to

#### migrate\_collects\_between\_stores ####
**retrieves collects corresponding to a single collection id and product titles from one store and creates corresponding**
__collects for configured collection id and product titles in another store__
* PARAMS
  * product: total number of collections (rows) being imported used to keep api calls from exceeding threshold

#### update\_products\_with\_tags ####
**parses a csv and updates products by title with a single tag**
* PARAMS
  * product: total number of collections (rows) being imported used to keep api calls from exceeding threshold
