define([
  'onion/model',
  'onion/class_declarations',
  'onion/utils/extend'
  ], function (Model, classDeclarations, extend) {

  return Model.sub("Bookmarks")

    .use(classDeclarations, 'bookmark')

    .after('init', function () {
      this.__bookmarks__ = {}
      this.__applyClassDeclarations__('bookmark')
    })

    .proto({

      bookmark: function (name, callback) {
        this.__bookmarks__[name] = callback
      },

      visit: function (name, params) {
        var result = this.run(name, params)
        this.emit('visit', name, params)
        return result
      },

      run: function (name, params) {
        var callback = this.__bookmarks__[name]
        if (!callback) { throw new Error("no such bookmark " + name) }
        return callback.call(this, extend({}, params))
      }

    })

})

