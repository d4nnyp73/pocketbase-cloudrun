/// <reference path="../pb_data/types.d.ts" />
migrate((app) => {
  const collection = app.findCollectionByNameOrId("pbc_2423026953")

  // update collection data
  unmarshal({
    "listRule": "@request.auth.id = user_id && is_favorite = true"
  }, collection)

  return app.save(collection)
}, (app) => {
  const collection = app.findCollectionByNameOrId("pbc_2423026953")

  // update collection data
  unmarshal({
    "listRule": null
  }, collection)

  return app.save(collection)
})
