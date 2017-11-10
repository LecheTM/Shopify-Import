# Migrate + Shopify = Migratify #
A Ruby / Shopify API console integration to help importing data in and out of Shopify stores
- - - -

## TODO ##
- [ ] (all rb) softcode values across all scripts; make it cl input for now
- [ ] (all rb) abstract chunking functionality for includion in scripts
- [ ] (most rb) review chunking so that not a hardcoded guess on how long interval is needed not to exceed the Shopify API rate 
- [ ] delete\_products - add a dummy check / opt-in so as not to just delete all of a stores products
- [ ] delete\_products - is there a more efficient way the get all products, go one at a time? api rate limit? 
- [ ] export\_metafields\_to\_csv - make retrieval of metafields names to be exported dynamic 
- [ ] import\_metafields\_from\_csv - add a dummy check / opt-in so as not to just delete all of a stores products
- [ ] create shopify\_app gem to handle (architecture / control structure, OAuth, store integration, frontend)
- - - -

## MIGRATIFY - config.yml ##

### PARAMS REQUIRED BY ALL FEATURES ###
*all params are namespace by 'store-credentials'*
* PARAMS
  * key: the api key for the store being used, or in the case of migration, the "from" store
  * password: the api password for the store being used, or in the case of migration, the "from" store
  * name: name of the store, the '.myshopify.com' is implied (name.myshopify.com)

### ADDITIONAL PARAMS REQUIRED BY EACH FEATURE ###
#### :: delete\_products :: ####
*this feature only requires the store credentials so BE CAREFUL*

#### :: export\_metafields\_to\_csv ::  ####
*parses a csv and posts metafields to Shopify API*
* PARAMS
  * product\_count: total number of products being exported used to keep api calls from exceeding threshold

#### :: impoprt\_collections\_from\_csv :: ####
*parses a csv and posts collections to Shopify API*
* PARAMS
  * collection\_count: total number of collections (rows) being imported used to keep api calls from exceeding threshold

#### :: impoprt\_metafields\_from\_csv :: #### 
*parses a csv and posts metatfields to Shopify API*
* PARAMS
  * collection\_count: total number of collections (rows) being imported used to keep api calls from exceeding threshold

#### :: impoprt\_products\_from\_csv :: #### 
*parses csv and posts products to Shopify API*
* PARAMS
  * product\_count: total number of collections (rows) being imported used to keep api calls from exceeding threshold

#### :: migrate\_collections\_between\_stores :: ####
*retrieves products within a single collection from one store and adds tags to smart collection in another store*
*key, password, and name params for this feature mean "the store from which collections are being migrated"*
* PARAMS
  * product\_count: total number of collections (rows) being imported used to keep api calls from exceeding threshold
  * to\_collection\_id: collection id of collection being migrated to
  * to\_key: api key of private app in store being migrated to
  * to\_password: api password of private app in store being migrated to
  * to\_name: name of store being migrated to

#### :: migrate\_collects\_between\_stores :: ####
*retrieves collects corresponding to a single collection id and product titles from one store and creates corresponding*
*collects for configured collection id and product titles in another store*
* PARAMS
  * product: total number of collections (rows) being imported used to keep api calls from exceeding threshold

#### :: update\_products\_with\_tags :: ####
*parses a csv and updates products by title with a single tag*
* PARAMS
  * product: total number of collections (rows) being imported used to keep api calls from exceeding threshold
