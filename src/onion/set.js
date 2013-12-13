if(typeof define!=='function'){var define=require('amdefine')(module);}

define([
  'onion/collection',
], function(Collection){

  return Collection.sub("Set")

    .decorate('__populateItems__', function (souper, items) {
      souper(this.__removeDuplicatesOf__(items))
    })

    .decorate('set', function (souper, items) {
      souper(this.__removeDuplicatesOf__(items))
    })

    .decorate('add', function (souper, item) {
      if(!this.contains(item)) souper(item)
    })

    .decorate('addMany', function (souper, items) {
      var itemsToAdd = this.__removeDuplicatesOf__(items).filter(function (item) {
        return !this.contains(item)
      }, this)
      souper(itemsToAdd)
    })

    .proto({

      _push: function (elem) { /* sort of protected */
        this.__items__.push(elem)
      },

      union: function (items) {
        var union = this.clone()
        union.addMany(items)
        return union
      },

      intersection: function (items) {
        var intersection = new this.constructor()
        items.forEach(function(item) {
          if(this.contains(item)) {
            intersection._push(item)
          }
        }, this)
        intersection.orderBy(this.__comparator__)
        return intersection
      },

      difference: function (items) {
        var difference = this.clone()
        difference.removeMany(items)
        return difference
      },

      __removeDuplicatesOf__: function (items) {
        return items.reduce(function (uniqueItems, elem) {
          if (!uniqueItems.contains(elem)) uniqueItems._push(elem)
          return uniqueItems
        }, new this.constructor())
      }
    })

})
