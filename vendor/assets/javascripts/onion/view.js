if(typeof define!=='function'){var define=require('amdefine')(module);}

define([
  'onion/class_declarations',
  'onion/event_emitter',
  'onion/type',
  'jquery'
], function(classDeclarations, eventEmitter, Type, $){

  var isFunction = function (object) {
    return typeof object === 'function'
  }

  return Type.sub('View')

    .proto(eventEmitter)

    .use(classDeclarations, 'onDom')
    .use(classDeclarations, 'insertChildRule')

    .extend({
      attachChild: function (type, value) {
        this.__insertChildOfTypeUsingDataAttribute__(type, 'attach', value, function (child, element) {
          child.attachTo(element)
        })
      },

      appendChild: function (type, value) {
        this.__insertChildOfTypeUsingDataAttribute__(type, 'append', value, function (child, element) {
          child.appendTo(element)
        })
      },

      __insertChildOfTypeUsingDataAttribute__: function (type, attribute, value, insertCallback) {
        this.insertChildRule(function (child, opts) {
          if(child.constructor.name != type) return false

          var dataValue = value
          if (isFunction(dataValue)) { dataValue = dataValue.call(this, opts) }

          var element = this.elementWithData(attribute, dataValue)
          if (element) {
            insertCallback(child, element)
            return true
          }
        })
      }
    })

    .proto({
      $: function () {
        return $(this.dom)
      },

      attachTo: function (dom) {
        this.dom = $(dom)[0]
        this.__setUpDomListeners__()
        this.__isRendered__ = true
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

      elementWithData: function (dataAttr, value) {
        var $elems = this.findFromData(dataAttr, value)
        return $elems.length ? $elems[0] : null
      },

      renderHTML: function (html) {
        html = html.trim()
        var newHtml = $(html)
        if ( !html.match(/^<[\s\S]+>$/) || newHtml.length != 1 ) {
          throw new Error("renderHTML only takes HTML wrapped in a single tag - you gave:\n" + html)
        }
        this.$().replaceWith(newHtml)
        this.attachTo(newHtml)
        return this
      },

      render: function () {},

      isRendered: function () {
        return this.__isRendered__
      },

      insertChild: function (childView, opts) {
        this.__applyInsertRules__(childView, opts) || this.__defaultInsertChild__(childView, opts)
      },

      insertChildRule: function (rule) {
        var rule = isFunction(rule) ? rule : this[rule]
        this.__insertRules__.push(rule)
      },

      __applyInsertRules__: function (childView, opts) {
        return this.__insertRules__.some(function(rule){
          return rule.call(this, childView, opts)
        }, this)
      },

      __defaultInsertChild__: function (childView, opts) {
        var element,
            type = childView.constructor.name
        if(element = this.elementWithData('append', type)) {
          childView.appendTo(element)
        } else if(element = this.elementWithData('attach', type)) {
          childView.attachTo(element)
        } else {
          if(childView.appendTo) childView.appendTo(this.$())
        }
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
      this.__insertRules__ = []
      this.__applyClassDeclarations__('insertChildRule')
      this.__isRendered__ = false
    })

})

