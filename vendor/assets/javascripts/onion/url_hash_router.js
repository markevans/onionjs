define([
  'onion/router',
  'jquery',
  'onion/vendor/jquery.hashchange'
], function (Router, $) {

  return Router.sub('UrlHashRouter')

    .after('init', function () {
      $(window).hashchange( function () {
        this.process(this.hash())
      }.bind(this))
    })

    .proto({

      // Firefox seems to act differently to Chrome when using location.hash
      hash: function () {
        var matches = window.location.href.match(/#(.*)$/)
        return matches ? matches[1] : ""
      }

    })

})

