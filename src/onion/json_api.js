if(typeof define!=='function'){var define=require('amdefine')(module);}

define([
  'jquery',
  'onion/type',
  'onion/event_emitter',
  'onion/utils/extend',
  'onion/utils/object_signature'
], function($, Type, eventEmitter, extend, objectSignature){

  return Type.sub('JsonApi')

    .proto(eventEmitter)

    .proto({
      init: function (options) {
        if (!options) options = {}
        this.urlPrefix = options.urlPrefix || ""
        this.ajaxOptions = options.ajaxOptions || {}
        this.persistentParams = options.persistentParams || {}
        this.__cache__ = {}
      },

      __get__: function (url, data, options) {
        return this.ajax('GET', url, this.__addPersistentParams__(data), options)
      },

      get: function (url, data, options) {
        if( options && options.cache ) {
          var sig = objectSignature({url: url, data: data, options: options})
          return this.__cache__[sig] = this.__cache__[sig] || this.__get__(url, data, options)
        } else {
          return this.__get__(url, data, options)
        }
      },

      put: function (url, data, options) {
        return this.ajax('PUT', url, JSON.stringify(this.__addPersistentParams__(data)), options)
      },

      post: function (url, data, options) {
        return this.ajax('POST', url, JSON.stringify(this.__addPersistentParams__(data)), options)
      },

      "delete": function (url, data, options) {
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

