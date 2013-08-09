Struct = requirejs('onion/struct')

describe "Struct", ->

  describe "attributes", ->
    class TestStruct extends Struct
      @attributes 'brucy'
    struct = null

    beforeEach ->
      struct = new TestStruct(brucy: 'bonus')

    it "sets provided attributes", ->
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
      expect( struct.attrs() )
        .to.eql(hello: 'guys', whats: 'up', nada: 'much')

    it "allows specifying specific attrs", ->
      expect( struct.attrs('hello', 'whats') )
        .to.eql(hello: 'guys', whats: 'up')

  describe "setting", ->
    class TestStruct extends Struct
      @attributes 'gold', 'silver'
    struct = null

    beforeEach ->
      struct = new TestStruct()

    it "sets and emits the `change` event", ->
      expect ->
        struct.setGold('lots')
      .toEmitOn(struct, 'change')
      expect( struct.gold() )
        .to.eql('lots')

    it "sets and emits the `change:gold` event", ->
      expect ->
        struct.setGold('lots')
      .toEmitOn(struct, 'change:gold', {from: undefined, to: 'lots'})
      expect( struct.gold() ).to.eql('lots')

    it "sets and emits a set event when a value is first set", ->
      struct.setGold(null)
      expect ->
        struct.setGold('lots')
      .toEmitOn(struct, 'set:gold', 'lots')
      expect( struct.gold() ).to.eql('lots')

    it "doesn't trigger if not changed", ->
      struct.setGold('lots')
      expect ->
        struct.setGold('lots')
      .not.toEmitOn(struct, 'change')

      expect ->
        struct.setGold('lots')
      .not.toEmitOn(struct, 'change:gold')

    describe "setting many", ->
      it "allows setting multiple at once", ->
        struct.setAttrs(gold: 'lots', silver: 'not so much')
        expect( struct.gold() ).to.eql('lots')
        expect( struct.silver() ).to.eql('not so much')

      it "doesn't allow setting attributes it doesn't know about", ->
        expect ->
          struct.setAttrs(what: 'the')
        .to.throw("unknown attribute what for TestStruct")

      it "emits `change:XXX` for each attribute", ->
        changeGoldEvents = changeSilverEvents = 0
        struct.on 'change:gold', ->
          changeGoldEvents++
        struct.on 'change:silver', ->
          changeSilverEvents++

        struct.setAttrs(gold: 'lots', silver: 'not so much')
        expect( changeGoldEvents ).to.eql( 1 )
        expect( changeSilverEvents ).to.eql( 1 )

        struct.setAttrs(gold: 'less now', silver: 'not so much')
        expect( changeGoldEvents ).to.eql( 2 )
        expect( changeSilverEvents ).to.eql( 1 )

      it "emits `change` only once, and only if there are changes", ->
        changeEvents = 0
        struct.on 'change', (changes) ->
          changeEvents++

        struct.setAttrs(gold: 'lots', silver: 'not so much')
        expect( changeEvents ).to.eql( 1 )

        struct.setAttrs(silver: 'not so much')
        expect( changeEvents ).to.eql( 1 )

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
      expect( struct.thing() ).to.eql(null)

    it "works on null if the flag is set", ->
      TestStruct.attributes 'array'
      TestStruct.decorateWriter 'array', ((value) -> [value]), includeNull: true
      struct = new TestStruct()
      struct.setArray(null)
      expect( struct.array() ).to.eql([null])

    it "works with setAttrs", ->
      struct = new TestStruct()
      struct.setAttrs(thing: 'blob')
      expect( struct.thing() ).to.eql('BLOB')

  describe "uuid", ->
    class TestStruct extends Struct
    struct = null

    beforeEach ->
      struct = new TestStruct()

    it "is truthy", ->
      assert.ok( struct.uuid() )

    it "is unique", ->
      expect( struct.uuid() ).not.to.eql( new TestStruct().uuid() )

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

  describe "relatedAttributes", ->
    struct = null
    TestStruct = null

    beforeEach ->
      TestStruct = class TestStruct extends Struct
        @attributes 'number', 'doubleNumber', 'tripleNumber'
        @relateAttributes 'doubleNumber', ['number'], (number) -> number * 2
      struct = new TestStruct()

    it "updates when the other is updated", ->
      struct.setNumber(3)
      expect( struct.doubleNumber() ).to.equal(6)

    it "emits both change events", ->
      expect(-> struct.setNumber(3) ).toEmitOn(struct, 'change:number')
      expect(-> struct.setNumber(4) ).toEmitOn(struct, 'change:doubleNumber')

    it "doesn't run in reverse", ->
      struct.setDoubleNumber(6)
      expect( struct.number() ).to.be.undefined

    it "doesn't run the function if it isn't affected by changes", ->
      spy = sinon.spy()
      TestStruct = class TestStruct extends Struct
        @attributes 'a', 'b', 'c'
        @relateAttributes 'a', ['b'], spy
      struct = new TestStruct()
      struct.setC('stuff')
      expect( spy.called ).to.be.false

    it "sanity check with more complex example", ->
      TestStruct = class TestStruct extends Struct
        @attributes 'firstName', 'lastName', 'fullName'
        @relateAttributes 'fullName', ['firstName', 'lastName'], (first, last) -> "#{first} #{last}"
        @relateAttributes 'firstName', ['fullName'], (fullName) -> fullName.split(' ')[0]
        @relateAttributes 'lastName', ['fullName'], (fullName) -> fullName.split(' ')[1]
      struct = new TestStruct()

      struct.setAttrs(firstName: 'John', lastName: 'Barnes')
      expect( struct.fullName() ).to.equal("John Barnes")

      struct.setAttrs(fullName: 'Mary Egg')
      expect( struct.firstName() ).to.equal("Mary")
      expect( struct.lastName() ).to.equal("Egg")

