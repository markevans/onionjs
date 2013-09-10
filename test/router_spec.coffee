Router = requirejs('onion/router')

describe "Router", ->
  router = null

  describe "parsing", ->

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

  describe "generating routes", ->
    router = null

    beforeEach ->
      router = new Router()

    it "raises if the named route doesn't exist", ->
      expect( ->
        router.path('greeting', who: 'me')
      ).to.throw("route greeting does not exist")

    it "creates a path", ->
      router.route("greeting", '/greeting/:what')
      expect( router.path('greeting', what: 'hi') ).to.eql("/greeting/hi")

    it "adds a query string if extra params are passed", ->
      router.route("greeting", '/greeting/:what')
      expect( router.path('greeting', what: 'hi', who: 'me', when: 'now') ).to.eql("/greeting/hi?who=me&when=now")

