if(typeof define!=='function'){var define=require('amdefine')(module);}

define([
  'onion/collection',
  'onion/decorator',
  'onion/extend',
  'onion/sub'
], function(Collection, decorator, extend, sub){

  var removeDuplicates = function (items) {
    return items.reduce(function (uniqueItems, elem) {
      if (!uniqueItems.contains(elem)) uniqueItems.push(elem)
      return uniqueItems
    }, new Set())
  }

  function Set(items, opts){
    Collection.call(this, items, opts)
  }

  sub(Set, Collection)

  decorator.decorate(Set.prototype, '__initItems__', function (__initItems__, items) {
    __initItems__(removeDuplicates(items))
  })

  decorator.decorate(Set.prototype, 'set', function (set, items) {
    set(removeDuplicates(items))
  })

  decorator.decorate(Set.prototype, 'add', function (add, item) {
    if(!this.contains(item)) add(item)
  })

  decorator.decorate(Set.prototype, 'addMany', function (addMany, items) {
    var itemsToAdd = removeDuplicates(items).filter(function (item) {
      return !this.contains(item)
    }, this)
    addMany(itemsToAdd)
  })

  extend(Set.prototype, {

    intersection: function (items) {
      var intersection = new Set()
      items.forEach(function(item) {
        if(this.contains(item)) {
          intersection.push(item)
        }
      }, this)
      intersection.orderBy(this.__comparator__)
      return intersection
    },

    difference: function (items) {
      var difference = this.clone()
      difference.removeMany(items)
      return difference
    }

  })

  return Set
})
