Set = requirejs('onion/set')

describe "Set", ->

  describe "duplicates", ->
    it "ignores duplicates on add", ->
      set = new Set([4, 27])
      set.add(4)
      expect( set.toArray() ).to.eql([4, 27])

    it "ignores duplicates on initialize", ->
      set = new Set([4, 27, 4])
      expect( set.toArray() ).to.eql([4, 27])

    it "ignores duplicates on set", ->
      set = new Set()
      set.set([4, 27, 4])
      expect( set.toArray() ).to.eql([4, 27])

    it "ignores duplicates on addMany", ->
      set = new Set([4, 27])
      set.addMany([4, 13])
      expect( set.toArray() ).to.eql([4, 27, 13])

    it "ignores duplicates in the added array in addMany", ->
      set = new Set()
      set.addMany([4, 4])
      expect( set.toArray() ).to.eql([4])

    it "uses 'isEqualTo' if implemented on the objects", ->
      isEqualTo = (other) -> @name == other.name
      newObject = (name) ->
        name: name
        isEqualTo: isEqualTo

      set = new Set([
        newObject('Jark')
        newObject('Mumfy')
        newObject('Jark')
      ])
      set.add(newObject('Doobie'))
      set.addMany([newObject('Doobie'), newObject('Mumfy')])

      expect( set.toArray() ).to.eql([
        newObject('Jark')
        newObject('Mumfy')
        newObject('Doobie')
      ])

  describe "intersection", ->
    it "returns items that occur in both collections", ->
      set = new Set([3, 55, 66, 345])
      newSet = set.intersection([55, 345, 678])
      expect( newSet.toArray() ).to.eql([55, 345])

  describe "difference", ->
    it "returns items that occur in only the first collection", ->
      set = new Set([3, 55, 66, 345])
      newSet = set.difference([55, 345, 678])
      expect( newSet.toArray() ).to.eql([3, 66])
