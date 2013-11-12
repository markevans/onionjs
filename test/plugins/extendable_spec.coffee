Type = requirejs('onion/type')
extendable = requirejs('onion/plugins/extendable')

describe "extendable", ->
  MyClass = null
  object = null

  beforeEach ->
    class MyClass extends Type
      @use extendable
    object = new MyClass()

  it "gives an extensions object", ->
    expect( object.extensions() ).to.be.truthy

  it "gives accessors for getting/setting extensions", ->
    expect( object.extensions().get('lobo') ).to.be.undefined
    object.extensions().set('lobo', 2)
    expect( object.extensions().get('lobo') ).to.equal(2)
