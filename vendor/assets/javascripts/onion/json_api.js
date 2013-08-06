if(typeof define!=='function'){var define=require('amdefine')(module);}

define([
  'jquery',
  'onion/type',
  'onion/event_emitter'
], function($, Type, eventEmitter){

  return Type.sub('JsonApi')

    .proto(eventEmitter)

    .proto({
      get: function (url, data, opts) {
        return this.ajax('GET', url, data, opts)
      },

      put: function (url, data, opts) {
        return this.ajax('PUT', url, JSON.stringify(data), $.extend({processData: false}, opts))
      },

      post: function (url, data, opts) {
        return this.ajax('POST', url, JSON.stringify(data), $.extend({processData: false}, opts))
      },

      delete: function (url, data, opts) {
        return this.ajax('DELETE', url, JSON.stringify(data), $.extend({processData: false}, opts))
      },

      ajax: function (type, url, data, opts) {
        opts = $.extend({
            type: type,
            url: url,
            data: data,
            contentType: 'application/json'
          }, opts)
        return $.ajax(opts)
      }
    })

})

