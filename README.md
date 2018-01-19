# Migrate + Shopify = Migratify #
A Ruby / Shopify API console integration to migrate data between stores 
- - - -

## TODO ##
- [ ] softcode config file pickup
- [ ] this is a test for gitflow-github use
- [ ] (all rb) softcode values across all scripts; make it cl input for now
- [ ] (all rb) abstract chunking functionality for includion in scripts
- [ ] (most rb) review chunking so that not a hardcoded guess on how long interval is needed not to exceed the Shopify API rate 
- [ ] migrate\_metafields - assuming this should be called from each distrinct script, where an object allows metafields
- [ ] migrate\_blogs
- [ ] migrate\_blogs_posts
- [ ] migrate\_manutal\_collections
- [ ] delete\_products - add a dummy check / opt-in so as not to just delete all of a stores products
- [ ] delete\_products - is there a more efficient way the get all products, go one at a time? api rate limit? 
- [ ] export\_metafields\_to\_csv - make retrieval of metafields names to be exported dynamic 
- [ ] import\_metafields\_from\_csv - add a dummy check / opt-in so as not to just delete all of a stores products
- [ ] create shopify\_app gem to handle (architecture / control structure, OAuth, store integration, frontend)
- [ ] create feature to migrate settings content
- [ ] add conditionals to erase or update objects (collections, blogs, articles, pages)
- [ ] add opt in to update or overwrite existing objects (collections, blogs, articles, pages)
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
* ADDITIONAL PARAMS
  * product\_count: total number of products being exported used to keep api calls from exceeding threshold

#### :: impoprt\_metafields\_from\_csv :: #### 
*parses a csv and posts metatfields to Shopify API*
* ADDITIONAL PARAMS
  * collection\_count: total number of collections (rows) being imported used to keep api calls from exceeding threshold

#### :: migrate\_articles :: ####
*retrieves articles from origin store, creates corresponding smart collections with in destination store*
*key, password, and name params for this feature mean "the origin store from which articles are being migrated"*
* ADDTIONAL PARAMS
  * destination\_key: api key of private app in store being migrated to
  * destination\_password: api password of private app in store being migrated to
  * destination\_name: name of store being migrated to
#### :: migrate\_blogs :: ####
*retrieves blogs from origin store, creates corresponding blogs in destination store*
*key, password, and name params for this feature mean "the origin store from which blogs are being migrated"*
* ADDITIONAL PARAMS
  * destination\_key: api key of private app in store being migrated to
  * destination\_password: api password of private app in store being migrated to
  * destination\_name: name of store being migrated to
#### :: migrate\_pages :: ####
*retrieves smart pages, creates corresponding pages in destination store*
*key, password, and name params for this feature mean "the origin store from which pages are being migrated"*
* ADDITIONAL PARAMS
  * destination\_key: api key of private app in store being migrated to
  * destination\_password: api password of private app in store being migrated to
  * destination\_name: name of store being migrated to
#### :: migrate\_smart\_collections :: ####
*retrieves smart collections from origin store, creates corresponding smart collections with rules in destination store*
*key, password, and name params for this feature mean "the origin store from which collections are being migrated"*
* ADDITIONAL PARAMS
  * destination\_key: api key of private app in store being migrated to
  * destination\_password: api password of private app in store being migrated to
  * destination\_name: name of store being migrated to
