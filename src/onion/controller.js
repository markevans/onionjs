if(typeof define!=='function'){var define=require('amdefine')(module);}

define([
    'onion/class_declarations',
    'onion/utils/extend',
    'onion/type',
    'onion/subscriber',
    'onion/has_uuid'
  ], function(
    classDeclarations,
    extend,
    Type,
    subscriber,
    hasUUID
) {

  var isFunction = function (object) {
    return typeof object === 'function'
  }

  var toKey = function (key1, key2) {
    return [key1, key2].join(' ')
  }

  var idForControllerWithModel = function (modelName, model) {
    return 'with-model-' + modelName + '-' + model.uuid()
  }

  var matchesChild = function (queryOpts, child) {
    if (!queryOpts) return true
    if (queryOpts.type && queryOpts.type != child.type) return false
    if (queryOpts.tag && queryOpts.tag != child.tag) return false
    return true
  }

  return Type.sub('Controller')

    .use(hasUUID)

    .proto(subscriber)

    .after('init', function(models, options){
      // Options
      this.options = options || {}

      // Models
      this.models = extend({}, models)
      this.selectedModels = {}
      this.__registerModels__()
      this.__disabledModelListeners__ = {}

      // View
      this.view = this.options.view || this.initView()
      this.__setUpViewListeners__()

      // Children
      this.__children__ = {}
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
          return new ViewClass({models: this.selectedModels})
        }
        return this
      }
    })

    .proto({
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
        this.__selectModel__(name)
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
        var child = new Child(this.__mergeModels__(opts.models), opts.options)
        var id = this.__addChild__(child, opts.id, opts.tag)
        if(this.view && child.view) {
          this.view.insertChild(child.view, {
            modelName: opts.modelName,
            model: opts.model,
            tag: opts.tag,
            id: id
          })
        }
        child.run()
        return child
      },

      spawnWithModel: function(Child, modelName, model, opts) {
        if(!opts) opts = {}
        var models = opts.models || {}
        models[modelName] = model
        var id = idForControllerWithModel(modelName, model)
        return this.spawn(Child, {models: models, id: id, modelName: modelName, model: model})
      },

      destroyChildren: function (queryOpts) {
        this.__eachChild__(queryOpts, function (child) {
          this.destroyChild(child.id)
        }, this)
      },

      destroyChildWithModel: function (modelName, model) {
        var id = idForControllerWithModel(modelName, model)
        this.destroyChild(id)
      },

      destroyChild: function (id) {
        var child = this.__children__[id]
        if(child) child.controller.destroy()
        delete this.__children__[id]
      },

      // "Private"

      __mergeModels__: function(models) {
        return extend({}, this.models, models)
      },

      __addChild__: function (child, id, tag) {
        var type = child.typeName()
        if(!id) id = type + '-' + child.uuid()
        this.__children__[id] = {
          controller: child,
          tag: tag,
          id: id,
          type: type
        }
        return id
      },

      __eachChild__: function (queryOpts, callback, context) {
        for(var id in this.__children__) {
          var child = this.__children__[id]
          if( matchesChild(queryOpts, child) ) {
            callback.call(context, child)
          }
        }
      },

      __registerModels__: function(){
        var requiredModels = this.constructor.__requiredModels__
        if(!requiredModels) { return }
        for(var i=0; i<requiredModels.length; i++){
          this.__selectModel__(requiredModels[i])
        }
      },

      __selectModel__: function (modelName) {
        var name, model, matches
        if ( matches = modelName.match(/^(.*)\.(.*)$/) ) {
          var parent = this.models[matches[1]]
          name = matches[2]
          model = isFunction(parent[name]) ? parent[name]() : parent[name]
        } else {
          model = this.models[modelName]
          name = modelName
        }
        if(typeof model !== 'undefined'){
          this[name] = model
          this.selectedModels[name] = model
          this.__createModelSubscriptionsFor__(name)
        } else {
          throw new Error(this.typeName()+" missing model "+name)
        }
      },

      __createModelSubscriptionsFor__: function (modelName) {
        this.constructor.onModelSubscriptions(modelName).forEach(function (sub) {
          this.subscribe(this.selectedModels[modelName], sub.eventName, function () {
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

