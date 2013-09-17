extend = requirejs('onion/extend')

describe "extend", ->
  a = null

  beforeEach ->
    a = {some: 'fruit'}

  it "extends an object", ->
    expect( extend(a, {more: 'things'}) ).to.equal(a)
    expect( a.some ).to.equal('fruit')
    expect( a.more ).to.equal('things')

  it "doesn't modify the src", ->
    b = {more: 'things'}
    extend(a, b)
    expect(b).to.eql(more: 'things')

  it "allows the src to be null", ->
    extend(a, null)
    expect(a).to.eql(some: 'fruit')

  it "extends with more than one src", ->
    extend(a, {more: 'things'}, {then: 'somemore'})
    expect(a).to.eql(some: 'fruit', more: 'things', then: 'somemore')

