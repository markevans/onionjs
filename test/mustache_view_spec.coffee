MustacheView = requirejs('onion/mustache_view')
$ = requirejs('jquery')

describe "MustacheView", ->

  describe "models", ->
    it "allows setting on init", ->
      view = new MustacheView(models: {bo: 'gee'})
      expect( view.models ).to.eql({bo: 'gee'})

    it "defaults to an empty object", ->
      view = new MustacheView()
      expect( view.models ).to.eql({})

  describe "dom", ->
    view = null

    beforeEach ->
      view = new MustacheView()

    it "raises an error if not yet set", ->
      expect(->
        view.dom()
      ).to.throw("the dom hasn't yet been set in MustacheView")

    it "returns the dom if set", ->
      element = $('<div>')[0]
      view.setDom(element)
      expect( view.dom() ).to.eql(element)

    it "allows setting as a string", ->
      view.setDom('<div>')
      assert.isTrue( $(view.dom()).is('div') )

    it "allows setting on init", ->
      view = new MustacheView(dom: '<div>')
      assert.isTrue( $(view.dom()).is('div') )

    it "calls __setUpDomListeners__ when set", ->
      element = $('<div>')[0]
      sinon.spy(view, '__setUpDomListeners__')
      view.setDom(element)
      assert.ok( view.__setUpDomListeners__.called )

    it "allows replacing the dom, and calls __setUpDomListeners__ again", ->
      sinon.spy(view, '__setUpDomListeners__')

      element1 = $('<div>', class: 'element1')
      view.setDom(element1)
      assert.ok( view.__setUpDomListeners__.called )

      element1.appendTo('body')[0]
      expect( $('body > :last-child').is(element1) ).to.eql(true)

      element2 = $('<div>', class: 'element2')[0]
      view.setDom(element2)

      assert.ok( view.__setUpDomListeners__.called )
      expect( $('body > :last-child').is(element2) ).to.eql(true)
      expect( $('body > .element1').length ).to.eql(0)

  describe "destroy", ->
    it "removes itself from the dom", ->
      view = new MustacheView(template: '<div></div>')
      view.render().appendTo('body')
      expect( view.$dom().parents('body').length ).to.eql(1)
      view.destroy()
      expect( view.$dom().parents('body').length ).to.eql(0)

  describe "template", ->
    it "throws an error if not set", ->
      view = new MustacheView()
      expect ->
        view.template()
      .to.throw("the template hasn't yet been set")

    it "allows setting on init", ->
      view = new MustacheView(template: "<p></p>")
      expect( view.template() ).to.eql("<p></p>")

    it "allows setting", ->
      view = new MustacheView()
      view.setTemplate("<p></p>")
      expect( view.template() ).to.eql("<p></p>")

    it "allows setting at the class level declaratively", ->
      class MyView extends MustacheView
      view = new MyView()
      expect( MyView.template("<i></i>") ).to.eql(MyView)
      expect( view.template() ).to.eql("<i></i>")

  describe "render", ->
    view = null
    MyView = null

    beforeEach ->
      class MyView extends MustacheView
        template: -> "<div>{{something}}{{SOMETHING}}</div>"
      view = new MyView()

    it "sets the DOM with the template specified by the 'template' method", ->
      view.render(something: 'good')
      expect( view.dom().outerHTML ).to.eql("<div>good</div>")

    describe "helpers", ->
      it "allows adding helpers", ->
        view.helpers
          SOMETHING: -> @something.toUpperCase()
        view.render(something: 'good')
        expect( view.dom().outerHTML ).to.eql("<div>goodGOOD</div>")

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
        expect( view.dom().outerHTML ).to.eql("<div>1234</div>")

      it "works at the class level", ->
        MyView.helpers
          SOMETHING: -> @something.toUpperCase()
        view = new MyView()
        view.render(something: 'good')
        expect( view.dom().outerHTML ).to.eql("<div>goodGOOD</div>")

  describe "toHTML", ->
    it "returns the entire html", ->
      view = new MustacheView()
      view.setDom('<div>gruber</div>')
      expect( view.toHTML() ).to.eql('<div>gruber</div>')

  describe "appendTo", ->
    view = null

    beforeEach ->
      view = new MustacheView(template: '<div class="hello"></div>')
      view.render()

    afterEach ->
      view.destroy()

    it "appends the DOM to the specified element", ->
      returnValue = view.appendTo($('body')[0])
      expect( $('body > .hello').length ).to.eql(1)
      expect( returnValue ).to.eql(view)

    it "works with jquery objects", ->
      view.appendTo($('body'))
      expect( $('body > .hello').length ).to.eql(1)

    it "works with css selectors", ->
      view.appendTo('body')
      expect( $('body > .hello').length ).to.eql(1)

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
      sinon.spy(view, 'onDom')
      assert.isFalse( view.onDom.called )
      view.setDom('<div></div>')
      assert.ok( view.onDom.calledWith('.link', 'click', 'clickedYo') )

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
      expect( view.toHTML() ).to.eql('<div><p data-child="bunion">wassup<a>CHILDVIEW</a></p></div>')

    it "appends to main container if id not known", ->
      view.insertChild(childView, 'butterscotch')
      expect( view.toHTML() ).to.eql('<div><p data-child="bunion">wassup</p><a>CHILDVIEW</a></div>')

    it "allows specifying more than one data-child on the same element (space separated) without confusing with substrings", ->
      view.setDom('<div><p data-child="bunion something else">wassup</p><span data-child="bunionBashers"></span></div>')
      view.insertChild(childView, 'bunion')
      expect( view.toHTML() ).to.eql('<div><p data-child="bunion something else">wassup<a>CHILDVIEW</a></p><span data-child="bunionBashers"></span></div>')
