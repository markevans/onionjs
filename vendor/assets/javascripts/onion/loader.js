if(typeof define!=='function'){var define=require('amdefine')(module);}

define(['jquery', 'onion/type'], function($, Type){

  return Type.sub('Loader')

    .after('init', function (options) {
      if(!options) options = {}

      if(options.loaders) this.loaders = options.loaders

      this.__loaderPromises__ = {}
    })

    .proto({
      load: function (loaderName) {
        var promises = this.__loaderPromises__
        // If already cached, return the cached promise...
        if( promises[loaderName] ) {
          return promises[loaderName].promise
        // ...otherwise call it, cache and return
        } else {
          return this.__reload__.apply(this, Array.prototype.slice.call(arguments))
        }
      },

      __reload__: function (loaderName) {
        var args = Array.prototype.slice.call(arguments, 1),
            method = this.loaders[loaderName]

        if(!method) throw new Error("loader \"" + loaderName + "\" doesn't exist")

        var deferred = new $.Deferred()
        method.apply(this, [deferred].concat(args))
        var promise = deferred.promise()

        this.__loaderPromises__[loaderName] = {promise: promise}

        return promise
      }
    })

})
