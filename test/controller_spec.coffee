Controller = requirejs('onion/controller')
eventEmitter = requirejs('onion/event_emitter')
Struct = requirejs('onion/struct')
extend = requirejs('onion/extend')

describe "Controller", ->

  describe "models", ->
    TestController = null
    controller = null

    beforeEach ->
      TestController = class TestController extends Controller
        @models 'one', 'two'

    it "throws an error if the required models are not passed in", ->
      expect(-> new TestController({one: 1}) ).to.throw("TestController missing model two")

    it "adds all models to the models object", ->
      controller = new TestController(one: 1, two: 2, three: 3)
      expect( controller.models ).to.eql({one: 1, two: 2, three: 3})

    it "adds only declared models to the controller itself", ->
      controller = new TestController(one: 1, two: 2, three: 3)
      expect( controller.one ).to.eql(1)
      expect( controller.two ).to.eql(2)
      expect( controller.three ).to.be.undefined

    it "makes a copy of the passed-in models object", ->
      models = {one: 1, two: 2}
      controller = new TestController(models)
      models.extra = 'extra'
      expect( controller.models ).to.eql({one: 1, two: 2})

    it "allows falsy values for models", ->
      models = {one: false, two: '', three: 0}
      controller = new TestController(models)
      TestController.models 'three'
      expect( controller.models ).to.eql({one: false, two: '', three: 0})

    it "allows calling twice, with no overlap", ->
      TestController.models 'two', 'three'
      expect( TestController.__requiredModels__ ).to.eql(['one', 'two', 'three'])

  describe "newModel", ->
    class TestController extends Controller
    controller = null

    beforeEach ->
      controller = new TestController()

    it "sets an instance variable", ->
      controller.newModel 'leg', "LEG"
      expect( controller.leg ).to.eql("LEG")

    it "adds the model to the models object", ->
      controller.newModel 'leg', "LEG"
      expect( controller.models.leg ).to.eql("LEG")

    it "returns the model", ->
      expect( controller.newModel 'leg', "LEG").to.eql("LEG")

  describe "onModel", ->
    TestController = null
    controller = null
    car = null
    dog = null
    breakdownCallback = null

    beforeEach ->
      breakdownCallback = sinon.spy()
      class TestController extends Controller
        @models 'car'
        @onModel 'car', 'start', 'onStart'
        @onModel 'dog', 'bark', 'onBark'
        @onModel 'car', 'breakdown', breakdownCallback
        onStartCalled: false
        onBarkCalled: false
        onStart: -> @onStartCalled = true
        onBark: -> @onBarkCalled = true
      car = new Struct()
      dog = new Struct()

    it "should listen to objects declared and passed in", ->
      controller = new TestController({car})
      car.emit('start')
      expect( controller.onStartCalled ).to.eql(true)

    it "should listen to objects created with newModel", ->
      controller = new TestController({car})
      controller.newModel 'dog', dog
      dog.emit('bark')
      expect( controller.onBarkCalled ).to.eql(true)

    it "allows passing in a function instead of a methodName string", ->
      controller = new TestController({car})
      car.emit('breakdown', 'some', 'args')
      assert.isTrue( breakdownCallback.calledWith('some', 'args') )

    it "allows space-separating a number of events", ->
      TestController.onModel 'car', ['empezar', 'comenzar'], 'onStart'
      controller = new TestController({car})
      car.emit('comenzar')
      expect( controller.onStartCalled ).to.eql(true)

    describe "disable/enable ModelListener", ->
      beforeEach ->
        controller = new TestController({car})
        controller.newModel 'dog', dog

      it "ignores disabled events", ->
        controller.disableModelListener('dog', 'bark')
        dog.emit('bark')
        expect( controller.onBarkCalled ).to.be.false

        controller.enableModelListener('dog', 'bark')
        dog.emit('bark')
        expect( controller.onBarkCalled ).to.be.true

      it "temporarily ignores disabled events", ->
        callbackCalled = false
        controller.disablingModelListener 'dog', 'bark', ->
          dog.emit('bark')
          expect( @ ).to.eql(controller)
          callbackCalled = true

        expect( callbackCalled ).to.be.true
        expect( controller.onBarkCalled ).to.be.false

        dog.emit('bark')
        expect( controller.onBarkCalled ).to.be.true

  describe "views", ->
    class TestController extends Controller

    it "allows passing in a view", ->
      view = {some: 'object'}
      controller = new TestController({}, view: view)
      expect( controller.view ).to.eql(view)

    it "uses the method initView if no view is passed in", ->
      view = {some: 'other object'}
      TestController.prototype.initView = ->
        view
      controller = new TestController()
      expect( controller.view ).to.eql(view)

    it "instantiates the specified view class if declared at the class level", ->
      View = ->
      expect( TestController.view(View) ).to.eql(TestController)
      controller = new TestController()
      expect( controller.view.constructor ).to.eql(View)

  describe "onView", ->
    controller = null
    emitter = null

    beforeEach ->
      controller = new Controller()
      emitter = extend({}, eventEmitter)

    it "raises an error if there is no view", ->
      expect ->
        controller.onView('chosen', 'something')
      .to.throw("there is no view to subscribe to")

    it "subscribes to the view and calls a method on itself with correct args", ->
      controller.view = emitter
      controller.something = sinon.spy()
      controller.onView('chosen', 'something')
      controller.view.emit('chosen', 'some', 'args')
      assert.isTrue( controller.something.calledWith('some', 'args') )

    it "allows passing a callback instead of a method name", ->
      controller.view = emitter
      callback = sinon.spy()
      controller.onView('chosen', callback)
      controller.view.emit('chosen', 'some', 'args')
      assert.isTrue( callback.calledWith('some', 'args') )

    it "has a class-level DSL", ->
      class MyController extends Controller
        @onView 'chosen', 'bingo'
        initView: -> emitter
        bingo: sinon.spy()

      controller = new MyController()
      controller.view.emit('chosen')
      assert.isTrue( controller.bingo.called )

  describe "child controllers", ->
    class TestController extends Controller
      initView: ->
        insertChild: ->
        destroy: ->

    class ChildController extends Controller
      initView: ->
        destroy: ->

    controller = undefined
    child = child1 = child2 = undefined

    beforeEach ->
      controller = new TestController()

    it "destroys child controllers when destroyed", ->
      child1 = controller.setChild '1', ChildController
      child2 = controller.setChild '2', ChildController
      sinon.spy(child1, 'destroy')
      sinon.spy(child2, 'destroy')
      controller.destroy()
      assert.isTrue( child1.destroy.called )
      assert.isTrue( child2.destroy.called )

    it "adds any models passed in to its own", ->
      controller.models = {one: 1}
      childController = controller.setChild 'blah', ChildController, {two: 2}
      expect( childController.models ).to.eql(one: 1, two: 2)

    describe "setChild", ->
      beforeEach ->
        controller = new TestController()
        sinon.spy(controller.view, 'insertChild')

      describe "in general", ->
        it "can receive an instantiated controller", ->
          givenChild = new ChildController
          returnedChild = controller.setChild 'list', givenChild
          expect(returnedChild).to.eql(givenChild)
          expect(controller.getChild 'list').to.eql(givenChild)

        it "inserts the child view", ->
          childController = controller.setChild 'otherblah', ChildController
          assert.isTrue( controller.view.insertChild.calledWith(childController.view, 'otherblah') )

      describe "when receiving a scalar id", ->
        beforeEach ->
          child = controller.setChild 'list', ChildController

        it "sets a child controller", ->
          expect( controller.getChild('list') ).to.eql(child)

        it "sets the child view", ->
          assert.isTrue( controller.view.insertChild.calledWith(child.view, 'list') )

        it "destroys a replaced child", ->
          sinon.spy(child, 'destroy')
          newChild = controller.setChild 'list', ChildController
          assert.isTrue( child.destroy.called )
          expect( controller.getChild('list') ).to.eql(newChild)

      describe "when receiving an array id", ->
        beforeEach ->
          child1 = controller.setChild ['list', 'uno'], ChildController
          child2 = controller.setChild ['list', 'dos'], ChildController

        it "sets a child controller", ->
          expect( controller.getChild(['list', 'uno']) ).to.eql(child1)
          expect( controller.getChild(['list', 'dos']) ).to.eql(child2)
          expect( controller.getChild(['list', 'tres']) ).to.be.undefined

        it "sets the child view", ->
          assert.isTrue( controller.view.insertChild.calledWith(child1.view, 'list', 'uno') )
          assert.isTrue( controller.view.insertChild.calledWith(child2.view, 'list', 'dos') )

        it "destroys a replaced child", ->
          sinon.spy(child2, 'destroy')
          newChild = controller.setChild ['list', 'dos'], ChildController
          assert.isTrue( child2.destroy.called )
          expect( controller.getChild(['list', 'dos']) ).to.eql(newChild)

    describe "addChild", ->
      beforeEach ->
        controller = new TestController()
        sinon.spy(controller.view, 'insertChild')

        child1 = controller.addChild 'list', ChildController
        child2 = controller.addChild 'list', ChildController

      it "sets a child controller", ->
        expect( controller.children['list'] ).to.eql({0: child1, 1: child2})

      it "sets the child view", ->
        assert.isTrue( controller.view.insertChild.calledWith(child1.view, 'list') )
        assert.isTrue( controller.view.insertChild.calledWith(child2.view, 'list') )

      # This fails if we don't make sure that separate __nextChildId__ values are used for each child
      it "doesn't mess up other children", ->
        other1 = controller.setChild 'blah', ChildController
        child3 = controller.addChild 'list', ChildController
        other2 = controller.setChild 'blah', ChildController
        expect( controller.children['blah'] ).to.eql({0: other2})

    describe "destroyChild", ->
      beforeEach ->
        child1 = controller.addChild 'list', ChildController
        child2 = controller.addChild 'list', ChildController

      it "destroys all items in the child", ->
        sinon.spy(child1, 'destroy')
        sinon.spy(child2, 'destroy')
        controller.destroyChild('list')
        assert.isTrue( child1.destroy.called )
        assert.isTrue( child2.destroy.called )

      it "does nothing when the child doesn't already exist", ->
        controller.destroyChild('spuds')

    describe "destroy", ->
      beforeEach ->
        child = controller.addChild 'loneChild', ChildController
        child1 = controller.addChild 'list', ChildController
        child2 = controller.addChild 'list', ChildController

      it "destroys all children", ->
        sinon.spy(child1, 'destroy')
        sinon.spy(child2, 'destroy')
        sinon.spy(child, 'destroy')
        controller.destroy()
        assert.isTrue( child1.destroy.called )
        assert.isTrue( child2.destroy.called )
        assert.isTrue( child.destroy.called )

    describe "domReady", ->
      view = null

      class TestView
        setDom: ->
          this.domWasSet = true

      beforeEach ->
        view = new TestView()
        controller = new Controller({}, {view})

      it "is called after the view calls setDom()", ->
        domReadyCalled = false
        domWasSet = false
        controller.domReady = ->
          domReadyCalled = true
          domWasSet = view.domWasSet

        view.setDom('body')

        expect( domReadyCalled ).to.eql(true)
        expect( domWasSet ).to.eql(true)