define([
  'onion/type',
  'onion/event_emitter',
  'onion/json_api',
  'jquery'
], function (
  Type,
  eventEmitter,
  JsonApi,
  $
) {

  return Type.sub("Server")

    .after("init", function () {
      this.api = new JsonApi()
    })

    .proto(eventEmitter)

    .proto({
      camelize: function (string) {
        return string.replace(/_(\w)/g, function (entire, c) {
          return c.toUpperCase()
        })
      },

      camelizeAttrs: function (attributes) {
        var camelAttributes = {}
        for ( var key in attributes ) {
          camelAttributes[this.camelize(key)] = attributes[key]
        }
        return camelAttributes
      },

      fromDataArray: function (data, Class) {
        return data.map(function (attrs) {
          return Class.newFromAttributes(this.camelizeAttrs(attrs))
        }, this)
      },

      withEventPrefix: function (prefix, callback) {
        this.emit(prefix + ":pending")
        var deferred = callback.call(this)
        deferred.done(function () { this.emit(prefix + ":done") }.bind(this))
        deferred.fail(function () { this.emit(prefix + ":fail") }.bind(this))
        return deferred
      }
    })

})

