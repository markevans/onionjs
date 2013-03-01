if(typeof define!=='function'){var define=require('amdefine')(module);}

define(function(){
  return function (ctor, methodName) {

    ctor[methodName] = function () {
      var args = Array.prototype.slice.call(arguments)
      if(!this.__classDeclarations__) this.__classDeclarations__ = {}
      if(!this.__classDeclarations__[methodName]) this.__classDeclarations__[methodName] = []
      this.__classDeclarations__[methodName].push(args)
      return this
    }

    ctor.prototype.__applyClassDeclarations__ = function (methodName) {
      var classDeclarations = this.constructor.__classDeclarations__ && this.constructor.__classDeclarations__[methodName]
      if(!classDeclarations) return
      var self = this
      classDeclarations.forEach(function (args) {
        self[methodName].apply(self, args)
      })
    }

  }
})
