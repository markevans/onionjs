Type = requirejs('onion/type')

describe "Type", ->

  describe "typeName", ->

    it "defaults to the constructor name", ->
      MyType = Type.sub("MyType")
      expect( new MyType().typeName() ).to.equal("MyType")

    it "works when declared using coffeescript", ->
      class MyType extends Type
      expect( new MyType().typeName() ).to.equal("MyType")

