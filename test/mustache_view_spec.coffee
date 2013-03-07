MustacheView = requirejs('onion/mustache_view')
$ = requirejs('jquery')

describe "MustacheView", ->

  describe "dom", ->
    view = null

    beforeEach ->
      view = new MustacheView()

    it "raises an error if not yet set", ->
      expect(->
        view.dom()
      ).toThrow("the dom hasn't yet been set in MustacheView")

    it "returns the dom if set", ->
      element = $('<div>')[0]
      view.setDom(element)
      expect( view.dom() ).toEqual(element)

    it "allows setting as a string", ->
      view.setDom('<div>')
      expect( view.dom().constructor ).toEqual(HTMLDivElement)

    it "allows setting on init", ->
      view = new MustacheView(dom: '<div>')
      expect( view.dom().constructor ).toEqual(HTMLDivElement)

    it "calls __setUpDomListeners__ when set", ->
      element = $('<div>')[0]
      spyOn(view, '__setUpDomListeners__')
      view.setDom(element)
      expect( view.__setUpDomListeners__ ).toHaveBeenCalled()

    it "allows replacing the dom, and calls __setUpDomListeners__ again", ->
      spyOn(view, '__setUpDomListeners__')

      element1 = $('<div>', class: 'element1')
      view.setDom(element1)
      expect( view.__setUpDomListeners__ ).toHaveBeenCalled()

      element1.appendTo('body')[0]
      expect( $('body > :last-child').is(element1) ).toEqual(true)

      element2 = $('<div>', class: 'element2')[0]
      view.setDom(element2)

      expect( view.__setUpDomListeners__ ).toHaveBeenCalled()
      expect( $('body > :last-child').is(element2) ).toEqual(true)
      expect( $('body > .element1').length ).toEqual(0)

  describe "destroy", ->
    it "removes itself from the dom", ->
      view = new MustacheView(template: '<div></div>')
      view.render().appendTo('body')
      expect( view.$dom().parents('body').length ).toEqual(1)
      view.destroy()
      expect( view.$dom().parents('body').length ).toEqual(0)

  describe "template", ->
    it "throws an error if not set", ->
      view = new MustacheView()
      expect ->
        view.template()
      .toThrow("the template hasn't yet been set")

    it "allows setting on init", ->
      view = new MustacheView(template: "<p></p>")
      expect( view.template() ).toEqual("<p></p>")

    it "allows setting", ->
      view = new MustacheView()
      view.setTemplate("<p></p>")
      expect( view.template() ).toEqual("<p></p>")

    it "allows setting at the class level declaratively", ->
      class MyView extends MustacheView
      view = new MyView()
      expect( MyView.template("<i></i>") ).toEqual(MyView)
      expect( view.template() ).toEqual("<i></i>")

  describe "render", ->
    view = null
    MyView = null

    beforeEach ->
      class MyView extends MustacheView
        template: -> "<div>{{something}}{{SOMETHING}}</div>"
      view = new MyView()

    it "sets the DOM with the template specified by the 'template' method", ->
      view.render(something: 'good')
      expect( view.dom().outerHTML ).toEqual("<div>good</div>")

    describe "helpers", ->
      it "allows adding helpers", ->
        view.helpers
          SOMETHING: -> @something.toUpperCase()
        view.render(something: 'good')
        expect( view.dom().outerHTML ).toEqual("<div>goodGOOD</div>")

      it "allows adding more than one helper", ->
        view.helpers({
            one: -> 1
            two: -> 2
          }, {
            three: -> 3
          }
        )
        view.helpers({
          four: -> 4
        })
        view.template = -> "<div>{{one}}{{two}}{{three}}{{four}}</div>"
        view.render()
        expect( view.dom().outerHTML ).toEqual("<div>1234</div>")

      it "works at the class level", ->
        MyView.helpers
          SOMETHING: -> @something.toUpperCase()
        view = new MyView()
        view.render(something: 'good')
        expect( view.dom().outerHTML ).toEqual("<div>goodGOOD</div>")

  describe "toHTML", ->
    it "returns the entire html", ->
      view = new MustacheView()
      view.setDom('<div>gruber</div>')
      expect( view.toHTML() ).toEqual('<div>gruber</div>')

  describe "appendTo", ->
    view = null

    beforeEach ->
      view = new MustacheView(template: '<div class="hello"></div>')
      view.render()

    afterEach ->
      view.destroy()

    it "appends the DOM to the specified element", ->
      returnValue = view.appendTo($('body')[0])
      expect( $('body > .hello').length ).toEqual(1)
      expect( returnValue ).toEqual(view)

    it "works with jquery objects", ->
      view.appendTo($('body'))
      expect( $('body > .hello').length ).toEqual(1)

    it "works with css selectors", ->
      view.appendTo('body')
      expect( $('body > .hello').length ).toEqual(1)

  describe "append", ->
    it "appends some shizzle", ->
      view = new MustacheView(template: '<div><span>dich</span></div>')
      view.render()
      returnValue = view.append('pants')
      expect( view.toHTML() ).toEqual('<div><span>dich</span>pants</div>')
      expect( returnValue ).toEqual(view)

  describe "events", ->

    describe "instance onDom", ->
      view = null

      beforeEach ->
        view = new MustacheView()

      afterEach ->
        view.destroy()

      it "forwards on events using onDOM", ->
        view.setTemplate('<div><a class="link">CLICK ME</a></div>')
        view.render()
        view.appendTo('body')
        view.onDom('.link', 'click', 'clickedYo')
        expect ->
          view.find('.link').click()
        .toEmitOn(view, 'clickedYo')

      it "still works for the outermost element", ->
        view.setTemplate('<a>CLICK ME</a>')
        view.render()
        view.appendTo('body')
        view.onDom('', 'click', 'clickedYo')
        expect ->
          view.$dom().click()
        .toEmitOn(view, 'clickedYo')

      it "still works for newly added html", ->
        view.setTemplate('<div></div>')
        view.render()
        view.appendTo('body')
        view.onDom('.link', 'click', 'clickedYo')
        view.append('<a class="link">CLICK ME</a>')
        expect ->
          view.find('.link').click()
        .toEmitOn(view, 'clickedYo')

      it "allows setting arguments", ->
        view.setDom('<div></div>')
        view.onDom '', 'click', 'someEvent', -> some: 'args'
        expect ->
          view.$dom().click()
        .toEmitOn(view, 'someEvent', some: 'args')

    describe "class onDom", ->
      class MyView extends MustacheView
      view = null

      beforeEach ->
        view = new MyView()

      afterEach ->
        view.destroy()

      it "calls instance onDom when dom is set", ->
        MyView.onDom('.link', 'click', 'clickedYo')
        spyOn(view, 'onDom')
        expect( view.onDom ).not.toHaveBeenCalled()
        view.setDom('<div></div>')
        expect( view.onDom ).toHaveBeenCalledWith('.link', 'click', 'clickedYo')

    describe "insertChild", ->
      view = null
      childView = null

      beforeEach ->
        view = new MustacheView(dom: '<div><p data-child="bunion">wassup</p></div>')
        childView = {
          appendTo: (element) -> $('<a>CHILDVIEW</a>').appendTo(element)
        }

      it "uses data-child", ->
        view.insertChild(childView, 'bunion')
        expect( view.toHTML() ).toEqual('<div><p data-child="bunion">wassup<a>CHILDVIEW</a></p></div>')

      it "appends to main container if id not known", ->
        view.insertChild(childView, 'butterscotch')
        expect( view.toHTML() ).toEqual('<div><p data-child="bunion">wassup</p><a>CHILDVIEW</a></div>')
