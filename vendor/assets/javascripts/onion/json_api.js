if(typeof define!=='function'){var define=require('amdefine')(module);}

define([
  'jquery',
  'onion/type',
  'onion/event_emitter',
  'onion/extend'
], function($, Type, eventEmitter, extend){

  return Type.sub('JsonApi')

    .proto(eventEmitter)

    .proto({
      init: function (options) {
        if (!options) options = {}
        this.urlPrefix = options.urlPrefix || ""
        this.ajaxOptions = options.ajaxOptions || {}
        this.persistentParams = options.persistentParams || {}
      },

      get: function (url, data, options) {
        return this.ajax('GET', url, this.__addPersistentParams__(data), options)
      },

      put: function (url, data, options) {
        return this.ajax('PUT', url, JSON.stringify(this.__addPersistentParams__(data)), options)
      },

      post: function (url, data, options) {
        return this.ajax('POST', url, JSON.stringify(this.__addPersistentParams__(data)), options)
      },

      delete: function (url, data, options) {
        return this.ajax('DELETE', url, JSON.stringify(this.__addPersistentParams__(data)), options)
      },

      ajax: function (type, url, data, options) {
        url = this.urlPrefix + url
        if(!options) options = {}
        return $.ajax($.extend({
          type: type,
          url: url,
          data: data,
          contentType: 'application/json',
          processData: (type === 'GET' ? true : false)
        }, this.ajaxOptions, options.ajaxOptions))
      },

      __addPersistentParams__: function (data) {
        return extend({}, this.persistentParams, data)
      }
    })

})

