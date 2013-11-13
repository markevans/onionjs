if(typeof define!=='function'){var define=require('amdefine')(module);}

define(function () {

  function Extensions () {
    this.extensions = {}
  }
  Extensions.prototype = {
    get: function (key) {
      return this.extensions[key]
    },

    set: function (key, value) {
      this.extensions[key] = value
    }
  }

  return function (Constructor) {
    Constructor

      .proto({
        extensions: function () {
          if (!this.__extensions__) this.__extensions__ = new Extensions()
          return this.__extensions__
        },

        extension: function (key) {
          return this.extensions().get(key)
        },

        setExtension: function (key, value) {
          this.extensions().set(key, value)
        }
      })
  }
})

