eventEmitter = requirejs('onion/event_emitter')

copy = (src, dest) ->
  dest[key] = value for key, value of src
  dest

describe "event_emitter", ->

  describe "subscribing/unsubscribing", ->
    f1 = ->
    f2 = ->
    f3 = ->
    emitter = null

    beforeEach ->
      emitter = copy(eventEmitter, {})

    it "subscribes", ->
      emitter.on('egg', f1)
      expect( emitter.channels()['egg'] ).to.eql([{event: 'egg', callback: f1}])

    it "unsubscribes", ->
      emitter.on('egg', f1)
      emitter.off('egg', f1)
      expect( emitter.channels()['egg'] ).to.eql([])

    it "doesn't unsubscribe if the channel is not the same", ->
      emitter.on('egg', f1)
      emitter.off('bacon', f1)
      expect( emitter.channels()['egg'] ).to.eql([{event: 'egg', callback: f1}])

    it "unsubscribes the correct subscription", ->
      emitter.on('egg', f1)
      emitter.on('egg', f2)
      emitter.on('egg', f3)

      emitter.off('egg', f2)

      expect( emitter.channels()['egg'] ).to.eql([
        {event: 'egg', callback: f1}
        {event: 'egg', callback: f3}
      ])

  describe "emit", ->
    it "allows emitting more than one arg", ->
      emitter = copy(eventEmitter, {})
      callback = sinon.spy()
      emitter.on('egg', callback)
      emitter.emit('egg', 'bar', 'fly')
      assert.isTrue( callback.calledWith('bar', 'fly') )

  describe "one", ->
    it "subscribes the caller to only one event", ->
      emitter = copy(eventEmitter, {})
      callback = sinon.spy()
      emitter.one('egg', callback)
      emitter.emit('egg', 'bar', 'fly')
      emitter.emit('egg', 'bar', 'flea')
      assert.isTrue( callback.calledWith('bar', 'fly') )
      assert.isFalse( callback.calledWith('bar', 'flea') )

  describe "silently", ->
    emitter = null

    beforeEach ->
      emitter = copy(eventEmitter, {})

    it "doesn't emit any events", ->
      x = null
      callback = sinon.spy()
      emitter.on 'something', callback
      emitter.silently ->
        x = 3
        emitter.emit('something')
      expect( x ).to.eql(3)
      assert.isFalse( callback.called )
