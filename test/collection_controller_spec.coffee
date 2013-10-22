Controller = requirejs('onion/controller')
collectionController = requirejs('onion/collection_controller')
Collection = requirejs('onion/collection')
Struct = requirejs('onion/struct')

describe "collectionController", ->
  controller = null
  collection = null
  ParentController = null
  ChildController = null

  assertNumChildren = (num) ->
    expect( Object.keys(controller.__children__).length ).to.equal(num)

  beforeEach ->
    class ChildController extends Controller
    class ParentController extends Controller
      @models 'items'
      @use collectionController, 'items', 'item', ChildController

    collection = new Collection()
    controller = new ParentController(items: collection)

  it "responds to items added with add", ->
    collection.add(new Struct())
    assertNumChildren(1)

  it "responds to items added with addMany", ->
    collection.addMany([new Struct(), new Struct()])
    assertNumChildren(2)

  it "responds to items removed with remove", ->
    struct = new Struct()
    collection.add(struct)
    collection.add(new Struct())
    assertNumChildren(2)
    collection.remove(struct)
    assertNumChildren(1)

  it "responds to items removed with removeMany", ->
    struct = new Struct()
    collection.addMany([struct, new Struct()])
    assertNumChildren(2)
    collection.removeMany([struct])
    assertNumChildren(1)

  it "responds to set items", ->
    collection.add(new Struct())
    assertNumChildren(1)
    collection.set([new Struct(), new Struct()])
    assertNumChildren(2)

  it "doesn't remove/add more than it needs to on set (this was causing wierd things to happen)", ->
    sinon.spy(ChildController::, 'init')
    sinon.spy(ChildController::, 'destroy')
    collection.set([new Struct()])
    expect( ChildController::init.callCount ).to.equal(1)
    expect( ChildController::destroy.callCount ).to.equal(0)

  describe "syncing (for one-off initialization)", ->
    beforeEach ->
      collection.set([new Struct(), new Struct()])

    it "syncs", ->
      controller = new ParentController(items: collection)
      assertNumChildren(0)
      controller.syncWithCollection()
      assertNumChildren(2)

    it "syncs with differently named selected models", ->
      class PadreController extends Controller
        @models 'shingle.beans'
        @use collectionController, 'beans', 'bean', ChildController
      controller = new PadreController(shingle: {beans: collection})
      controller.syncWithCollection()
      assertNumChildren(2)

  it "doesn't interfere other children", ->
    class OtherChildController extends Controller
    controller.spawn(OtherChildController)
    assertNumChildren(1)
    s = new Struct()
    collection.add(s)
    assertNumChildren(2)
    collection.remove(s)
    assertNumChildren(1)

