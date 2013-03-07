requirejs [
  'onion/membership'
  'onion/collection'
], (Membership, Collection) ->

  describe "Membership", ->
    collection = null
    item = null
    otherItem = null
    membership = null

    beforeEach ->
      item = {}
      otherItem = {}
      collection = new Collection()
      membership = new Membership(item, collection)

    describe "listening to add", ->

      it "says when a collection doesn't contain an item", ->
        expect( membership.exists() ).toEqual(false)

      it "says when an item contains an object", ->
        collection.set([item])
        expect( membership.exists() ).toEqual(true)

      it "emits when the item is added", ->
        expect(->
          collection.add(item)
        ).toEmitOn(membership, 'add')

      it "emits when added with set", ->
        expect(->
          collection.set([item])
        ).toEmitOn(membership, 'add')

      it "emits when added with addMany", ->
        expect(->
          collection.addMany([item])
        ).toEmitOn(membership, 'add')

      it "doesn't emit when another item is added", ->
        expect(->
          collection.add(otherItem)
        ).not.toEmitOn(membership, 'add')

    describe "listening to remove", ->
      beforeEach ->
        collection.set([item, otherItem])

      it "emits when the item is removed", ->
        expect(->
          collection.remove(item)
        ).toEmitOn(membership, 'remove')

      it "emits when removed with set", ->
        expect(->
          collection.set([])
        ).toEmitOn(membership, 'remove')

      it "emits when removed with removeMany", ->
        expect(->
          collection.removeMany([item])
        ).toEmitOn(membership, 'remove')

      it "doesn't emit when another item is removed", ->
        expect(->
          collection.remove(otherItem)
        ).not.toEmitOn(membership, 'remove')

    describe "adding", ->
      it "adds to the collection", ->
        membership.add()
        expect( collection.contains(item) ).toEqual(true)

    describe "removing", ->
      it "removes from the collection", ->
        membership.add()
        membership.remove()
        expect( collection.contains(item) ).toEqual(false)

    describe "toggling", ->
      it "adds if it doesn't exist", ->
        membership.toggle()
        expect( collection.contains(item) ).toEqual(true)

      it "removes if it exists", ->
        membership.add()
        membership.toggle()
        expect( collection.contains(item) ).toEqual(false)
