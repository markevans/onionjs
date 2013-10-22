if(typeof define!=='function'){var define=require('amdefine')(module);}

define([
    'onion/utils/extend',
    'onion/vendor/mustache'
  ], function (extend, Mustache) {
  return function (View) {

    View

      .proto({

        evalMustache: function (template, obj, partials) {
          return Mustache.render(template, obj, partials)
        },

        renderMustache: function (template, helpers, partials) {
          var obj = extend({}, this.models, helpers),
              html = this.evalMustache(template, obj, partials)
          this.renderHTML(html)
        }

      })

  }
})
