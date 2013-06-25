if(typeof define!=='function'){var define=require('amdefine')(module);}

define([
  'onion/type',
  'onion/event_emitter',
  'onion/has_uuid'
], function (Type, eventEmitter, hasUUID) {

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

      __readAttribute__: function(attr) {
        return this.__attrs__[attr]
      },

      __writeAttribute__: function(attr, value) {
        this.__attrs__[attr] = value
      },

      set: function(attr, value) {
        var attrs = {}
        attrs[attr] = value
        var changes = this.__collectChanges__(attrs)
        this.__writeAttribute__(attr, value)
        this.__notifyChanges__(changes)
        return this
      },

      setAttrs: function(attrs) {
        var changes = this.__collectChanges__(attrs)
        for(key in attrs){
          if(this.constructor.attributeNames.indexOf(key) != -1){
            this.__writeAttribute__(key, attrs[key])
          } else {
            throw new Error("unknown attribute " + key + " for " + this.constructor.name)
          }
        }
        this.__notifyChanges__(changes)
      },

      attrs: function() {
        var keys
        if(arguments.length) keys = Array.prototype.slice.apply(arguments)
        return copy({}, this.__attrs__, keys)
      },

      loadAttrs: function (attrs) {
        copy(this.__attrs__, attrs)
      },

      __collectChanges__: function (attrs) {
        var changes = {}
        var newValue, oldValue
        var attr
        for (attr in attrs) {
          newValue = attrs[attr]
          oldValue = this.__readAttribute__(attr)
          if(newValue != oldValue) {
            changes[attr] = {from: oldValue, to: newValue}
          }
        }
        return changes
      },

      __notifyChanges__: function (changes) {
        var change
        var attr
        for (attr in changes) {
          change = changes[attr]
          this.emit('change:'+attr, change)
          if (change.from == null && change.to != null) {
            this.emit('set:'+attr, change.to)
          };
          if (change.from != null && change.to == null) {
            this.emit('unset:'+attr)
          };
        }
        if (Object.keys(changes).length > 0) {
          this.emit('change')
        }
        return changes
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

      attributes: function(){
        if(!this.attributeNames) this.attributeNames = []
        var i
        for(i=0; i<arguments.length; i++){
          this.__createReader__(arguments[i])
          this.__createWriter__(arguments[i])
          this.attributeNames.push(arguments[i])
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

      __createReader__: function(attr){
        this.prototype[attr] = function(){
          return this.__readAttribute__(attr)
        }
      },

      __createWriter__: function(attr){
        var methodName = setterMethodName(attr)
        this.prototype[methodName] = function(value){
          this.set(attr, value)
          return this
        }
      },

    })

    .after('init', function(attrs){
      this.__attrs__ = {}
      this.setAttrs(attrs)
    })

})

