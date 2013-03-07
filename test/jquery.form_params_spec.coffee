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
    expect( $(html).formParams() ).toEqual({
      golf: 'course'
      swimming: 'pool'
    })


  it "works for checkboxes", ->
    html = """
           <form>
             <input type="checkbox" name="golf", value="great" checked="checked" />
             <input type="checkbox" name="golf", value="stuff" />
           </form>
           """
    expect( $(html).formParams() ).toEqual(golf: 'great')

  it "allows specifying a namespace", ->
    html = """
           <form>
             <input name="joke[golf]", value="course" />
             <input name="joke[swimming]", value="pool" />
             <input name="japes", value="grapes" />
           </form>
           """
    expect( $(html).formParams('joke') ).toEqual({
      golf: 'course'
      swimming: 'pool'
    })
