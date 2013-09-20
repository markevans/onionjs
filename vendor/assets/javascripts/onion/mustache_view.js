if(typeof define!=='function'){var define=require('amdefine')(module);}

define([
    'onion/extend',
    'onion/vendor/mustache'
  ], function (extend, Mustache) {
  return function (View) {

    View

      .proto({

        evalMustache: function (template, obj) {
          return Mustache.render(template, obj)
        },

        renderMustache: function (template, helpers) {
          var obj = extend({}, this.models, helpers),
              html = this.evalMustache(template, obj)
          this.renderHTML(html)
        }

      })

  }
})
