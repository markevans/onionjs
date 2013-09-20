View = requirejs('onion/view')
mustacheView = requirejs('onion/mustache_view')

describe "mustacheView", ->

  class MyView extends View
    @use mustacheView

  describe "renderMustache", ->
    view = null

    beforeEach ->
      view = new MyView(models: {age: 32})

    it "renders a mustache template, using the models", ->

      view.renderMustache('<p>{{age}}</p>')
      expect( view.toHTML() ).to.equal('<p>32</p>')

    it "allows passing an extra object for helpers etc.", ->
      view.renderMustache('<p>{{age}}, {{height}}</p>', height: 'teeny')
      expect( view.toHTML() ).to.equal('<p>32, teeny</p>')
