if(typeof define!=='function'){var define=require('amdefine')(module);}

define(function(){

  function argumentsToArray(args, startIndex){
    return Array.prototype.slice.call(args, startIndex)
  }

  function decorate(obj, method, callback){
    var originalOwnMethod
    if(obj.hasOwnProperty(method)) originalOwnMethod = obj[method]
    var parentPrototype = Object.getPrototypeOf(obj)

    obj[method] = function(){
      var souper, args
      if(originalOwnMethod){
        souper = originalOwnMethod.bind(this)
      } else if(parentPrototype[method]) {
        souper = parentPrototype[method].bind(this)
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
