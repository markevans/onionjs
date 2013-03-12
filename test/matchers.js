chai= requirejs('chai')

// toEmitOn
chai.Assertion.addMethod('toEmitOn', function (object, eventName) {
  var slice = Array.prototype.slice

  var eventArgs = slice.call(arguments, 2)
  var eventCalled = false
  var eventCalledWith = null

  // Subscribe to the event
  object.on(eventName, function () {
    eventCalled = true
    eventCalledWith = slice.call(arguments)
  })

  // Call the given function
  this._obj()

  this.assert(
    eventCalled,
    "expected event " + eventName + " to be called",
    "expected event " + eventName + " not to be called"
  )
  if (eventArgs.length) {
    new chai.Assertion(eventCalledWith).to.eql(eventArgs)
  }
})
