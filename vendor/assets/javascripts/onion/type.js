if(typeof define!=='function'){var define=require('amdefine')(module)}

define(['onion/decorator', 'onion/extend', 'onion/sub'], function (decorator, extend, sub) {

  var copyOnto = function (destination, sources) {
    sources = Array.prototype.slice.call(sources) // convert "arguments" object to array
    extend.apply(null, [destination].concat(sources))
  }

  function Type(){}

  Type.sub = function(name, definition) {
    if (!name.match(/^[A-Z]\w*$/)) {
      throw "invalid name '" + name + "'"
    }
    eval("var t=function " + name + "(){if(this.init)this.init.apply(this,arguments)}")
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

  Type.use(decorator.plugin)

  return Type
})
