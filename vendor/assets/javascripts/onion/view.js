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

      findFromData: function (dataAttr, value) {
        return this.find('[data-' + dataAttr + ']').filter(function () {
          return $(this).data(dataAttr).match(new RegExp('\\b' + value + '\\b'))
        })
      },

      elemWithData: function (dataAttr, value) {
        var $elems = this.findFromData(dataAttr, value)
        return $elems.length ? $elems[0] : null
      },

      renderHTML: function (html) {
        html = html.trim()
        var newHtml = $(html)
        if ( !html.match(/^<.+>$/m) || newHtml.length != 1 ) {
          throw new Error("renderHTML only takes HTML wrapped in a single tag - you gave:\n" + html)
        }
        $(this.dom).replaceWith(newHtml)
        this.attachTo(newHtml)
        return this
      },

      render: function () {},

      insertChild: function(childView, id){
        var element
        if(element = this.elemWithData('append-child', id)) {
          childView.appendTo(element)
        } else if(element = this.elemWithData('attach-child', id)) {
          childView.attachTo(element)
        } else {
          childView.appendTo($(this.dom))
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
        this.dom = $('<script>', {type: 'application/vnd.onionjs.placeholder', 'data-view-class': this.constructor.name})[0]
      }
      this.models = options.models || {}
    })

})

