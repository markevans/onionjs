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
    .use(classDeclarations, 'insertChildOfType')

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

      insertChild: function (childView, opts) {
        this.__applyInsertRules__(childView, opts) || this.__defaultInsertChild__(childView, opts)
      },

      // attachChild: function (type, mapping) {
      //   var rules = this.__insertRule__(type)
      //   rules.push(['attach', mapping])
      // },

      insertChildOfType: function (type, rule) {
        var rule = isFunction(rule) ? rule : this[rule]
        this.__insertRulesForType__(type).push(rule)
      },

      __applyInsertRules__: function (childView, opts) {
        var type = childView.constructor.name
        return this.__insertRulesForType__(type).some(function(rule){
          return rule.call(this, childView, opts)
        }, this)
      },

      __defaultInsertChild__: function (childView, opts) {
        var element,
            type = childView.constructor.name
        if(element = this.elemWithData('append', type)) {
          childView.appendTo(element)
        } else if(element = this.elemWithData('attach', type)) {
          childView.attachTo(element)
        } else {
          if(childView.appendTo) childView.appendTo(this.$())
        }
      },

      __insertRulesForType__: function (type) {
        return this.__insertRules__[type] = this.__insertRules__[type] || []
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
      this.__applyClassDeclarations__('insertChildOfType')
    })

})

