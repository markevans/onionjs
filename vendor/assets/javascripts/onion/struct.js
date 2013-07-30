if(typeof define!=='function'){var define=require('amdefine')(module);}

define([
  'onion/type',
  'onion/event_emitter',
  'onion/collection',
  'onion/has_uuid'
], function(Type, eventEmitter, Collection, hasUUID){

  function setterMethodName(attributeName){
    return 'set' + attributeName.replace(/./, function(ch){ return ch.toUpperCase() })
  }

  function copy(dest, src, keys){
    var key
    for(key in src){
      if(keys && (keys.indexOf(key) == -1)) continue
      if(src.hasOwnProperty(key)){
        dest[key] = src[key]
      }
    }
    return dest
  }

  return Type.sub('Struct')

    .use(hasUUID)

    .proto(eventEmitter)

    .proto({

      __get__: function(attr){
        return this.__attrs__[attr]
      },

      setAttrs: function(attrs){
        var key, methodName
        for(key in attrs){
          methodName = setterMethodName(key)
          if(this[methodName]){
            this[methodName](attrs[key])
          } else {
            throw new Error("unknown attribute " + key + " for " + this.constructor.name)
          }
        }
      },

      attrs: function(){
        var keys
        if(arguments.length) keys = Array.prototype.slice.apply(arguments)
        return copy({}, this.__attrs__, keys)
      },

      loadAttrs: function (attrs) {
        copy(this.__attrs__, attrs)
      },

      set: function(attr, value){
        var from = this.__get__(attr)
        if(from != value) {
          this.__attrs__[attr] = value
          this.emit('change:'+attr, {from: from, to: value})
          this.emit('change')
          if (from == null && value != null) {
            this.emit('set:'+attr, value)
          };
          if (from != null && value == null) {
            this.emit('unset:'+attr)
          };

        }

        return this
      },

      setDefaults: function (attrs) {
        for (var key in attrs) {
          if (this[key]() === undefined) {
            this[setterMethodName(key)](attrs[key])
          }
        }
      }
    })

    .extend({

      load: function (attrs) {
        var instance = new this()
        instance.loadAttrs(attrs)
        return instance
      },

      instances: function() {
        if(!this.__instances__) {
          this.__instances__ = new Collection()
        }

        return this.__instances__
      },

      attributes: function(){
        if(!this.attributeNames) this.attributeNames = []
        var i
        for(i=0; i<arguments.length; i++){
          this.createReader(arguments[i])
          this.createWriter(arguments[i])
          this.attributeNames.push(arguments[i])
        }
        return this
      },

      collection: function(name, options){
        var privateName = '__'+name+'__'
        options = options || {}
        var type = options.type || Collection

        // Reader
        this.prototype[name] = function(){
          if(!this[privateName]){
            this[privateName] = new type()
            if(options.orderBy){ this[privateName].orderBy(options.orderBy) }
          }
          return this[privateName]
        }

        // Writer
        this.prototype[setterMethodName(name)] = function(items){
          this[name]().set(items)
          this.emit('change:' + name)
        }

        return this
      },

      decorateWriter: function (attribute, decorator, options) {
        var includeNull = !!(options && options.includeNull)
        this.decorate(setterMethodName(attribute), function (setter, value) {
          setter((includeNull || value != null) ? decorator(value) : value)
        })
        return this
      },

      createReader: function(attr){
        this.prototype[attr] = function(){
          return this.__get__(attr)
        }
      },

      createWriter: function(attr){
        var methodName = setterMethodName(attr)
        this.prototype[methodName] = function(value){
          this.set(attr, value)
          return this
        }
      },

    })

    .after('init', function(attrs){
      this.constructor.instances().add(this)
      this.__attrs__ = {}
      this.setAttrs(attrs)
    })

})
