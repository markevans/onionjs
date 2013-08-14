Model = requirejs('onion/model')

describe "Model", ->
  model = null

  describe "uuid", ->

    beforeEach ->
      model = new Model()

    it "is truthy", ->
      assert.ok( model.uuid() )

    it "is unique", ->
      expect( model.uuid() ).not.to.eql( new Model().uuid() )

  describe "events", ->
    it "implements events", ->
      model = new Model()
      x = null
      model.on 'something', -> x = 'ok'
      model.emit('something')
      expect( x ).to.equal('ok')

