objectSignature = requirejs('onion/utils/object_signature')

describe "objectSignature", ->
  obj = ->
    a = {a: {b: 'c'}, d: '5'}
  sig = null

  beforeEach ->
    sig = objectSignature(obj())

  it "returns a signature string", ->
    expect( sig ).to.match(/^\w+$/)

  it "ignores order", ->
    sig2 = objectSignature(d: '5', a: {b: 'c'})
    expect( sig ).to.equal(sig2)

  it "doesn't allow different keys", ->
    obj2 = obj()
    obj2.x = 'y'
    sig2 = objectSignature(obj2)
    expect( sig ).not.to.equal(sig2)

  it "allows numbers or strings", ->
    obj2 = obj()
    obj2.d = 5
    sig2 = objectSignature(obj2)
    expect( sig ).to.equal(sig2)

  it "works with arrays", ->
    sig1 = objectSignature(['a','b','c'])
    sig2 = objectSignature(['a','b','c'])
    expect( sig1 ).to.equal(sig2)
