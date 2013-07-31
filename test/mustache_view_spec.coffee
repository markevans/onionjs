View = requirejs('onion/view')
mustacheView = requirejs('onion/mustache_view')

describe "mustacheView", ->

  class MyView extends View
    @use mustacheView

  describe "renderMustache", ->
    view = null

    beforeEach ->
      view = new MyView()

    it "renders a mustache template", ->
      view.renderMustache('<p>{{age}}</p>', age: 32)
      expect( view.toHTML() ).to.equal('<p>32</p>')

    it "allows passing more than one object to merge into the rendered obj", ->
      view.renderMustache('<p>{{age}}, {{height}}</p>', {age: 32}, {height: 'teeny'})
      expect( view.toHTML() ).to.equal('<p>32, teeny</p>')

