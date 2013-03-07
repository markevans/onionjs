requirejs [
  'onion/controller'
  'onion/event_emitter'
  'onion/struct'
], (Controller, eventEmitter, Struct) ->

  describe "Controller", ->

    describe "models", ->
      TestController = null
      controller = null

      beforeEach ->
        TestController = class TestController extends Controller
          @models 'one', 'two'

      it "throws an error if the required models are not passed in", ->
        expect(-> new TestController({one: 1}) ).toThrow(new Error("TestController missing model two"))

      it "adds all models to the models object", ->
        controller = new TestController(one: 1, two: 2, three: 3)
        expect( controller.models ).toEqual({one: 1, two: 2, three: 3})

      it "adds only declared models to the controller itself", ->
        controller = new TestController(one: 1, two: 2, three: 3)
        expect( controller.one ).toEqual(1)
        expect( controller.two ).toEqual(2)
        expect( controller.three ).toBeUndefined()

      it "makes a copy of the passed-in models object", ->
        models = {one: 1, two: 2}
        controller = new TestController(models)
        models.extra = 'extra'
        expect( controller.models ).toEqual({one: 1, two: 2})

      it "allows calling twice, with no overlap", ->
        TestController.models 'two', 'three'
        expect( TestController.__requiredModels__ ).toEqual(['one', 'two', 'three'])

    describe "newModel", ->
      class TestController extends Controller
      controller = null

      beforeEach ->
        controller = new TestController()

      it "sets an instance variable", ->
        controller.newModel 'leg', "LEG"
        expect( controller.leg ).toEqual("LEG")

      it "adds the model to the models object", ->
        controller.newModel 'leg', "LEG"
        expect( controller.models.leg ).toEqual("LEG")

      it "returns the model", ->
        expect( controller.newModel 'leg', "LEG").toEqual("LEG")

    describe "onModel", ->
      TestController = null
      controller = null
      car = null
      dog = null
      breakdownCallback = null

      beforeEach ->
        breakdownCallback = jasmine.createSpy()
        class TestController extends Controller
          @models 'car'
          @onModel 'car', 'start', 'onStart'
          @onModel 'dog', 'bark', 'onBark'
          @onModel 'car', 'breakdown', breakdownCallback
          onStart: -> @onStartCalled = true
          onBark: -> @onBarkCalled = true
        car = new Struct()
        dog = new Struct()

      it "should listen to objects declared and passed in", ->
        controller = new TestController({car})
        car.emit('start')
        expect( controller.onStartCalled ).toEqual(true)

      it "should listen to objects created with newModel", ->
        controller = new TestController({car})
        controller.newModel 'dog', dog
        dog.emit('bark')
        expect( controller.onBarkCalled ).toEqual(true)

      it "allows passing in a function instead of a methodName string", ->
        controller = new TestController({car})
        car.emit('breakdown', 'some', 'args')
        expect( breakdownCallback ).toHaveBeenCalledWith('some', 'args')

      it "allows space-separating a number of events", ->
        TestController.onModel 'car', ['empezar', 'comenzar'], 'onStart'
        controller = new TestController({car})
        car.emit('comenzar')
        expect( controller.onStartCalled ).toEqual(true)

      describe "disable/enable ModelListener", ->
        beforeEach ->
          controller = new TestController({car})
          controller.newModel 'dog', dog

        it "ignores disabled events", ->
          controller.disableModelListener('dog', 'bark')
          dog.emit('bark')
          expect( controller.onBarkCalled ).toBeFalsy()

          controller.enableModelListener('dog', 'bark')
          dog.emit('bark')
          expect( controller.onBarkCalled ).toBeTruthy()

        it "temporarily ignores disabled events", ->
          callbackCalled = false
          controller.disablingModelListener 'dog', 'bark', ->
            dog.emit('bark')
            expect( @ ).toEqual(controller)
            callbackCalled = true

          expect( callbackCalled ).toBeTruthy()
          expect( controller.onBarkCalled ).toBeFalsy()

          dog.emit('bark')
          expect( controller.onBarkCalled ).toBeTruthy()

    describe "views", ->
      class TestController extends Controller

      it "allows passing in a view", ->
        view = {some: 'object'}
        controller = new TestController({}, view: view)
        expect( controller.view ).toEqual(view)

      it "uses the method initView if no view is passed in", ->
        view = {some: 'other object'}
        TestController.prototype.initView = ->
          view
        controller = new TestController()
        expect( controller.view ).toEqual(view)

      it "instantiates the specified view class if declared at the class level", ->
        View = ->
        expect( TestController.view(View) ).toEqual(TestController)
        controller = new TestController()
        expect( controller.view.constructor ).toEqual(View)

    describe "onView", ->
      controller = null

      beforeEach ->
        controller = new Controller()

      it "raises an error if there is no view", ->
        expect ->
          controller.onView('chosen', 'something')
        .toThrow("there is no view to subscribe to")

      it "subscribes to the view and calls a method on itself with correct args", ->
        controller.view = eventEmitter
        controller.something = jasmine.createSpy()
        controller.onView('chosen', 'something')
        controller.view.emit('chosen', 'some', 'args')
        expect( controller.something ).toHaveBeenCalledWith('some', 'args')

      it "allows passing a callback instead of a method name", ->
        controller.view = eventEmitter
        callback = jasmine.createSpy()
        controller.onView('chosen', callback)
        controller.view.emit('chosen', 'some', 'args')
        expect( callback ).toHaveBeenCalledWith('some', 'args')

      it "has a class-level DSL", ->
        class MyController extends Controller
          @onView 'chosen', 'bingo'
          initView: -> eventEmitter
          bingo: jasmine.createSpy()

        controller = new MyController()
        controller.view.emit('chosen')
        expect( controller.bingo ).toHaveBeenCalled()

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
        spyOn(child1, 'destroy')
        spyOn(child2, 'destroy')
        controller.destroy()
        expect( child1.destroy ).toHaveBeenCalled()
        expect( child2.destroy ).toHaveBeenCalled()

      it "adds any models passed in to its own", ->
        controller.models = {one: 1}
        childController = controller.setChild 'blah', ChildController, {two: 2}
        expect( childController.models ).toEqual(one: 1, two: 2)

      describe "setChild", ->
        beforeEach ->
          controller = new TestController()
          spyOn(controller.view, 'insertChild')

        describe "in general", ->
          it "can receive an instantiated controller", ->
            givenChild = new ChildController
            returnedChild = controller.setChild 'list', givenChild
            expect(returnedChild).toEqual(givenChild)
            expect(controller.getChild 'list').toEqual(givenChild)

          it "inserts the child view", ->
            childController = controller.setChild 'otherblah', ChildController
            expect( controller.view.insertChild ).toHaveBeenCalledWith(childController.view, 'otherblah')

        describe "when receiving a scalar id", ->
          beforeEach ->
            child = controller.setChild 'list', ChildController

          it "sets a child controller", ->
            expect( controller.getChild('list') ).toEqual(child)

          it "sets the child view", ->
            expect( controller.view.insertChild ).toHaveBeenCalledWith(child.view, 'list')

          it "destroys a replaced child", ->
            spyOn(child, 'destroy')
            newChild = controller.setChild 'list', ChildController
            expect( child.destroy ).toHaveBeenCalled()
            expect( controller.getChild('list') ).toEqual(newChild)

        describe "when receiving an array id", ->
          beforeEach ->
            child1 = controller.setChild ['list', 'uno'], ChildController
            child2 = controller.setChild ['list', 'dos'], ChildController

          it "sets a child controller", ->
            expect( controller.getChild(['list', 'uno']) ).toEqual(child1)
            expect( controller.getChild(['list', 'dos']) ).toEqual(child2)
            expect( controller.getChild(['list', 'tres']) ).toBeUndefined()

          it "sets the child view", ->
            expect( controller.view.insertChild ).toHaveBeenCalledWith(child1.view, 'list')
            expect( controller.view.insertChild ).toHaveBeenCalledWith(child2.view, 'list')

          it "destroys a replaced child", ->
            spyOn(child2, 'destroy')
            newChild = controller.setChild ['list', 'dos'], ChildController
            expect( child2.destroy ).toHaveBeenCalled()
            expect( controller.getChild(['list', 'dos']) ).toEqual(newChild)

      describe "addChild", ->
        beforeEach ->
          controller = new TestController()
          spyOn(controller.view, 'insertChild')

          child1 = controller.addChild 'list', ChildController
          child2 = controller.addChild 'list', ChildController

        it "sets a child controller", ->
          expect( Object.values(controller.children['list']) ).toEqual([child1, child2])

        it "sets the child view", ->
          expect( controller.view.insertChild ).toHaveBeenCalledWith(child1.view, 'list')
          expect( controller.view.insertChild ).toHaveBeenCalledWith(child2.view, 'list')

        # This fails if we don't make sure that separate __nextChildId__ values are used for each child
        it "doesn't mess up other children", ->
          other1 = controller.setChild 'blah', ChildController
          child3 = controller.addChild 'list', ChildController
          other2 = controller.setChild 'blah', ChildController
          expect( Object.values(controller.children['blah']) ).toEqual([other2])

      describe "destroyChild", ->
        beforeEach ->
          child1 = controller.addChild 'list', ChildController
          child2 = controller.addChild 'list', ChildController

        it "destroys all items in the child", ->
          spyOn(child1, 'destroy')
          spyOn(child2, 'destroy')
          controller.destroyChild('list')
          expect( child1.destroy ).toHaveBeenCalled()
          expect( child2.destroy ).toHaveBeenCalled()

        it "does nothing when the child doesn't already exist", ->
          controller.destroyChild('spuds')

      describe "destroy", ->
        beforeEach ->
          child = controller.addChild 'loneChild', ChildController
          child1 = controller.addChild 'list', ChildController
          child2 = controller.addChild 'list', ChildController

        it "destroys all children", ->
          spyOn(child1, 'destroy')
          spyOn(child2, 'destroy')
          spyOn(child, 'destroy')
          controller.destroy()
          expect( child1.destroy ).toHaveBeenCalled()
          expect( child2.destroy ).toHaveBeenCalled()
          expect( child.destroy ).toHaveBeenCalled()

