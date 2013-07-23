if(typeof define!=='function'){var define=require('amdefine')(module);}

define([
  'onion/class_declarations',
  'onion/event_emitter',
  'onion/type',
  'jquery'
], function(classDeclarations, eventEmitter, Type, $){

  return Type.sub('View')

    .proto(eventEmitter)

    .use(classDeclarations, 'onDom')

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

      appendTo: function (element) {
        $(this.dom).appendTo(element)
        return this
      },

      find: function (selector) {
        return $(this.dom).find(selector)
      },

      findFromDataAttribute: function (dataAttr, value) {
        return this.find('[data-' + dataAttr + ']').filter(function () {
          return $(this).data(dataAttr).match(new RegExp('\\b' + value + '\\b'))
        })
      },

      renderHTML: function (html) {
        html = html.trim()
        var newHtml = $(html)
        if ( !html.match(/^<.+>$/) || newHtml.length != 1 ) {
          throw new Error("renderHTML only takes HTML wrapped in a single tag")
        }
        $(this.dom).replaceWith(newHtml)
        this.attachTo(newHtml)
        return this
      },

      render: function () {},

      insertChild: function(childView, id){
        var container = this.findFromDataAttribute('child', id)
        if(container.length === 0) container = $(this.dom)
        childView.appendTo(container)
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
        this.dom = $('<script>', {type: 'application/vnd.onionjs.placeholder', 'data-view-class': this.constructor.name})[0]
      }
      this.models = options.models || {}
    })

})

