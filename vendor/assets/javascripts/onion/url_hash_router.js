define([
  'onion/router',
  'jquery',
  'onion/vendor/jquery.hashchange'
], function (Router, $) {

  return Router.sub('UrlHashRouter')

    .after('init', function () {
      $(window).hashchange( this.sync.bind(this) )
    })

    .proto({

      // Firefox seems to act differently to Chrome when using location.hash
      hash: function () {
        var matches = window.location.href.match(/#(.*)$/)
        return matches ? matches[1] : ""
      },

      setHash: function (hash) {
        // Need to test this in IE7
        window.location.hash = hash
      },

      update: function (name, params) {
        this.setHash(this.path(name, params))
      },

      sync: function () {
        this.process(this.hash())
      }

    })

})

