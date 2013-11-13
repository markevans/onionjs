Type = requirejs('onion/type')
extendable = requirejs('onion/plugins/extendable')

describe "extendable", ->
  MyClass = null
  object = null

  beforeEach ->
    class MyClass extends Type
      @use extendable
    object = new MyClass()

  it "gives accessors for getting/setting extensions", ->
    expect( object.extension('lobo') ).to.be.undefined
    object.setExtension('lobo', 2)
    expect( object.extension('lobo') ).to.equal(2)
