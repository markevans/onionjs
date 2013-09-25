Bookmarks = requirejs('onion/bookmarks')

describe "Bookmarks", ->
  bookmarks = null

  beforeEach ->
    bookmarks = new Bookmarks()

  it "throws if bookmark doesn't exist", ->
    expect(->
      bookmarks.run('blarney', some: 'params')
    ).to.throw("no such bookmark blarney")


  describe "with a registered bookmark", ->
    beforeEach ->
      sinon.spy(bookmarks, 'emit')
      bookmarks.bookmark 'blarney', (params) ->
        @message = "kiss the blarney #{params.what}"
        4

    it "runs the bookmarked function", ->
      expect( bookmarks.run('blarney', what: 'stone') ).to.eql(4)
      expect( bookmarks.message ).to.eql("kiss the blarney stone")
      expect( bookmarks.emit.called ).to.be.false

    it "runs the bookmarked function and emits an event", ->
      expect( bookmarks.visit('blarney', what: 'stone') ).to.eql(4)
      expect( bookmarks.message ).to.eql("kiss the blarney stone")
      expect( bookmarks.emit.calledWith("visit", "blarney", what: 'stone') ).to.be.true
