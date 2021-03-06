if(typeof define!=='function'){var define=require('amdefine')(module);}

define(function () {
  return function (Controller, collectionName, itemName, ItemController) {

    Controller
      .onModel(collectionName, 'itemsAdded', 'addItemChildren')
      .onModel(collectionName, 'itemsRemoved', 'removeItemChildren')

      .proto({

        syncWithCollection: function () {
          this.addItemChildren(this.selectedModels[collectionName])
        },

        addItemChildren: function (models) {
          models.forEach(this.addItemChild, this)
        },

        addItemChild: function (model) {
          this.spawnWithModel(ItemController, itemName, model)
        },

        removeItemChildren: function (models) {
          models.forEach(this.removeItemChild, this)
        },

        removeItemChild: function (model) {
          this.destroyChildWithModel(itemName, model)
        }

      })

  }

})

