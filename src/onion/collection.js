if(typeof define!=='function'){var define=require('amdefine')(module);}

define([
  'onion/model'
], function(Model){

  var isFunction = function (object) {
    return typeof object === 'function'
  }

  var conditionsMatch = function (item, conditions) {
    if(typeof item.attrs != 'function') return false
    var attrs = item.attrs()
    for(var key in conditions) {
      if( attrs[key] != conditions[key] ) return false
    }
    return true
  }

  return Model.sub('Collection')

    .extend({
      compare: function(a, b) {
        if(a > b) {
          return 1
        } else if(a == b) {
          return 0
        } else {
          return -1
        }
      }
    })

    .proto({
      init: function (items, opts) {
        opts = opts || {}
        if(opts.orderBy) {
          this.__comparator__ = opts.orderBy
        }

        this.__items__ = items ? (items.toArray ? items.toArray() : items.slice()) : []

        this.order()
      },

      count: function () {
        return this.__items__.length
      },

      set: function(items){
        if (items.toArray) { items = items.toArray() }
        var oldItems = this.toArray(),
            _items = this.__items__
        _items.splice.apply(_items, [0, _items.length].concat(items))
        this.order()
        this.emit('itemsRemoved', oldItems)
        this.emit('itemsAdded', items)
        this.emit('set', this.toArray())
        this.emit('change', this)
      },

      add: function(item){
        this.__items__.push(item)
        this.order()
        var index = this.__items__.indexOf(item)
        this.emit('itemsAdded', [item])
        this.emit('add', item, index)
        this.emit('change', this)
        return index
      },

      addMany: function(items) {
        if (items.toArray) { items = items.toArray() }
        var _items = this.__items__
        _items.splice.apply(_items, [_items.length, 0].concat(items))
        this.order()
        this.emit('itemsAdded', items)
        this.emit('addMany', items)
        this.emit('change', this)
      },

      remove: function(item) {
        var index = this.indexFor(item)
        if(index >= 0) {
          var removedItems = this.__items__.splice(index, 1)
          this.emit('itemsRemoved', removedItems)
          this.emit('remove', removedItems[0], index)
          this.emit('change', this)
          return true
        }

        return false
      },

      removeMany: function(items) {
        if (items.toArray) { items = items.toArray() }
        var removedItems = []
        items.forEach(function(item) {
          var index
          while((index = this.indexFor(item)) >= 0) {
            removedItems.push(this.__items__.splice(index, 1)[0])
          }
        }, this)

        if(removedItems.length > 0) {
          this.emit('itemsRemoved', removedItems)
          this.emit('removeMany', removedItems)
          this.emit('change', this)
        }
      },

      // onItem only works for items that implement
      // the "standard" on and off event interface
      onItem: function (event, callback) {
        var subscribeToItem = function (item) {
          if(typeof item.on === 'function'){
            item.on(event, callback)
          }
        }

        this.forEach(subscribeToItem)
        this.on('itemsAdded', function (items) {
          items.forEach(subscribeToItem)
        })

        this.on('itemsRemoved', function (items) {
          items.forEach(function (item) {
            if(typeof item.off === 'function'){
              item.off(event, callback)
            }
          })
        })
      },

      // Returns the index of an item, but will use isEqualTo function
      // if defined on the item.
      indexFor: function(item) {
        if(typeof item.isEqualTo === 'function') {
          for(var i = 0; i < this.__items__.length; i++) {
            if(item.isEqualTo(this.__items__[i])) {
              return i
            }
          }
          return -1
        } else {
          return this.__items__.indexOf(item)
        }
      },

      indexWhere: function(comparator) {
        for(var i = 0; i < this.__items__.length; i++) {
          var item = this.__items__[i]
          if(comparator(item)) {
            return i
          }
        }
        return -1
      },

      toArray: function(){
        return this.map(function(item){ return item })
      },

      orderBy: function(comparator) {
        this.__comparator__ = comparator
        this.order()
      },

      order: function(){
        if(this.__comparator__) this.__items__.sort(this.__comparator__)
      },

      isEmpty: function() {
        return this.__items__.length === 0
      },

      clone: function() {
        var clone = new this.constructor(this.toArray())
        clone.orderBy(this.__comparator__)
        return clone
      },

      contains: function(value) {
        return this.indexFor(value) != -1
      },

      first: function () {
        return this.__items__[0]
      },

      last: function () {
        return this.__items__[this.__items__.length-1]
      },

      forEach: function (callback, context) {
        this.__items__.forEach(callback, context)
      },

      map: function (callback, context) {
        var results = []
        this.forEach(function (a,b,c) {
          results.push(callback.call(context, a,b,c))
        })
        return results
      },

      filter: function (callback, context) {
        var results = []
        this.forEach(function (item,b,c) {
          if ( callback.call(context,item,b,c) ) results.push(item)
        })
        return results
      },

      pluck: function (attr) {
        return this.map(function (item) {
          return isFunction(item[attr]) ? item[attr]() : item[attr]
        })
      },

      // For items with an 'attrs' method (e.g. models)
      where: function (conditions) {
        return this.filter(function (item) {
          return conditionsMatch(item, conditions)
        })
      },

      removeWhere: function (conditions) {
        this.forEach(function (item) {
          if( conditionsMatch(item, conditions) ) this.remove(item)
        }, this)
      }

    })
})
