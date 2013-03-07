decorator = requirejs('onion/decorator')

describe "decorator", ->

  describe "after", ->
    object = null

    beforeEach ->
      object = {
        upcase: (string) ->
          @result = string.toUpperCase()
          'originalReturnValue'
      }

    it "works with a function", ->
      decorator.after object, 'upcase', (string) ->
        @result += ' hooray'
      object.upcase('elephant')
      expect( object.result ).toEqual('ELEPHANT hooray')

    it "works with a string", ->
      decorator.after object, 'upcase', 'addThing'
      object.addThing = (string) ->
          @result += string
      object.upcase('elephant')
      expect( object.result ).toEqual('ELEPHANTelephant')

    it "doesn't change the return value", ->
      decorator.after object, 'upcase', ->
      expect( object.upcase('elephant') ).toEqual('originalReturnValue')
