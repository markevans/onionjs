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
    it "defaults to a placeholder tag", ->
      view = new MustacheView()
      expect( view.dom.tagName ).to.equal('SCRIPT')

  describe "attachTo", ->
    view = null

    beforeEach ->
      view = new MustacheView()

    it "returns the dom if set", ->
      element = $('<div>')[0]
      view.attachTo(element)
      expect( view.dom ).to.eql(element)

    it "allows setting on init", ->
      view = new MustacheView(attachTo: '<div>')
      assert.isTrue( $(view.dom).is('div') )

  describe "render", ->
    view = null

    beforeEach ->
      view = new MustacheView()

    it "sets the dom to the given html", ->
      view.render("<p>Hello</p>")
      expect( view.dom.outerHTML ).to.eql('<p>Hello</p>')

    it "throws an error if called with non-wrapped content", ->
      expect(->
        view.render("Hello")
      ).to.throw()

    it "throws an error if called with wrapped content but not in a single tag", ->
      expect(->
        view.render("<p>Hello</p><p>Hello</p>")
      ).to.throw()

    it "doesn't get confused with things already on the page", ->
      testParagraph = $('<p class="test-paragraph"></p>').appendTo('body')
      expect(->
        view.render("p.test-paragraph")
      ).to.throw()
      testParagraph.remove()

    it "sets the dom on the page if attached", ->
      container = $('<div>')[0]
      element = $('<p>Hello</p>').appendTo(container)
      view.attachTo(element)
      expect( container.innerHTML ).to.eql('<p>Hello</p>')

      view.render("<span>dubble</span>")
      expect( container.innerHTML ).to.eql('<span>dubble</span>')
      expect( view.dom.outerHTML ).to.eql('<span>dubble</span>')

  describe "appendTo", ->
    view = null
    container = null

    beforeEach ->
      container = $('<div>')[0]
      view = new MustacheView()

    it "appends the DOM to the specified element", ->
      view.appendTo(container)
      expect( $(view.dom).parent()[0] ).to.equal(container)

  describe "destroy", ->
    it "removes itself from the dom", ->
      view = new MustacheView()
      view.render('<div></div>').appendTo('body')
      expect( $(view.dom).parents('body').length ).to.eql(1)
      view.destroy()
      expect( $(view.dom).parents('body').length ).to.eql(0)

  describe "toHTML", ->
    it "returns the entire html", ->
      view = new MustacheView()
      view.attachTo('<div>gruber</div>')
      expect( view.toHTML() ).to.eql('<div>gruber</div>')

  describe "events", ->

    describe "instance onDom", ->
      view = null

      beforeEach ->
        view = new MustacheView()

      afterEach ->
        view.destroy()

      it "forwards on events using onDOM", ->
        view.render('<div><a class="link">CLICK ME</a></div>')
        view.appendTo('body')
        view.onDom('.link', 'click', 'clickedYo')
        expect ->
          view.find('.link').click()
        .toEmitOn(view, 'clickedYo')

      it "still works for the outermost element", ->
        view.render('<a>CLICK ME</a>')
        view.appendTo('body')
        view.onDom('', 'click', 'clickedYo')
        expect ->
          $(view.dom).click()
        .toEmitOn(view, 'clickedYo')

      it "still works for newly added html", ->
        view.render('<div></div>')
        view.appendTo('body')
        view.onDom('.link', 'click', 'clickedYo')
        $(view.dom).append('<a class="link">CLICK ME</a>')
        expect ->
          view.find('.link').click()
        .toEmitOn(view, 'clickedYo')

      it "allows setting arguments", ->
        view.attachTo('<div></div>')
        view.onDom '', 'click', 'someEvent', -> some: 'args'
        expect ->
          $(view.dom).click()
        .toEmitOn(view, 'someEvent', some: 'args')

    describe "class onDom", ->
      class MyView extends MustacheView
      view = null

      beforeEach ->
        view = new MyView()

      afterEach ->
        view.destroy()

      assertOnDomCalled = (callback) ->
        MyView.onDom('.link', 'click', 'clickedYo')
        sinon.spy(view, 'onDom')
        assert.isFalse( view.onDom.called )
        callback()
        assert.ok( view.onDom.calledWith('.link', 'click', 'clickedYo') )

      it "calls instance onDom when attached", ->
        assertOnDomCalled ->
          view.attachTo('<div></div>')

      it "calls instance onDom when rendered", ->
        assertOnDomCalled ->
          view.render('<div></div>')

  describe "insertChild", ->
    view = null
    childView = null

    beforeEach ->
      view = new MustacheView(attachTo: '<div><p data-child="bunion">wassup</p></div>')
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
      view.attachTo('<div><p data-child="bunion something else">wassup</p><span data-child="bunionBashers"></span></div>')
      view.insertChild(childView, 'bunion')
      expect( view.toHTML() ).to.eql('<div><p data-child="bunion something else">wassup<a>CHILDVIEW</a></p><span data-child="bunionBashers"></span></div>')

