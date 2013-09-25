define([
  'onion/type',
  'onion/serializer',
  'jquery',
  'onion/vendor/jquery.hashchange',
  'onion/class_declarations',
  'onion/event_emitter'
], function (Type, Serializer, $, _, classDeclarations, eventEmitter) {

  return Type.sub('UrlHashRouter')

    .proto(eventEmitter)

    .use(classDeclarations, 'route')

    .after('init', function () {
      this.serializer = new Serializer()
      $(window).hashchange( this.processUrl.bind(this) )
      this.__applyClassDeclarations__('route')
    })

    .proto({

      // Firefox seems to act differently to Chrome when using location.hash
      hash: function () {
        var matches = window.location.href.match(/#(.*)$/)
        return matches ? window.decodeURI(matches[1]) : ""
      },

      setHash: function (hash) {
        // Need to test this in IE7
        window.location.hash = window.encodeURI(hash)
      },

      updateUrl: function (name, params) {
        this.setHash(this.serializer.serialize(name, params))
      },

      processUrl: function () {
        var result = this.serializer.deserialize(this.hash())
        if (result) this.emit('route', result.name, result.params)
      },

      route: function (options) {
        this.serializer.serializeRule(options.name, options.serialize)
        this.serializer.deserializeRule(options.pattern, options.name, options.deserialize)
      }

    })

})
