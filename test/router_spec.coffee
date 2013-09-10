Router = requirejs('onion/router')

describe "Router", ->
  router = null

  describe "parsing urls", ->

    beforeEach ->
      router = new Router()

    it "returns nothing if not matched", ->
      expect( router.match("/hi/everyone") ).to.eql(null)

    it "returns params if it matches", ->
      router.route("greeting", "/greeting/:what/:who")
      result = router.match("/greeting/hi/everyone")
      expect( result.name ).to.eql('greeting')
      expect( result.params ).to.eql(what: 'hi', who: 'everyone')

    it "adds extra params not in the path part", ->
      router.route("greeting", "/greeting/:what")
      result = router.match("/greeting/hi?who=everyone")
      expect( result.name ).to.eql('greeting')
      expect( result.params ).to.eql(what: 'hi', who: 'everyone')

    it "doesn't match longer routes that contain the pattern", ->
      router.route("greeting", "/greeting/:what/:who")
      expect( router.match("/greeting/hi/everyone/wassup") ).to.eql(null)

