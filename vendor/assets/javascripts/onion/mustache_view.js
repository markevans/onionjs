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

    .extend({
      template: function (template) {
        this.prototype.__template__ = template
        return this
      }
    })

    .proto({
      setDom: function (dom) {
        var oldDom = this.__dom__
        dom = $(dom)[0]
        if(oldDom) {
          $(oldDom).replaceWith(dom)
        }
        this.__dom__ = dom
        this.__setUpDomListeners__()
        return this
      },

      dom: function () {
        if(!this.__dom__) throw new Error("the dom hasn't yet been set in "+this.constructor.name)
        return this.__dom__
      },

      $dom: function () {
        return $(this.dom())
      },

      onDom: function (selector, event, newEvent, argumentsMapper) {
        var self = this
        this.$dom().on(event, selector, function (event) {
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

      renderTemplate: function (template, object) {
        return Mustache.render(template, extend({}, object, this.__helpers__))
      },

      render: function (object) {
        var html = this.renderTemplate(this.template(), object)
        var parsedDom = null
        try {
          parsedDom = $(html)
        }
        catch (e) {
          throw new Error(["Could not parse the result of rendering the template.",
                           "A probable cause is that the result starts with spaces,",
                           "and you are using jQuery 1.9.1 or 2.0, which don't accept this.",
                           "To solve the problem, either remove the spaces at the beginning",
                           "or upgrade jQuery."].join(" "))
        }
        this.setDom(parsedDom[0])
        return this
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

      setTemplate: function(template) {
        this.__template__ = template
        return this
      },

      template: function () {
        if(!this.__template__) throw new Error("the template hasn't yet been set")
        return this.__template__
      },

      appendTo: function (element) {
        $(this.dom()).appendTo(element)
        return this
      },

      find: function (selector) {
        return $(this.dom()).find(selector)
      },

      append: function (element) {
        this.$dom().append(element)
        return this
      },

      insertChild: function(childView, id){
        if (childView.appendTo) {
          var container = this.find('[data-child]').filter(function () {
            return $(this).data('child').match(new RegExp('\\b' + id + '\\b'))
          })
          if(container.length === 0) container = this.$dom()
          childView.appendTo(container)
        }
        return this
      },

      toHTML: function () {
        return this.dom().outerHTML
      },

      destroy: function () {
        this.$dom().remove()
      }
    })

    .after('init', function (options) {
      if(!options) options = {}

      if(options.template) this.setTemplate(options.template)
      if(options.dom) this.setDom(options.dom)

      // Helpers
      this.__helpers__ = {}
      this.__applyClassDeclarations__('helpers')
    })

})
