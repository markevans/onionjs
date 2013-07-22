if(typeof define!=='function'){var define=require('amdefine')(module);}

define([
  'onion/class_declarations',
  'onion/event_emitter',
  'onion/extend',
  'onion/vendor/mustache',
  'onion/type',
  'jquery'
], function(classDeclarations, eventEmitter, extend, Mustache, Type, $){

  return Type.sub('MustacheView')

    .proto(eventEmitter)

    .use(classDeclarations, 'onDom')

    .use(classDeclarations, 'helpers')

    .proto({
      attachTo: function (dom) {
        this.dom = $(dom)[0]
        this.__setUpDomListeners__()
        return this
      },

      onDom: function (selector, event, newEvent, argumentsMapper) {
        var self = this
        $(this.dom).on(event, selector, function (event) {
          event.stopPropagation()
          event.preventDefault()

          if(argumentsMapper) {
            self.emit(newEvent, argumentsMapper.call(self, this, event))
          } else {
            self.emit(newEvent)
          }
        })
        return this
      },

      __setUpDomListeners__: function () {
        this.__applyClassDeclarations__('onDom')
      },

      helpers: function () {
        var self = this,
            objects = Array.prototype.slice.call(arguments)
        objects.forEach(function (object) {
          for(var key in object) {
            self.__helpers__[key] = object[key]
          }
        })
      },

      appendTo: function (element) {
        $(this.dom).appendTo(element)
        return this
      },

      find: function (selector) {
        return $(this.dom).find(selector)
      },

      render: function (html) {
        html = html.trim()
        var newHtml = $(html)
        if ( !html.match(/^<.+>$/) || newHtml.length != 1 ) {
          throw new Error("render only takes HTML wrapped in a single tag")
        }
        $(this.dom).replaceWith(newHtml)
        this.attachTo(newHtml)
        return this
      },

      insertChild: function(childView, id){
        if (childView.appendTo) {
          var container = this.find('[data-child]').filter(function () {
            return $(this).data('child').match(new RegExp('\\b' + id + '\\b'))
          })
          if(container.length === 0) container = $(this.dom)
          childView.appendTo(container)
        }
        return this
      },

      toHTML: function () {
        return this.dom.outerHTML
      },

      destroy: function () {
        $(this.dom).remove()
      }
    })

    .after('init', function (options) {
      if(!options) options = {}

      if(options.attachTo) {
        this.attachTo(options.attachTo)
      } else {
        this.dom = $('<script>', {type: 'application/vnd.onionjs.placeholder'})[0]
      }
      this.models = options.models || {}

      // Helpers
      this.__helpers__ = {}
      this.__applyClassDeclarations__('helpers')
    })

})

