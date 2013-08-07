---
layout: default
title: Event flow
---

# Event flow

The application we built in the previous chapter was not really very useful. It also failed to illustrate a basic principle of OnionJS's architecture: **events**. But first, we need to add a new element to the mix: **models**.

## Models

Models hold the state of the application. Any concept that has a state, it has a model for it. Models can represent:

* Business objects: users, relationships, messages, transactions...
* Interface elements: selectors, tabs, buttons, sliders...

Models are accessed and modified by controllers. When this happens, models emit events as a response. Other controllers listen to these events and act in consequence, telling the views to present the updated information.

OnionJS provides a class you can use to implement models: Struct. You'll see how to use in the examples below.

## A more "real" application

We are going to build a new OnionJS app. This time there will be more files than before, but each will still be small. In OnionJS, we tend to have many simple files that do only one thing and are easy to debug, rather than a few large and complicated files that too many things.

This is the simple application we will be building here:

##[Link or embed the app here]

Let's have a look at the code, reviewing one element at a time.

## Top level

    <!-- index.html -->
    <div id="second-app"></div>
    <script>
    require(['second/second_controller'], function(SecondController) {
      new SecondController().appendTo('#second-app')
    })
    </script>

No surprises here. We start this application the same way we started the previous one. Using RequireJS we load the main controller and append it to a element of the page.

## Comment model

First, there's a business object. Comments are elements of the application that surely will be posted somewhere after being written.

    define([
      'onion/struct'
    ], function(
      Struct
    ) {

      return Struct.sub('Comment')
        .attributes('body')
    })

Using the provided `Struct` class, we create a `Comment` model that will hold the details of the comment. In this case it's only the text body, but it could be more complex than that.

The declaration `.attributes('body')` creates an attribute in the struct, and adds the methods `.body()` and `.setBody()`, that act as getter and setter for this attribute. An example follows with two attributes instead:

    Comment = Struct.sub('Comment').attributes('body', 'title')
    comment = new Comment()
    comment.setTitle("The title")
    comment.setBody("This is the body")
    comment.title() // => "The title"
    comment.body() // => "This is the body"

Additionally, the struct will emit events when it changes:

    comment.on('change', function () {
        // This will fire on any change
    })

    comment.on('change:body', function () {
        // This will fire when the 'body' attribute changes
    })

## Selector model

Next we have another model, but this time it does not reflect a business object, but a UI element: the tabs that allow us to select the editor or the display.

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

This time we are adding a method to the struct: 'select'. This is really little more than an alias for 'setSelection'. We add it just because this is a selector, so surely we should be able to select! :-)

As with the Comment model, the events 'change' and 'change:selection' will be fired when the attribute 'selection' changes. This includes when changed using the 'select' method.

## Main controller ("Second" controller)

Now that we have the models, we can start building the application itself. It's made of several models, and the first one is the following:

    define([
      'onion/controller',
      'models/comment',
      'models/selector',
      'second/second_view',
      'second/tabs_controller',
      'second/editor_controller',
      'second/display_controller'
    ], function (
      Controller,
      Comment,
      Selector,
      SecondView,
      TabsController,
      EditorController,
      DisplayController
    ) {

      return Controller.sub('SecondController')

        .view(SecondView)

        .after('init', function () {
          this.newModel('comment', new Comment)
          this.newModel('tabs', new Selector)
          this.tabs.select('editor')
          this.view.render()
          this.setChild('tabs', TabsController)
          this.setChild('editor', EditorController)
          this.setChild('display', DisplayController)
        })

    })


Now this is a bit longer that we have seen so far, but it's all just setting up stuff. Let's look at the new elements:

    this.newModel('comment', new Comment)
    this.newModel('tabs', new Selector)

As mentioned before, we will be listening to the events fired by the models. OnionJS controllers provide several shortcuts for these. To take advantage of them, you must register the models first, which is what we do above.

Note that this specific controller doesn't do any listening, but its children controllers will. I haven't introduced the concept of children controllers yet, but we are almost there! For now, let's just say that this is the appropriate place to register these models because they will be shared by some other controllers down the line.

    this.tabs.select('editor')

When we register models, these become available as properties of the controller, and we can access them through the `this` keyword. In this case, we use this to set an initial value for the tabs.

    this.setChild('tabs', TabsController)
    this.setChild('editor', EditorController)
    this.setChild('display', DisplayController)

I mentioned the concept of "children controllers" above. Well, these are those. In OnionJS, controllers are organised hierarchically. Most controllers will have one or more children controllers that implement smaller pieces of the UI they represent.

In this example application, the hierarchy is the following:

![Controller hierarchy](controller_hierarchy.png)

For simplicity, in this example there are only two levels in the tree, but there could be as many as deemed necessary. Let's now have a look at these other controllers and see how they participate in the architecture of the app.

## Tabs controller

Actually, it might be better if we explain this in a bottom-up fashion. Therefore, let's start with the template. It is the following:

    <div class="tabs-view">
      <p class="tab editor">Editor</p>
      <p class="tab display">Display</p>
    </div>

This is pretty simple HTML. There's not even any variable here, so it will be rendered exactly as-is. The main thing to pay attention to is that there are two elements, that represent the tabs, and each has a class name that identifies its purpose ('editor' and 'display').

Now that we know what the HTML is going to look like, let's have a look at the view:

    // second/tabs_view.js
    define([
      'onion/mustache_view',
      'onion/vendor/text!second/tabs.mustache'
    ], function (
      MustacheView,
      template
    ) {

      return MustacheView.sub('TabsView')

        .template(template)

        .onDom('.editor', 'click', 'editor')
        .onDom('.display', 'click', 'display')

        .proto({
          selectTab: function (tab) {
            this.find('.tab').removeClass('current')
            this.find('.' + tab).addClass('current')
          }
        })

    })

We have two new things that we haven't seen in before. I'll comment them separately.

    .onDom('.editor', 'click', 'editor')
    .onDom('.display', 'click', 'display')

If you think these look like listeners for DOM events, then you are completely right. The view is going to attach two of these listeners, one to the '.editor' tab and another one to the '.display' tab, both for the 'click' event. You may be wondering what 'editor' and 'display' strings mean at the end of each line. That's where you'd normally find callbacks for the events, but there's none of that here! The reason is simple: in OnionJS, views are **extremely** dumb.

By extremely dumb, here I mean that they don't even act on their own events. Instead, they delegate them to the controller. The lines above mean:

  * When the user clicks on '.editor', emit the 'editor' event
  * When the user clicks on '.display', emit the 'display' event

Hopefully the controller will be listening to those!

Now, the other new element:

    .proto({
      selectTab: function (tab) {
        this.find('.tab').removeClass('current')
        this.find('.' + tab).addClass('current')
      }
    })

This is very similar to what we saw earlier in the Selector model: we are adding a method to the view. This method deals with details of how the widget is presented: class names and DOM nodes. It's knowledge that only the view should be privy to. By putting it here, we keep the presentation concern contained in the view while giving the controller something it can use to communicate changes to the user.

Right, so the above are two elements we have added to this view's public interface. The controller should be able to use them for its own purposes. Once we know this, we can have a look at the controller:

    // second/tabs_controller.js
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

Again, there are a few new elements here, but by now you should be able to understand most of them. Let's see.

    .models('tabs')

Initially, we defined the 'tabs' model on SecondController. I said that this was so that child controllers could access it too, but this doesn't happen automatically. Instead, with this line we tell TabsController that we do want to make use of 'tabs' here. Because 'tabs' has been defined upstream, no more information is needed.

    .onView('editor', function () {
      this.tabs.select('editor')
    })

    .onView('display', function () {
      this.tabs.select('display')
    })

Remember the 'editor' and 'display' events that TabsView was emitting? This is where the controller listens to them. On each of them, we notify the model so that it changes its state.

**Important point to note here**: notice how the controller is just changing the state of the model, but not taking any further action. For example, it's not asking the view to highlight the currently selected tab. This will only happen in response to events from the models. It's actually on the following line that this happens:

    .onModel('tabs', 'change:selection', 'selectCurrentTab')

There. On this line, we listen to the 'tabs' model. If the selection changes, the method `selectCurrentTab` is called. This will in turn tell the view to do its magic so that the current tab looks selected, and the other one doesn't.

A detail to note: on the `onView` declarations, we set callbacks using anonymous functions on the spot. On the `onModel` declaration, we are giving the name of a method declared elsewhere in the controller (`selectCurrentTab`). Either approach is valid in either case. In the `onModel` example, there's already a method on the controller doing what we want, so we are better off delegating to it than writing new code.

As for this `selectCurrentTab` method:

    .proto({
      selectCurrentTab: function () {
        this.view.selectTab(this.tabs.selection())
      }
    })

Similar to others seen before. Notice how we read the state of the model (`this.tabs.selection()`) and pass the appropriate details down to the view so it does its job.

And that's it for the tabs!

## The rest

EditorController, DisplayController, their views and their templates are very similar to what's been explained above, so I won't go in detail about them here. Instead, have a look at the code yourself to see by yourself.

However, there are a couple of new things there, so I'll just explain those. For example, in EditorView:

    .onDom('textarea', 'keyup', 'textChanged', function () {
      return this.find('textarea').val()
    })

The editor is mostly a textarea element where users can write. On `keyup`, we let the controller know that the text has changed. Notice how there's a strange callback there. It may initially look like it's a handler for the event, but it's not.

Instead, the given function is used to provide arguments for the `textChanged` event. When this event is fired, this function is run and it read the contents of the textarea. These contents will be passed along with the event for the controller to use them.

Accordingly, this is the code that handles this event at EditorController:

    .onView('textChanged', 'textChanged')

    .proto({
      textChanged: function (text) {
        this.comment.setBody(text)
      }
    })

Here, we can see how the text in the textarea is received with the event, and used to set the 'body' attribute of the 'comment' model.

All the rest, you can now figure out by yourself! :-)
