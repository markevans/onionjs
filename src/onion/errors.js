if(typeof define!=='function'){var define=require('amdefine')(module);}

define(['onion/type'], function(Type){
  return Type.sub('Errors')
    .proto({
      init: function() {
        this.__errors__ = {}
      },

      add: function(field, message) {
        if(!this.__errors__[field]) {
          this.__errors__[field] = []
        }
        this.__errors__[field].push(message)
      },

      get: function(field) {
        return this.__errors__[field] || []
      },
      
      isEmpty: function() {
        return Object.keys(this.__errors__).length == 0
      },

      forEach: function(callback) {
        Object.keys(this.__errors__).forEach(function(field) {
          callback(field, this.__errors__[field])
        }.bind(this))
      }
    })
})
