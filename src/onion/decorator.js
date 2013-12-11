if(typeof define!=='function'){var define=require('amdefine')(module);}

define(function(){

  function argumentsToArray(args, startIndex){
    return Array.prototype.slice.call(args, startIndex)
  }

  function decorate(obj, method, callback){
    var originalMethod = obj[method]

    obj[method] = function(){
      var souper, args
      if(originalMethod){
        souper = originalMethod.bind(this)
      }
      args = [souper].concat(argumentsToArray(arguments))
      return callback.apply(this, args)
    }
  }

  function before(obj, method, callback){
    decorate(obj, method, function(souper){
      if (typeof callback === 'string') callback = obj[callback]
      var args = argumentsToArray(arguments, 1)
      callback.apply(this, args)
      if(souper){ return souper.apply(this, args) }
    })
  }

  function after(obj, method, callback){
    decorate(obj, method, function(souper){
      if (typeof callback === 'string') callback = obj[callback]
      var args = argumentsToArray(arguments, 1)
      var returnValue
      if(souper) returnValue = souper.apply(this, args)
      callback.apply(this, args)
      return returnValue
    })
  }

  function plugin(ctor){
    ctor.decorate = function(method, callback){
      decorate(this.prototype, method, callback)
      return this
    }

    ctor.before = function(method, callback){
      before(this.prototype, method, callback)
      return this
    }

    ctor.after = function(method, callback){
      after(this.prototype, method, callback)
      return this
    }
  }

  return {
    plugin: plugin,
    decorate: decorate,
    before: before,
    after: after
  }
})
