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

        renderMustache: function () {
          var args = Array.prototype.slice.call(arguments),
              template = args.shift(),
              objs = args,
              obj = extend.apply(null, [{}].concat(objs)),
              html = this.evalMustache(template, obj)
          this.renderHTML(html)
        }

      })

  }
})

