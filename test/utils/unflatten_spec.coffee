unflatten = requirejs('onion/utils/unflatten')

describe "unflatten", ->
  it "unflattens an object with the given keys", ->
    expect( unflatten(
      {
        a: 1,
        b: 2,
        c: 3,
        d: 4
      },
      {
        x: ['b'],
        y: ['c', 'd', 'e'],
        z: ['f']
      }
    ) ).to.eql({
      a: 1,
      x: {b: 2},
      y: {c: 3, d: 4}
    })
