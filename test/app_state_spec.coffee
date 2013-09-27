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
