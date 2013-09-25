Serializer = requirejs('onion/serializer')

describe "Serializer", ->
  serializer = null

  describe "serializing", ->

    beforeEach ->
      serializer = new Serializer()
      serializer.serializeRule('egg', (params) -> params.howCooked )

    it "returns nothing if not matched", ->
      expect(-> serializer.serialize('fish', {howCooked: 'boiled'}) ).to.throw('cannot serialize with name "fish"')

    it "serializes if matched", ->
      expect( serializer.serialize('egg', {howCooked: 'boiled'}) ).to.eql("boiled")

  describe "deserializing", ->
    beforeEach ->
      serializer = new Serializer()
      serializer.deserializeRule /b(oiled)/, 'egg', (string, matches) ->
        {
          s: string
          r: matches[0]
          g: matches[1]
        }

    it "returns nothing if not matched", ->
      expect(-> serializer.deserialize('fried') ).to.throw('cannot deserialize "fried"')

    it "serializes if matched", ->
      expect( serializer.deserialize('me boiled').name ).to.eql('egg')
      expect( serializer.deserialize('me boiled').params ).to.eql(
        s: "me boiled"
        r: "boiled"
        g: "oiled"
      )
