---
layout: default
title: CoffeeScript
---

# CoffeeScript

For those who are so inclined, OnionJS can be easily used with CoffeeScript. It actually was created a by a CoffeeScript user, so you may see that some elements look like they were designed with CoffeeScript in mind. However, unless otherwise stated all examples in this documentation are in JavaScript, which should be understood by everybody (because you really should know your JavaScript before starting coffee-ing it!)

## Type system

In previous examples, we have seen how OnionJs provides a type system that gives us proper classes. For example:

    define([
      'onion/struct'
    ], function(
      Struct
    ) {

      return Struct.sub('Selector')
        .attributes('selection')

        .proto({
          select: function (val) {
            this.setSelection(val)
          }
        })

    })

Coffeescript also provides these facilities, so the question is: how well do the play together?

The answer: they are perfectly compatible. In fact, if you are using CoffeeScript, you can just use CoffeeScript classes without worrying about any of this. This is how the above code would look like in CoffeeScript:

    define [
      'onion/struct'
    ], (
      Struct
    ) ->

      class Selector extends Struct
        @attributes 'selection'

        select: (val) ->
          this.setSelection(val)

Two details here:

  * Struct provides `attributes` as a class method, so we can just call it inside the class definition.
  * We don't need the `proto` call to define methods, because CoffeeScript provides this natively.

## Another example

Let's look at a controller in JS now:

    define([
      'onion/controller',
      'second/tabs_view'
    ], function (
      Controller,
      TabsView
    ) {

      return Controller.sub('TabsController')

        .view(TabsView)
        .models('tabs')

        .onView('editor', function () {
          this.tabs.select('editor')
        })

        .onView('display', function () {
          this.tabs.select('display')
        })

        .onModel('tabs', 'change:selection', 'selectCurrentTab')

        .after('init', function () {
          this.view.render()
          this.selectCurrentTab()
        })

        .proto({
          selectCurrentTab: function () {
            this.view.selectTab(this.tabs.selection())
          }
        })

    })

Now, this is the coffee'd up equivalent:

    define [
      'onion/controller'
      'second/tabs_view'
    ], (
      Controller
      TabsView
    ) ->

      class TabsController extends Controller

        @view TabsView
        @models 'tabs'

        @onView 'editor', -> @tabs.select('editor')
        @onView 'display', -> @tabs.select('display')
        @onModel 'tabs', 'change:selection', 'selectCurrentTab'

        @after 'init', ->
          @view.render()
          @selectCurrentTab()

        selectCurrentTab: ->
          @view.selectTab(@tabs.selection())

Again, `@view()`, `@models()`, `@onView()` and `@onModel()` can just be called in the body of the class, and they will work as expected.

There isn't really much more to say. Using CoffeeScript with OnionJS is straightforward, even natural, so you can start doing it now if you prefer it.
