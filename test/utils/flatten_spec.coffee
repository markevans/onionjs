flatten = requirejs('onion/utils/flatten')

describe "flatten", ->
  it "flattens an object by one level", ->
    expect( flatten(a: {b: c: 1}, e: 2) ).to.eql(b: {c: 1}, e: 2)
