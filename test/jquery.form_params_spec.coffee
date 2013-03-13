$ = requirejs('jquery')
requirejs('onion/jquery.form_params')

describe "jquery formParams plugin", ->

  it "gives form params for a form", ->
    html = """
           <form>
             <input name="golf", value="course" />
             <input name="swimming", value="pool" />
           </form>
           """
    expect( $(html).formParams() ).to.eql({
      golf: 'course'
      swimming: 'pool'
    })

  it "works for radio buttons", ->
    html = """
           <form>
             <input type="radio" name="golf", value="great" checked="checked" />
             <input type="radio" name="golf", value="stuff" />
           </form>
           """
    expect( $(html).formParams() ).to.eql(golf: 'great')

  it "works for checked checkboxes", ->
    html = """
           <form>
             <input type="checkbox" name="golf", value="great" checked="checked" />
           </form>
           """
    expect( $(html).formParams() ).to.eql(golf: 'great')

  it "works for unchecked checkboxes", ->
    html = """
           <form>
             <input type="checkbox" name="golf", value="great" />
           </form>
           """
    expect( $(html).formParams() ).to.eql(golf: null)

  it "allows specifying a namespace", ->
    html = """
           <form>
             <input name="joke[golf]", value="course" />
             <input name="joke[swimming]", value="pool" />
             <input name="japes", value="grapes" />
           </form>
           """
    expect( $(html).formParams('joke') ).to.eql({
      golf: 'course'
      swimming: 'pool'
    })

  it "works for unchecked checkboxes with a namespace", ->
    html = """
           <form>
             <input type="checkbox" name="joke[golf]", value="great" />
           </form>
           """
    expect( $(html).formParams('joke') ).to.eql(golf: null)
