if(typeof define!=='function'){var define=require('amdefine')(module);}

define(function () {
  return function (Controller, collectionName, itemName, itemController) {

    Controller
      .onModel(collectionName, 'itemsAdded', 'addItemChildren')
      .onModel(collectionName, 'itemsRemoved', 'removeItemChildren')
      .onModel(collectionName, 'set', 'setItemChildren')

      .proto({

        setItemChildren: function () {
          this.destroyChild(collectionName)
          this.addItemChildren(this.models[collectionName])
        },

        addItemChildren: function (models) {
          models.forEach(this.addItemChild, this)
        },

        addItemChild: function (model) {
          var extraModels = {}
          extraModels[itemName] = model
          this.setChild([collectionName, model.mid()], itemController, extraModels)
        },

        removeItemChildren: function (models) {
          models.forEach(this.removeItemChild, this)
        },

        removeItemChild: function (model) {
          this.destroyChild([collectionName, model.mid()])
        }

      })

  }

})
