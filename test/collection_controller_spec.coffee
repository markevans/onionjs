Controller = requirejs('onion/controller')
collectionController = requirejs('onion/collection_controller')
Collection = requirejs('onion/collection')
Struct = requirejs('onion/struct')

describe "collectionController", ->
  controller = null
  collection = null
  ParentController = null

  numberOfChildren = (controller) ->
    Object.keys(controller.__children__).length

  beforeEach ->
    class ChildController extends Controller
    class OtherChildController extends Controller
    class ParentController extends Controller
      @models 'items'
      @use collectionController, 'items', 'item', ChildController

    collection = new Collection()
    controller = new ParentController(items: collection)

    controller.spawn(OtherChildController)
    expect( numberOfChildren(controller) ).to.equal(1)

  it "responds to added items", ->
    collection.addMany([new Struct(), new Struct()])
    expect( numberOfChildren(controller) ).to.equal(3)

  it "responds to removed items", ->
    struct = new Struct()
    collection.addMany([struct, new Struct()])
    collection.remove(struct)
    expect( numberOfChildren(controller) ).to.equal(2)

  it "responds to set items", ->
    collection.add(new Struct())
    expect( numberOfChildren(controller) ).to.equal(2)
    collection.set([])
    expect( numberOfChildren(controller) ).to.equal(1)

  it "allows setting the children", ->
    collection.set([new Struct(), new Struct()])
    controller = new ParentController(items: collection)
    controller.syncWithCollection()
    expect( numberOfChildren(controller) ).to.equal(2)

