if(typeof define!=='function'){var define=require('amdefine')(module)}

define(['onion/decorator', 'onion/utils/extend', 'onion/sub'], function (decorator, extend, sub) {

  var copyOnto = function (destination, sources) {
    sources = Array.prototype.slice.call(sources) // convert "arguments" object to array
    extend.apply(null, [destination].concat(sources))
  }

  function Type(){}

  Type.sub = function(name, definition) {
    if (!name.match(/^[A-Z]\w*$/)) {
      throw "invalid name '" + name + "'"
    }
    var t
    try {
      eval("t=function " + name + "(){if(this.init)this.init.apply(this,arguments)}")
    }
    catch(e) {
      // Eval failed, probably because a CSP doesn't allow it,
      // proceed with a standard anonymous function.
      // Disadvantage: `t.constructor.name` will be "Function"
      // (or similar), instead of the actual name we gave to the type
      t = function(){if(this.init)this.init.apply(this,arguments)}
    }
    sub(t, this)
    if (definition) definition.call(t, t)
    return t
  }

  Type.use = function () {
    var plugin = arguments[0]
    arguments[0] = this
    plugin.apply(null, arguments)
    return this
  }

  Type.extend = function () {
    copyOnto(this, arguments)
    return this
  }

  Type.proto = function () {
    copyOnto(this.prototype, arguments)
    return this
  }

  Type.prototype.extend = function () {
    copyOnto(this, arguments)
    return this
  }

  Type.prototype.typeName = function () {
    return this.constructor.name
  }

  Type.use(decorator.plugin)

  return Type
})
