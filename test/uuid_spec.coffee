uuid = requirejs('onion/utils/uuid')

describe "uuid", ->

  it "generates a different uuid each time", ->
    pattern = /^\w{8}-\w{4}-4\w{3}-\w{4}-\w{12}$/
    uuid1 = uuid()
    uuid2 = uuid()
    expect( uuid1 ).to.match(pattern)
    expect( uuid2 ).to.match(pattern)
    expect( uuid1 ).not.to.equal(uuid2)
