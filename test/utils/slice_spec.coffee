slice = requirejs('onion/utils/slice')

describe "slice", ->
  attrs = {}

  beforeEach ->
    attrs = {
      apple: 1
      banana: 2
      carrot: 3
    }

  it "slices the specified attributes", ->
    expect( slice(attrs, 'apple', 'carrot') ).to.eql({
      apple: 1
      carrot: 3
    })

  it "does not set keys that doesn't exist", ->
    result = slice(attrs, 'apple', 'carrot', 'kiwi')
    expect( Object.prototype.hasOwnProperty.call(result, 'kiwi') ).to.eql(false)
