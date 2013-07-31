Collection = requirejs('onion/collection')
Struct = requirejs('onion/struct')

describe "Struct", ->

  describe "attributes", ->
    class TestStruct extends Struct
      @attributes 'brucy'
    struct = null

    beforeEach ->
      struct = new TestStruct(brucy: 'bonus')

    it "sets attributes we care about", ->
      expect( struct.attrs() ).to.eql(brucy: 'bonus')

    it "returns the class's attribute names", ->
      expect( TestStruct.attributeNames ).to.eql(['brucy'])

  describe "#attrs", ->
    class TestStruct extends Struct
      @attributes 'hello', 'whats', 'nada'
    struct = null

    beforeEach ->
      struct = new TestStruct(hello: 'guys', whats: 'up', nada: 'much')

    it "gives all the attrs", ->
      expect( struct.attrs() ).to.eql(hello: 'guys', whats: 'up', nada: 'much')

    it "allows specifying specific attrs", ->
      expect( struct.attrs('hello', 'whats') ).to.eql(hello: 'guys', whats: 'up')

  describe "setting", ->
    class TestStruct extends Struct
      @attributes 'gold', 'silver'
    struct = null

    beforeEach ->
      struct = new TestStruct()

    it "sets and emits a change event", ->
      expect ->
        struct.setGold('lots')
      .toEmitOn(struct, 'change')
      expect( struct.gold() ).to.eql('lots')

    it "sets and emits a set event when a value is first set", ->
      struct.setGold(null)
      expect ->
        struct.setGold('lots')
      .toEmitOn(struct, 'set:gold', 'lots')
      expect( struct.gold() ).to.eql('lots')

    it "sets and emits a unset event when a value is set to null", ->
      struct.setGold('lots')
      expect ->
        struct.setGold(null)
      .toEmitOn(struct, 'unset:gold')

    it "doesn't trigger if not changed", ->
      struct.setGold('lots')
      expect ->
        struct.setGold('lots')
      .not.toEmitOn(struct, 'change')

    describe "setting many", ->
      it "allows setting multiple at once", ->
        struct.setAttrs(gold: 'lots', silver: 'not so much')
        expect( struct.gold() ).to.eql('lots')
        expect( struct.silver() ).to.eql('not so much')

      it "doesn't allow setting attributes it doesn't know about", ->
        expect ->
          struct.setAttrs(what: 'the')
        .to.throw("unknown attribute what for TestStruct")

  describe "instances", ->
    class TestStruct extends Struct

    it "maintains a collection of instances", ->
      struct1 = new TestStruct()
      struct2 = new TestStruct()
      expect( TestStruct.instances().toArray() ).to.eql([struct1, struct2])

  describe "collection", ->
    class TestStruct extends Struct
      @collection 'things'
    struct = null

    beforeEach ->
      struct = new TestStruct()

    it "returns a collection", ->
      expect( struct.things() instanceof Collection ).to.eql(true)
      expect( struct.things().toArray() ).to.eql([])

    it "allows setting an order", ->
      TestStruct.collection 'bings', orderBy: (a, b) -> if a > b then 1 else -1
      struct.bings().add(1)
      struct.bings().add(3)
      struct.bings().add(2)
      expect( struct.bings().toArray() ).to.eql([1,2,3])

    it "allows setting with setXXXX", ->
      struct.setThings([2,4])
      expect( struct.things().toArray() ).to.eql([2,4])

    it "allows setting on init", ->
      expect( new TestStruct(things: [3,5]).things().toArray() ).to.eql([3,5])

    it "triggers the change event on setXXXX", ->
      expect ->
        struct.setThings([2,4])
      .toEmitOn(struct, 'change:things')

    it "allows setting a different type", ->
      class MyCollection
      TestStruct.collection 'stuff', type: MyCollection
      expect( struct.stuff() instanceof MyCollection ).to.eql(true)

  describe "decorateWriter", ->
    class TestStruct extends Struct
      @attributes 'thing'
      @decorateWriter 'thing', (value) -> value.toUpperCase()

    it "decorates a writer with a function", ->
      struct = new TestStruct()
      struct.setThing('blob')
      expect( struct.thing() ).to.eql('BLOB')

    it "ignores the decorator if set to null", ->
      struct = new TestStruct()
      struct.setThing(null)
      expect( struct.thing() ).to.eql(undefined)

    it "works on null if the flag is set", ->
      TestStruct.attributes 'array'
      TestStruct.decorateWriter 'array', ((value) -> [value]), includeNull: true
      struct = new TestStruct()
      struct.setArray(null)
      expect( struct.array() ).to.eql([null])

  describe "uuid", ->
    class TestStruct extends Struct
    struct = null

    beforeEach ->
      struct = new TestStruct()

    it "is truthy", ->
      assert.ok( struct.uuid() )

    it "is unique", ->
      expect( struct.uuid() ).not.to.eql( new TestStruct().uuid() )

  describe "load", ->
    class TestStruct extends Struct
    struct = null

    beforeEach ->
      struct = TestStruct.load(something: 'nice')

    it "creates a struct with attrs exactly as passed in", ->
      expect( struct.attrs() ).to.eql(something: 'nice')

  describe "setDefaults", ->
    class TestStruct extends Struct
      @attributes 'colour'
    struct = null

    beforeEach ->
      struct = new TestStruct()

    it "sets if not already set", ->
      struct.setDefaults(colour: 'blue')
      expect( struct.colour() ).to.eql('blue')

    it "doesn't overwrite", ->
      struct.setColour('red')
      struct.setDefaults(colour: 'blue')
      expect( struct.colour() ).to.eql('red')

    it "doesn't overwrite falsy but already set", ->
      struct.setColour('')
      struct.setDefaults(colour: 'blue')
      expect( struct.colour() ).to.eql('')
