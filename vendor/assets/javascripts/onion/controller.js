if(typeof define!=='function'){var define=require('amdefine')(module);}

define([
    'onion/class_declarations',
    'onion/extend',
    'onion/type',
    'onion/subscriber',
    'onion/uuid'
  ], function(
    classDeclarations,
    extend,
    Type,
    subscriber,
    uuid
) {

  var isFunction = function (object) {
    return typeof object === 'function'
  }

  var toKey = function (key1, key2) {
    return [key1, key2].join(' ')
  }

  return Type.sub('Controller')

    .proto(subscriber)

    .after('init', function(models, opts){
      if(!opts) opts = {}

      // UUID
      this.__uuid__ = uuid()

      // Models
      this.models = extend({}, models)
      this.__registerModels__()
      this.__disabledModelListeners__ = {}

      // View
      this.view = opts.view || this.initView()
      this.__setUpViewListeners__()

      // Children
      this.__children__ = []
    })

    .use(classDeclarations, 'onView')

    .extend({
      models: function(){
        if(!this.__requiredModels__) this.__requiredModels__ = []
        var arg
        for(var i=0; i<arguments.length; i++){
          var modelName = arguments[i]
          if(this.__requiredModels__.indexOf(modelName) == -1){
            this.__requiredModels__.push(modelName)
          }
        }
        return this
      },

      onModelSubscriptions: function(modelName){
        if(!this.__onModelSubscriptions__) this.__onModelSubscriptions__ = {}
        if(!this.__onModelSubscriptions__[modelName]) this.__onModelSubscriptions__[modelName] = []
        return this.__onModelSubscriptions__[modelName]
      },

      onModel: function(modelName, eventNames, callbackOrMethodName){
        if(typeof eventNames === 'string') eventNames = [eventNames]
        eventNames.forEach(function (eventName) {
          this.onModelSubscriptions(modelName).push({
            eventName: eventName,
            callbackOrMethodName: callbackOrMethodName
          })
        }, this)
        return this
      },

      view: function (ViewClass) {
        this.prototype.initView = function () {
          return new ViewClass({models: this.models})
        }
        return this
      }
    })

    .proto({
      uuid: function () {
        return this.__uuid__
      },

      destroy: function(){
        this.unsubscribeAll()
        this.destroyChildren()
        if(this.view && this.view.destroy) this.view.destroy()
      },

      run: function(){
        // Override me
      },

      // Models

      newModel: function(name, model){
        this.models[name] = model
        this[name] = model
        this.__createModelSubscriptionsFor__(name)
        return model
      },

      disableModelListener: function (modelName, eventName) {
        this.__disabledModelListeners__[toKey(modelName, eventName)] = true
      },

      enableModelListener: function (modelName, eventName) {
        delete this.__disabledModelListeners__[toKey(modelName, eventName)]
      },

      disablingModelListener: function (modelName, eventName, callback) {
        this.disableModelListener(modelName, eventName)
        callback.call(this)
        this.enableModelListener(modelName, eventName)
      },

      // Views

      initView: function () {
        // Override me
      },

      onView: function (event, handler) {
        if (!this.view) {
          throw new Error("there is no view to subscribe to")
        }
        var callback = this.__callbackFrom__(handler)
        this.subscribe(this.view, event, callback)
      },

      appendTo: function(element){
        this.view.appendTo(element)
        return this
      },

      attachTo: function(element){
        this.view.attachTo(element)
        return this
      },

      // Children

      spawn: function(Child, opts) {
        if(!opts) opts = {}
        var child = this.__newChild__(Child, opts.models)
        this.__children__.push({
          controller: child,
          type: child.constructor.name
        })
        this.view.insertChild(child.view)
        child.run()
        return child
      },

      spawnWithModel: function(Child, modelName, model, opts) {
        if(!opts) opts = {}
        var models = opts.models || {}
        models[modelName] = model
        return this.spawn(Child, {models: models})
      },

      destroyChildren: function (opts) {
        if(!opts) opts = {}
        var remainingChildren = []
        this.__children__.forEach(function (params, i) {
          if(!opts.type || opts.type == params.type) {
            params.controller.destroy()
          } else {
            remainingChildren.push(params)
          }
        }, this)
        this.__children__ = remainingChildren
      },

      // "Private"

      __newChild__: function(ctor, models){
        var childModels = extend({}, this.models, models)
        return new ctor(childModels)
      },

      __registerModels__: function(){
        var requiredModels = this.constructor.__requiredModels__
        if(!requiredModels) { return }

        var name
        for(var i=0; i<requiredModels.length; i++){
          name = requiredModels[i]
          if(typeof this.models[name] !== 'undefined'){
            this[name] = this.models[name]
            this.__createModelSubscriptionsFor__(name)
          } else {
            throw new Error(this.constructor.name+" missing model "+name)
          }
        }
      },

      __createModelSubscriptionsFor__: function(modelName){
        this.constructor.onModelSubscriptions(modelName).forEach(function (sub) {
          this.subscribe(this.models[modelName], sub.eventName, function () {
            var callback = this.__callbackFrom__(sub.callbackOrMethodName)
            if (this.__isModelListenerEnabled__(modelName, sub.eventName)) {
              callback.apply(this, arguments)
            }
          })
        }, this)
      },

      __isModelListenerEnabled__: function (modelName, eventName) {
        return !this.__disabledModelListeners__[toKey(modelName, eventName)]
      },

      __setUpViewListeners__: function () {
        this.__applyClassDeclarations__('onView')
      },

      __callbackFrom__: function (callbackOrMethodName) {
        if( isFunction(callbackOrMethodName) ) {
          return callbackOrMethodName
        } else {
          var callback = this[callbackOrMethodName]
          if(!callback) throw new Error("Can't find method '"+callbackOrMethodName+"'")
          return callback
        }
      }

    })

})

