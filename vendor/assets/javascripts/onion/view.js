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
      $: function () {
        return $(this.dom)
      },

      attachTo: function (dom) {
        this.dom = $(dom)[0]
        this.__setUpDomListeners__()
        return this
      },

      onDom: function (selector, event, newEvent, argumentsMapper) {
        var self = this
        this.$().on(event, selector, function (event) {
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
        this.$().appendTo(element)
        return this
      },

      find: function (selector) {
        return this.$().find(selector)
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
        this.$().replaceWith(newHtml)
        this.attachTo(newHtml)
        return this
      },

      render: function () {},

      insertChild: function(childView){
        var element,
            type = childView.constructor.name
        if(element = this.elemWithData('append', type)) {
          childView.appendTo(element)
        } else if(element = this.elemWithData('attach', type)) {
          childView.attachTo(element)
        } else {
          if(childView.appendTo) childView.appendTo(this.$())
        }
        return this
      },

      toHTML: function () {
        return this.dom.outerHTML
      },

      destroy: function () {
        this.$().remove()
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

