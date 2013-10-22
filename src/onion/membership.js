if(typeof define!=='function'){var define=require('amdefine')(module);}

define(['onion/type', 'onion/event_emitter'], function (Type, eventEmitter) {

  return Type.sub('Membership')

    .after('init', function (item, collection) {
      this.item = item
      this.collection = collection
      this.__updateExists__()
      this.collection.on('change', this.__onCollectionChange__.bind(this))
    })

    .proto(eventEmitter)

    .proto({
      __updateExists__: function () {
        this.__exists__ = this.collection.contains(this.item)
      },

      __onCollectionChange__: function () {
        var oldExists = this.exists()
        this.__updateExists__()
        var newExists = this.exists()
        if (!oldExists && newExists) {
          this.emit('add')
        } else if (oldExists && !newExists) {
          this.emit('remove')
        }
      },

      add: function () {
        this.collection.add(this.item)
      },

      remove: function () {
        this.collection.remove(this.item)
      },

      toggle: function () {
        this.exists() ? this.remove() :this.add()
      },

      exists: function () {
        return this.__exists__
      }
    })

})
