define([
  'onion/type',
  'onion/serializer',
  'jquery',
  'onion/vendor/jquery.hashchange',
  'onion/plugins/class_declarations',
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
        var hash = this.serializer.serialize(name, params)
        this.__hashFromUpdateUrl__ = hash
        this.setHash(hash)
      },

      processUrl: function () {
        var hash = this.hash()
        if (hash != this.__hashFromUpdateUrl__) {
          var result = this.serializer.deserialize(hash)
          if (result) this.emit('route', result.name, result.params)
        }
        this.__hashFromUpdateUrl__ = null
      },

      route: function (options) {
        this.serializer.serializeRule(options.name, options.serialize)
        this.serializer.deserializeRule(options.pattern, options.name, options.deserialize)
      }

    })

})
