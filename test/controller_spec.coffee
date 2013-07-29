Controller = requirejs('onion/controller')
eventEmitter = requirejs('onion/event_emitter')
Struct = requirejs('onion/struct')
extend = requirejs('onion/extend')

describe "Controller", ->

  describe "uuid", ->
    TestController = null

    beforeEach ->
      class TestController extends Controller

    it "has a uuid of an appropriate format", ->
      controller = new Controller
      expect( controller.uuid() ).to.match(/[\w+-]+/)

    it "is unique per controller", ->
      controller1 = new Controller
      controller2 = new Controller
      expect( controller1.uuid() ).not.to.eql( controller2.uuid() )

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

    it "instantiates the specified view class if declared at the class level, passing in the models", ->
      initializer = sinon.spy()
      class View
        constructor: initializer
      expect( TestController.view(View) ).to.eql(TestController)
      controller = new TestController()
      expect( controller.view.constructor ).to.eql(View)
      expect( initializer.calledWith(models: controller.models) ).to.be.true

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

  describe "children", ->
    parent = null
    ChildController = null

    beforeEach ->
      parent = new Controller
      parent.view = { insertChild: -> }
      ChildController = class ChildController extends Controller
        initView: -> {}
        run: -> @hasRun = true

    describe "spawn", ->
      it "creates a new child controller", ->
        child = parent.spawn(ChildController)
        expect( child ).to.be.an.instanceof(ChildController)

      it "calls run() on the child controller", ->
        child = parent.spawn(ChildController)
        expect( child.hasRun ).to.be.true

      it "calls insertChild on the parent's view", ->
        sinon.spy(parent.view, 'insertChild')
        child = parent.spawn(ChildController)
        expect( parent.view.insertChild.calledWith(child.view) ).to.be.true

      it "allows adding models", ->
        child = parent.spawn(ChildController, models: {egg: 'nog'})
        expect( child.models.egg ).to.equal('nog')

    describe "spawnWithModel", ->
      egg = null

      beforeEach ->
        egg = {uuid: -> 'abc'}

      it "gives the child access to the passed model", ->
        child = parent.spawnWithModel(ChildController, 'egg', egg)
        expect( child.models.egg ).to.equal(egg)

      it "allows passing extra models", ->
        child = parent.spawnWithModel(ChildController, 'egg', egg, models: {food: 'pizza'})
        expect( child.models.food ).to.equal('pizza')

      it "passes the model and modelName to insertChild", ->
        sinon.spy(parent.view, 'insertChild')
        child = parent.spawnWithModel(ChildController, 'egg', egg)
        expect( parent.view.insertChild.calledWith(child.view, modelName: 'egg', model: egg) ).to.be.true

    describe "destroyChildren", ->
      OtherChildController = null

      beforeEach ->
        OtherChildController = class OtherChildController extends Controller

      it "destroys all children", ->
        child1 = parent.spawn(ChildController)
        child2 = parent.spawn(OtherChildController)
        sinon.spy(child1, 'destroy')
        sinon.spy(child2, 'destroy')

        parent.destroyChildren()

        expect( child1.destroy.called ).to.be.true
        expect( child2.destroy.called ).to.be.true

      it "doesn't destroy an already destroyed child", ->
        child = parent.spawn(ChildController)
        sinon.spy(child, 'destroy')
        parent.destroyChildren()
        parent.destroyChildren()
        expect( child.destroy.calledOnce ).to.be.true

      it "destroys all children of a given type", ->
        child1 = parent.spawn(ChildController)
        child2 = parent.spawn(OtherChildController)
        child3 = parent.spawn(ChildController)
        sinon.spy(child1, 'destroy')
        sinon.spy(child2, 'destroy')
        sinon.spy(child3, 'destroy')

        parent.destroyChildren(type: 'ChildController')

        expect( child1.destroy.called ).to.be.true
        expect( child2.destroy.called ).to.be.false
        expect( child3.destroy.called ).to.be.true

    describe "destroyChildWithModel", ->
      it "destroys a specific child, matched with a model (on its uuid)", ->
        item1 = {uuid: -> 'a'}
        item2 = {uuid: -> 'b'}

        child1 = parent.spawn(ChildController)
        child2 = parent.spawnWithModel(ChildController, 'item', item1)
        child3 = parent.spawnWithModel(ChildController, 'item', item2)
        sinon.spy(child1, 'destroy')
        sinon.spy(child2, 'destroy')
        sinon.spy(child3, 'destroy')

        parent.destroyChildWithModel('item', item2)

        expect( child1.destroy.called ).to.be.false
        expect( child2.destroy.called ).to.be.false
        expect( child3.destroy.called ).to.be.true

  describe "destroy", ->
    it "destroys children", ->

