define([
  'onion/model',
  'onion/class_declarations',
  'onion/extend'
  ], function (Model, classDeclarations, extend) {

  return Model.sub("States")

    .use(classDeclarations, 'state')

    .after('init', function () {
      this.__states__ = {}
      this.__applyClassDeclarations__('state')
    })

    .proto({

      state: function (name, callback) {
        this.__states__[name] = callback
      },

      goTo: function (name, params) {
        this.update(name, params)
        this.emit('state', name, params)
      },

      update: function (name, params) {
        var callback = this.__states__[name]
        if (!callback) { throw new Error("no such state " + name) }
        callback.call(this, extend({}, params))
      }

    })

})

