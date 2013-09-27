AppState = requirejs('onion/app_state')

describe "AppState", ->
  appState = null

  beforeEach ->
    appState = new AppState()

  it "throws on load if state doesn't exist", ->
    expect(->
      appState.load('blarney', some: 'params')
    ).to.throw("no such state blarney")

  it "throws on save if state doesn't exist", ->
    expect(->
      appState.save('blarney')
    ).to.throw("no such state blarney")

  describe "with a registered state", ->
    beforeEach ->
      appState.currentTab = 1

      appState.state 'page',
        toParams: ->
          {tab: @currentTab}
        fromParams: (params) ->
          @currentTab = params.tab

    it "saves the current state", ->
      sinon.spy(appState, 'emit')
      expect( appState.save('page') )
      expect( appState.currentState() ).to.eql(name: 'page', params: {tab: 1})
      expect( appState.emit.calledWith("save", "page", tab: 1) ).to.be.true

    it "can return to a state", ->
      appState.load('page', tab: 2)
      expect( appState.currentTab ).to.eql(2)
      expect( appState.currentState() ).to.eql(name: 'page', params: {tab: 2})

    it "can run a state function", ->
      appState.run('page', tab: 2)
      expect( appState.currentTab ).to.eql(2)
      expect( appState.currentState() ).to.be.undefined

    it "doesn't run a state again if it's already there", ->
      sinon.spy( appState, 'run' )
      appState.load('page', tab: 2)
      appState.load('page', tab: 2)
      expect( appState.run.callCount ).to.equal(1)

    it "runs a state again if the params are different", ->
      sinon.spy( appState, 'run' )
      appState.load('page', tab: 2)
      appState.load('page', tab: 3)
      expect( appState.run.callCount ).to.equal(2)

    it "runs a state again if the name is different", ->
      appState.state 'tab',
        toParams: -> {}
        fromParams: ->
      sinon.spy( appState, 'run' )
      appState.load('page', tab: 2)
      appState.load('tab', tab: 2)
      expect( appState.run.callCount ).to.equal(2)
