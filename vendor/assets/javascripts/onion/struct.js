if(typeof define!=='function'){var define=require('amdefine')(module);}

define([
  'onion/type',
  'onion/event_emitter',
  'onion/has_uuid'
], function (Type, eventEmitter, hasUUID) {

  function setterMethodName (attributeName) {
    return 'set' + attributeName.replace(/./, function(ch){ return ch.toUpperCase() })
  }

  function copy (dest, src, keys) {
    var key
    for(key in src){
      if(keys && (keys.indexOf(key) == -1)) continue
      if(src.hasOwnProperty(key)){
        dest[key] = src[key]
      }
    }
    return dest
  }

  function containsAnyOfKeys (obj, keys) {
    for(var i = 0; i < keys.length; i++) {
      if (obj.hasOwnProperty(keys[i]) ) { return true }
    }
    return false
  }

  return Type.sub('Struct')

    .use(hasUUID)

    .proto(eventEmitter)

    .proto({

      __readAttribute__: function(attr) {
        return this.__attrs__[attr]
      },

      __writeAttribute__: function(attr, value) {
        var decorator = this.__writerDecoratorFor__(attr)
        if (decorator) {
          var ignoreDecorator = value === null && decorator.options.includeNull != true
          if (!ignoreDecorator) {
            value = decorator.func(value)
          }
        }
        this.__attrs__[attr] = value
      },

      __writerDecoratorFor__: function (attribute) {
        var decorators = this.constructor.__writerDecorators__
        return decorators && decorators[attribute]
      },

      set: function(name, value) {
        var attrs = {}
        attrs[name] = value
        this.setAttrs(attrs)
      },

      setAttrs: function(attrs) {
        var changes = this.__collectChanges__(attrs)
        this.__addChangesToRelatedAttrs__(changes)
        this.__writeChanges__(changes)
        this.__notifyChanges__(changes)
      },

      attrs: function() {
        var keys
        if(arguments.length) keys = Array.prototype.slice.apply(arguments)
        return copy({}, this.__attrs__, keys)
      },

      __collectChanges__: function (attrs) {
        var changes = {}
        for (var attr in attrs) {
          this.__addToChanges__(changes, attr, attrs[attr])
        }
        return changes
      },

      __addToChanges__: function (changes, attr, newValue) {
        var oldValue = this.__readAttribute__(attr)
        if(newValue !== oldValue) {
          changes[attr] = {from: oldValue, to: newValue}
        }
      },

      __addChangesToRelatedAttrs__: function (changes) {
        var attr, change, relation
        var relations = this.constructor.__attributeRelations__
        if(!relations) return
        for (attr in relations) {
          relation = relations[attr]
          if (containsAnyOfKeys(changes, relation.attributes)) {
            var otherValues = relation.attributes.map(function (otherAttr) {
              return changes[otherAttr] ? changes[otherAttr].to : this.__readAttribute__(otherAttr)
            }, this)
            this.__addToChanges__(changes, attr, relation.relationFunction.apply(this, otherValues))
          }
        }
      },

      __writeChanges__: function (changes) {
        for(var key in changes){
          if(this.constructor.attributeNames.indexOf(key) === -1){
            throw new Error("unknown attribute " + key + " for " + this.constructor.name)
          }
          this.__writeAttribute__(key, changes[key].to)
        }
      },

      __notifyChanges__: function (changes) {
        var change, attr
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

      attributes: function () {
        if(!this.attributeNames) this.attributeNames = []
        var i
        for(i=0; i<arguments.length; i++){
          this.__createReader__(arguments[i])
          this.__createWriter__(arguments[i])
          this.attributeNames.push(arguments[i])
        }
        return this
      },

      relateAttributes: function (attribute, otherAttributes, relation) {
        if(!this.__attributeRelations__) this.__attributeRelations__ = {}
        this.__attributeRelations__[attribute] = {
          attributes: otherAttributes,
          relationFunction: relation
        }
        return this
      },

      decorateWriter: function (attribute, decorator, options) {
        if(!this.__writerDecorators__) this.__writerDecorators__ = {}
        this.__writerDecorators__[attribute] = {func: decorator, options: (options || {})}
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

