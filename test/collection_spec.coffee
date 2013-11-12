Collection = requirejs('onion/collection')
eventEmitter = requirejs('onion/event_emitter')
extend = requirejs('onion/utils/extend')

describe "Collection", ->
  describe "array-like properties", ->
    collection = null

    beforeEach ->
      collection = new Collection([
        {number: 4}
        {number: 27}
      ])

    it "implements forEach", ->
      result = []
      collection.forEach (obj, i)->
        result.push [obj, i]
      expect( result ).to.eql([
        [{number: 4}, 0]
        [{number: 27}, 1]
      ])

    it "implements map", ->
      result = collection.map (obj, i) ->
        [obj, i]
      expect( result ).to.eql([
        [{number: 4}, 0]
        [{number: 27}, 1]
      ])

  describe "add", ->
    collection = null

    beforeEach ->
      collection = new Collection([6, 22, 44])

    it "defaults to a push when the collection has no order", ->
      collection.add(35)
      expect( collection.toArray() ).to.eql([6, 22, 44, 35])

    it "emits an add event", ->
      x = null
      collection.on 'add', (item) -> x = item
      collection.add(44)
      expect( x ).to.eql(44)

    it "emits a change event", ->
      expect ->
        collection.add(33)
      .toEmitOn(collection, 'change', collection)

    it "emits an itemsAdded event", ->
      expect ->
        collection.add(33)
      .toEmitOn(collection, 'itemsAdded', [33])

  describe "addMany", ->
    collection = null

    beforeEach ->
      collection = new Collection([33, 76], orderBy: (a, b) -> Collection.compare(a, b))

    it "adds many, in the correct order", ->
      collection.addMany([56, 44])
      expect( collection.toArray() ).to.eql([33, 44, 56, 76])

    it "emits an addMany event", ->
      expect ->
        collection.addMany([56, 44])
      .toEmitOn(collection, 'addMany', [56, 44])

    it "should work with a collection", ->
      miniCollection = new Collection([56, 44])
      expect ->
        collection.addMany(miniCollection)
      .toEmitOn(collection, 'addMany', miniCollection)
      expect( collection.toArray() ).to.eql([33, 44, 56, 76])

    it "emits a change event", ->
      expect ->
        collection.addMany([33])
      .toEmitOn(collection, 'change', collection)

    it "emits an itemsAdded event", ->
      expect ->
        collection.addMany([22, 33])
      .toEmitOn(collection, 'itemsAdded', [22, 33])

  describe "remove", ->
    collection = null

    beforeEach ->
      collection = new Collection([4, 4, 5])

    it "removes the first element that matches", ->
      result = collection.remove(4)
      expect( result ).to.eql(true)
      expect( collection.toArray() ).to.eql([4, 5])

    it "does nothing if the element doesn't exist", ->
      result = collection.remove(36)
      expect( result ).to.eql(false)
      expect( collection.toArray() ).to.eql([4, 4, 5])

    it "emits a remove event", ->
      collection.add(95)
      expect ->
        collection.remove(95)
      .toEmitOn(collection, 'remove', 95, 3)

    it "emits a change event", ->
      expect ->
        collection.remove(4)
      .toEmitOn(collection, 'change', collection)

    it "doesn't emit any events if not removed", ->
      expect ->
        collection.remove(400)
      .not.toEmitOn(collection)

    it "emits an itemsRemoved event", ->
      collection.add(7)
      expect ->
        collection.remove(7)
      .toEmitOn(collection, 'itemsRemoved', [7])

  describe "removeMany", ->
    collection = null

    beforeEach ->
      collection = new Collection([4, 4, 5, 6, 7])

    it "removes all elements that match", ->
      result = collection.removeMany([4, 6])
      expect( collection.toArray() ).to.eql([5, 7])

    it "emits a removeMany event", ->
      expect ->
        collection.removeMany([4, 6])
      .toEmitOn(collection, 'removeMany', [4, 4, 6])

    it "emits a change event", ->
      expect ->
        collection.removeMany([4, 6])
      .toEmitOn(collection, 'change', collection)

    it "doesn't emit any events if nothing is removed", ->
      expect ->
        collection.removeMany([9, 10])
      .not.toEmitOn(collection)

    it "emits an itemsRemoved event", ->
      expect ->
        collection.removeMany([4, 6])
      .toEmitOn(collection, 'itemsRemoved', [4, 4, 6])

  describe "using 'isEqualTo'", ->
    isEqualTo = (other) -> @name == other.name
    newObject = (name) ->
      name: name
      isEqualTo: isEqualTo
    collection = null
    sparky = null
    otherSparky = null
    bilf = null
    otherBilf = null

    beforeEach ->
      sparky = newObject('Sparky')
      otherSparky = newObject('Sparky')
      bilf = newObject('Bilf')
      otherBilf = newObject('Bilf')
      collection = new Collection([bilf, sparky, bilf])

    it "removes using 'isEqualTo' if implemented on the objects", ->
      collection.remove(otherSparky)
      expect( collection.toArray() ).to.eql([bilf, bilf])

    it "emits the remove event with the actual removed object (not the matched one)", ->
      removedItem = null
      collection.on 'remove', (item) -> removedItem = item
      collection.remove(otherSparky)
      expect( removedItem == sparky ).to.eql(true)

    it "removes many using 'isEqualTo' if implemented on the objects", ->
      collection.removeMany([otherBilf])
      expect( collection.toArray() ).to.eql([sparky])

    it "emits the remove many event with the actual removed objects (not the matched ones)", ->
      removedItems = null
      collection.on 'removeMany', (items) -> removedItems = items
      collection.removeMany([otherBilf])
      expect( removedItems.length ).to.eql(2)
      expect( removedItems[0] == bilf ).to.eql(true)
      expect( removedItems[1] == bilf ).to.eql(true)

  describe "ordering", ->
    collection = null

    beforeEach ->
      collection = new Collection([21, 44, 5])

    it "orders the items", ->
      collection.orderBy (a, b) -> Collection.compare(a, b)
      expect( collection.toArray() ).to.eql([5, 21, 44])

    it "adds items in the correct position", ->
      collection.orderBy (a, b) -> Collection.compare(a, b)
      collection.add(36)
      expect( collection.toArray() ).to.eql([5, 21, 36, 44])

    it "returns the insertion index", ->
      collection.orderBy (a, b) -> Collection.compare(a, b)
      expect( collection.add(36) ).to.eql(2)

    it "allows passing the order as an arg", ->
      collection = new Collection([21, 44, 5], orderBy: (a, b) -> Collection.compare(a, b))
      expect( collection.toArray() ).to.eql([5, 21, 44])

  describe "isEmpty", ->
    it "is empty if there are no items", ->
      collection = new Collection([])
      expect( collection.isEmpty() ).to.eql(true)

    it "is not empty if there are items", ->
      collection = new Collection([1])
      expect( collection.isEmpty() ).to.eql(false)

  describe "set", ->
    collection = null

    beforeEach ->
      collection = new Collection([7, 65])

    it "resets all elements", ->
      collection.set([4,2,3])
      expect( collection.toArray() ).to.eql([4,2,3])

    it "accepts another collection", ->
      collection2 = new Collection([4,2,3])
      collection.set(collection2)
      expect( collection.toArray() ).to.eql([4,2,3])

    it "orders according to its own order", ->
      collection.orderBy (a, b) -> Collection.compare(a, b)
      collection.set([4,2,3])
      expect( collection.toArray() ).to.eql([2,3,4])

    it "emits a set event", ->
      newItems = null
      collection.on 'set', (a) -> newItems = a
      collection.set([4,5])
      expect( newItems ).to.eql([4,5])

    it "emits a change event", ->
      expect ->
        collection.set([4])
      .toEmitOn(collection, 'change', collection)

    it "emits an itemsAdded event for new items (even items that existed in the old collection)", ->
      expect ->
        collection.set([2, 65])
      .toEmitOn(collection, 'itemsAdded', [2, 65])

    it "emits an itemsRemoved event for old items (even items that exist in the new collection)", ->
      expect ->
        collection.set([2, 65])
      .toEmitOn(collection, 'itemsRemoved', [7, 65])

  describe "clone", ->
    collection = null
    cloned = null

    beforeEach ->
      collection = new Collection([3, 6, 8], orderBy: -> 0)
      cloned = collection.clone()

    it "copies the items", ->
      expect( collection.toArray() ).to.eql( cloned.toArray() )

    it "copies the comparator function", ->
      expect( collection.__comparator__ ).to.eql( cloned.__comparator__ )

    it "doesn't effect the original", ->
      cloned.push(42)

      expect( collection.toArray() ).to.eql( [3, 6, 8] )
      expect( cloned.toArray() ).to.eql( [3, 6, 8, 42] )

  describe "contains", ->
    collection = null

    beforeEach ->
      collection = new Collection()

    it "returns false if it doesn't contain an item", ->
      expect( collection.contains('dice') ).to.eql(false)

    it "returns true if it does contain an item", ->
      collection.add('dice')
      expect( collection.contains('dice') ).to.eql(true)

  describe "onItem", ->
    item = null
    callback = ->

    beforeEach ->
      item =
        on: sinon.spy()
        off: sinon.spy()

    it "subscribes to items currently in the collection", ->
      collection = new Collection([item])
      collection.onItem('change', callback)
      assert.isTrue( item.on.calledWith('change', callback) )

    it "subscribes to new items", ->
      collection = new Collection()
      collection.onItem('change', callback)
      collection.add(item)
      assert.isTrue( item.on.calledWith('change', callback) )

    it "unsubscribes when items are removed", ->
      collection = new Collection([item])
      collection.onItem('change', callback)
      assert.isFalse( item.off.called )
      collection.remove(item)
      assert.isTrue( item.off.calledWith('change', callback) )

    it "does nothing if the item doesn't respond to on", ->
      collection = new Collection([4])
      collection.onItem('change', callback)
      collection.add(5)

 describe "indexFor", ->
    collection = null

    describe "indexOf functionality", ->
      beforeEach ->
        collection = new Collection([6,3,2])

      it "returns the index of an item", ->
        expect( collection.indexFor(3) ).to.eql(1)

      it "returns -1 if not found", ->
        expect( collection.indexFor(33) ).to.eql(-1)

    describe "using isEqualTo", ->
      person = (name) ->
        name: name
        isEqualTo: (other) ->
          other.name == @name

      beforeEach ->
        collection = new Collection([
          person('john')
          person('fred')
        ])

      it "returns the correct index", ->
        expect( collection.indexFor(person('fred')) ).to.eql(1)

      it "returns -1 if not found", ->
        expect( collection.indexFor(345) ).to.eql(-1)

  describe "indexWhere", ->
    collection = null

    beforeEach ->
      collection = new Collection(['john', 'fred', 'egg'])

    it "returns the correct index", ->
      expect( collection.indexWhere (name) -> name == 'fred' ).to.eql(1)

    it "returns -1 if not found", ->
      expect( collection.indexWhere (name) -> name == 'blurgh' ).to.eql(-1)

  describe "special positions", ->
    collection = null

    beforeEach ->
      collection = new Collection([4, 25, 235])

    it "returns the first", ->
      expect( collection.first() ).to.eql(4)

    it "returns the last", ->
      expect( collection.last() ).to.eql(235)

    it "returns undefined if it doesn't exist", ->
      collection = new Collection()
      expect( collection.first() ).to.eql(undefined)
      expect( collection.last() ).to.eql(undefined)

  describe "filtering", ->
    newModel = (attributes) -> {attrs: -> attributes}
    collection = null
    [m1, m2, m3, m4] = []

    beforeEach ->
      m1 = newModel(kung: 1, fu: 1)
      m2 = newModel(kung: 1, fu: 2)
      m3 = newModel(kung: 2, fu: 1)
      m4 = newModel(kung: 1, fu: 1)
      collection = new Collection [m1, m2, m3, m4]

    describe "where", ->
      it "returns an array of ones that exactly match", ->
        expect( collection.where(kung: 1, fu: 1) ).to.eql([m1, m4])

      it "ignores items that don't have an 'attrs' method", ->
        collection.add(4)
        expect( collection.where(kung: 1, fu: 1) ).to.eql([m1, m4])

    describe "removeWhere", ->
      it "remove ones that exactly match", ->
        collection.removeWhere(kung: 1, fu: 1)
        expect( collection.toArray() ).to.eql([m2, m3])

      it "ignores items that don't have an 'attrs' method", ->
        collection.add(4)
        collection.removeWhere(kung: 1, fu: 1)
        expect( collection.toArray() ).to.eql([m2, m3, 4])

  describe "uuid", ->
    it "has a uuid", ->
      expect( new Collection().uuid() ).to.match(/^[\w-]+$/)

  describe "pluck", ->
    collection = null

    beforeEach ->
      collection = new Collection()

    it "plucks an attribute", ->
      collection.set [
        {name: 'wing'}
        {name: 'nut'}
      ]
      expect( collection.pluck('name') ).to.eql(['wing', 'nut'])

    it "calls if a function", ->
      collection.set [
        {name: -> 'wing'}
        {name: -> 'nut'}
      ]
      expect( collection.pluck('name') ).to.eql(['wing', 'nut'])
