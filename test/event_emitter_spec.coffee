requirejs ['onion/event_emitter'], (eventEmitter)->

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
        expect( emitter.channels()['egg'] ).toEqual([{event: 'egg', callback: f1}])

      it "unsubscribes", ->
        emitter.on('egg', f1)
        emitter.off('egg', f1)
        expect( emitter.channels()['egg'] ).toEqual([])

      it "doesn't unsubscribe if the channel is not the same", ->
        emitter.on('egg', f1)
        emitter.off('bacon', f1)
        expect( emitter.channels()['egg'] ).toEqual([{event: 'egg', callback: f1}])

      it "unsubscribes the correct subscription", ->
        emitter.on('egg', f1)
        emitter.on('egg', f2)
        emitter.on('egg', f3)

        emitter.off('egg', f2)

        expect( emitter.channels()['egg'] ).toEqual([
          {event: 'egg', callback: f1}
          {event: 'egg', callback: f3}
        ])

    describe "emit", ->
      it "allows emitting more than one arg", ->
        emitter = copy(eventEmitter, {})
        callback = jasmine.createSpy(->)
        emitter.on('egg', callback)
        emitter.emit('egg', 'bar', 'fly')
        expect( callback ).toHaveBeenCalledWith('bar', 'fly')

    describe "one", ->
      it "subscribes the caller to only one event", ->
        emitter = copy(eventEmitter, {})
        callback = jasmine.createSpy(->)
        emitter.one('egg', callback)
        emitter.emit('egg', 'bar', 'fly')
        emitter.emit('egg', 'bar', 'flea')
        expect( callback ).toHaveBeenCalledWith('bar', 'fly')
        expect( callback ).not.toHaveBeenCalledWith('bar', 'flea')

    describe "silently", ->
      emitter = null

      beforeEach ->
        emitter = copy(eventEmitter, {})

      it "doesn't emit any events", ->
        x = null
        callback = jasmine.createSpy(->)
        emitter.on 'something', callback
        emitter.silently ->
          x = 3
          emitter.emit('something')
        expect( x ).toEqual(3)
        expect( callback ).not.toHaveBeenCalled()
