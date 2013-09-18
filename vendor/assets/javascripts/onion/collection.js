if(typeof define!=='function'){var define=require('amdefine')(module);}

define([
  'onion/extend',
  'onion/sub',
  'onion/event_emitter',
  'onion/type',
  'onion/membership',
  'onion/has_uuid'
], function(extend, sub, eventEmitter, Type, Membership, hasUUID){

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

  function Collection(){
    this.init.apply(this, arguments)
  }

  sub(Collection, Array)

  extend(Collection, Type)

  return Collection
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

    .use(hasUUID)

    .proto(eventEmitter)

    .proto({
      init: function (items, opts) {
        opts = opts || {}
        if(opts.orderBy) {
          this.__comparator__ = opts.orderBy
        }

        if(items) this.__initItems__(items)
      },

      __initItems__: function (items) {
        this.push.apply(this, Array.prototype.slice.call(items))
        this.order()
      },

      set: function(items){
        if(items.toArray){ items = items.toArray() }
        var oldItems = this.toArray()
        this.splice.apply(this, [0, this.length].concat(items))
        this.order()
        this.emit('itemsRemoved', oldItems)
        this.emit('itemsAdded', items)
        this.emit('set', this.toArray())
        this.emit('change', this)
      },

      add: function(item){
        this.push(item)
        this.order()
        var index = this.indexOf(item)
        this.emit('itemsAdded', [item])
        this.emit('add', item, index)
        this.emit('change', this)
        return index
      },

      addMany: function(items) {
        var itemsArray = Array.prototype.slice.call(items)
        this.splice.apply(this, [this.length, 0].concat(itemsArray))
        this.order()
        this.emit('itemsAdded', items)
        this.emit('addMany', items)
        this.emit('change', this)
      },

      remove: function(item) {
        var index = this.indexFor(item)
        if(index >= 0) {
          var removedItems = this.splice(index, 1)
          this.emit('itemsRemoved', removedItems)
          this.emit('remove', removedItems[0], index)
          this.emit('change', this)
          return true
        }

        return false
      },

      removeMany: function(items) {
        var itemsArray = Array.prototype.slice.call(items)
        var removedItems = []
        itemsArray.forEach(function(item) {
          var index
          while((index = this.indexFor(item)) >= 0) {
            removedItems.push(this.splice(index, 1)[0])
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

      membershipFor: function (item) {
        return new Membership(item, this)
      },

      // Returns the index of an item, but will use isEqualTo function
      // if defined on the item.
      indexFor: function(item) {
        if(typeof item.isEqualTo === 'function') {
          for(var i = 0; i < this.length; i++) {
            if(item.isEqualTo(this[i])) {
              return i
            }
          }
          return -1
        } else {
          return this.indexOf(item)
        }
      },

      indexWhere: function(comparator) {
        for(var i = 0; i < this.length; i++) {
          var item = this[i]
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
        if(this.__comparator__) this.sort(this.__comparator__)
      },

      isEmpty: function() {
        return this.length === 0
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
        return this[0]
      },

      last: function () {
        return this[this.length-1]
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
