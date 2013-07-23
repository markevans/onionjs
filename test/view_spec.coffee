View = requirejs('onion/view')
$ = requirejs('jquery')

describe "View", ->

  describe "models", ->
    it "allows setting on init", ->
      view = new View(models: {bo: 'gee'})
      expect( view.models ).to.eql({bo: 'gee'})

    it "defaults to an empty object", ->
      view = new View()
      expect( view.models ).to.eql({})

  describe "dom", ->
    it "defaults to a placeholder tag with the View name", ->
      MyView = View.sub('MyView')
      view = new MyView()
      expect( view.dom.tagName ).to.equal('SCRIPT')
      expect( $(view.dom).data('view-class') ).to.equal('MyView')

  describe "attachTo", ->
    view = null

    beforeEach ->
      view = new View()

    it "returns the dom if set", ->
      element = $('<div>')[0]
      view.attachTo(element)
      expect( view.dom ).to.eql(element)

    it "allows setting on init", ->
      view = new View(attachTo: '<div>')
      assert.isTrue( $(view.dom).is('div') )

  describe "renderHTML", ->
    view = null

    beforeEach ->
      view = new View()

    it "sets the dom to the given html", ->
      view.renderHTML("<p>Hello</p>")
      expect( view.dom.outerHTML ).to.eql('<p>Hello</p>')

    it "throws an error if called with non-wrapped content", ->
      expect(->
        view.renderHTML("Hello")
      ).to.throw()

    it "throws an error if called with wrapped content but not in a single tag", ->
      expect(->
        view.renderHTML("<p>Hello</p><p>Hello</p>")
      ).to.throw()

    it "doesn't get confused with things already on the page", ->
      testParagraph = $('<p class="test-paragraph"></p>').appendTo('body')
      expect(->
        view.renderHTML("p.test-paragraph")
      ).to.throw()
      testParagraph.remove()

    it "sets the dom on the page if attached", ->
      container = $('<div>')[0]
      element = $('<p>Hello</p>').appendTo(container)
      view.attachTo(element)
      expect( container.innerHTML ).to.eql('<p>Hello</p>')

      view.renderHTML("<span>dubble</span>")
      expect( container.innerHTML ).to.eql('<span>dubble</span>')
      expect( view.dom.outerHTML ).to.eql('<span>dubble</span>')

  describe "appendTo", ->
    view = null
    container = null

    beforeEach ->
      container = $('<div>')[0]
      view = new View()

    it "appends the DOM to the specified element", ->
      view.appendTo(container)
      expect( $(view.dom).parent()[0] ).to.equal(container)

  describe "destroy", ->
    it "removes itself from the dom", ->
      view = new View()
      view.renderHTML('<div></div>').appendTo('body')
      expect( $(view.dom).parents('body').length ).to.eql(1)
      view.destroy()
      expect( $(view.dom).parents('body').length ).to.eql(0)

  describe "toHTML", ->
    it "returns the entire html", ->
      view = new View()
      view.attachTo('<div>gruber</div>')
      expect( view.toHTML() ).to.eql('<div>gruber</div>')

  describe "events", ->

    describe "instance onDom", ->
      view = null

      beforeEach ->
        view = new View()

      afterEach ->
        view.destroy()

      it "forwards on events using onDOM", ->
        view.renderHTML('<div><a class="link">CLICK ME</a></div>')
        view.appendTo('body')
        view.onDom('.link', 'click', 'clickedYo')
        expect ->
          view.find('.link').click()
        .toEmitOn(view, 'clickedYo')

      it "still works for the outermost element", ->
        view.renderHTML('<a>CLICK ME</a>')
        view.appendTo('body')
        view.onDom('', 'click', 'clickedYo')
        expect ->
          $(view.dom).click()
        .toEmitOn(view, 'clickedYo')

      it "still works for newly added html", ->
        view.renderHTML('<div></div>')
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
      class MyView extends View
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
          view.renderHTML('<div></div>')

  describe "insertChild", ->
    view = null
    childView = null

    beforeEach ->
      view = new View()
      childView = new View(attachTo: '<a>CHILDVIEW</a>')

    it "uses data-append-child", ->
      view.attachTo('<div><p data-append-child="bunion"></p></div>')
      view.insertChild(childView, 'bunion')
      expect( view.toHTML() ).to.eql('<div><p data-append-child="bunion"><a>CHILDVIEW</a></p></div>')

    it "uses data-attach-child", ->
      view.attachTo('<div><p data-attach-child="bunion"></p></div>')
      view.insertChild(childView, 'bunion')
      expect( view.toHTML() ).to.eql('<div><p data-attach-child="bunion"></p></div>')
      expect( childView.toHTML() ).to.eql('<p data-attach-child="bunion"></p>')

    it "appends to main container if id not known", ->
      view.attachTo('<div><p></p></div>')
      view.insertChild(childView, 'bunion')
      expect( view.toHTML() ).to.eql('<div><p></p><a>CHILDVIEW</a></div>')

    it "allows specifying more than one data-append-child on the same element (space separated) without confusing with substrings", ->
      view.attachTo('<div><p data-append-child="bunion something else"></p><span data-append-child="bunionBashers"></span></div>')
      view.insertChild(childView, 'bunion')
      expect( view.toHTML() ).to.eql('<div><p data-append-child="bunion something else"><a>CHILDVIEW</a></p><span data-append-child="bunionBashers"></span></div>')

