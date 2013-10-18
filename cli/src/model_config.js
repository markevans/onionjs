var S = require('string'),
    config = require('./config')

S.extendPrototype()

function ModelConfig (name) {
  this.__name__ = name.underscore()
}

ModelConfig.prototype = {
  name: function () {
    return this.__name__
  },

  basename: function () {
    var parts = this.name().split('/')
    return parts[parts.length-1]
  },

  baseUrl: function () {
    return config.get(['baseUrl'])
  },

  modelPath: function () {
    return config.getAndParse(['model'], this)
  },

  modelTypeName: function () {
    return this.basename().capitalize().camelize()
  }
}

module.exports = ModelConfig
