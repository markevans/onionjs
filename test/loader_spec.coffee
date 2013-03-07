requirejs [
  'onion/loader'
], (Loader) ->

  describe "Loader", ->

    describe "initializing", ->
      it "allows setting loaders on init", ->
        loaders =
          loaders:
            something: ->
        loader = new Loader({loaders})
        expect( loader.loaders ).toEqual(loaders)

    describe "load", ->
      loader = null

      beforeEach ->
        loader = new Loader()
        loader.callsToFish = []
        loader.loaders =
          fish: (deferred, some, args) ->
            @callsToFish.push [some, args]

      it "throws an error if the loader doesn't exist", ->
        expect(->
          loader.load('eggs')
        ).toThrow("loader \"eggs\" doesn't exist")

      it "calls the method the first time with the given arguments, setting this to the loader", ->
        result = loader.load('fish', 3, 'bunty')
        expect( loader.callsToFish ).toEqual([[3, 'bunty']])

      it "doesn't call the method the second time but returns the same deferred each time", ->
        result1 = loader.load('fish', 3, 'bunty')
        expect( typeof result1.done ).toEqual('function') # make sure it's a deferred
        expect( loader.callsToFish ).toEqual([[3, 'bunty']])

        result2 = loader.load('fish', 3, 'irrelevant arg')
        expect( result2 ).toEqual(result1)
        expect( loader.callsToFish ).toEqual([[3, 'bunty']])
