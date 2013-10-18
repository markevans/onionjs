var S = require('string'),
    config = require('./config')

S.extendPrototype()

function ModuleConfig (name) {
  this.__name__ = name.underscore()
}

ModuleConfig.prototype = {
  getConfig: function (key) {
    return config.getAndParse(['module', key], this)
  },

  baseUrl: function () {
    return config.get(['baseUrl'])
  },

  controllerPath: function () {
    return this.getConfig('controller')
  },

  viewPath: function () {
    return this.getConfig('view')
  },

  templatePath: function () {
    return this.getConfig('template')
  },

  cssPath: function () {
    return this.getConfig('css')
  },

  name: function () {
    return this.__name__
  },

  basename: function () {
    var parts = this.name().split('/')
    return parts[parts.length-1]
  },

  relativeToBaseUrl: function (path) {
    return path.replace(this.baseUrl(), '').replace(/^\//,'')
  },

  viewRequirePath: function () {
    return this.relativeToBaseUrl(this.viewPath()).replace(/\.js$/, '')
  },

  templateRequirePath: function () {
    return this.relativeToBaseUrl(this.templatePath())
  },

  controllerTypeName: function () {
    return this.basename().capitalize().camelize() + "Controller"
  },

  viewTypeName: function () {
    return this.basename().capitalize().camelize() + "View"
  },

  viewCssClass: function () {
    return this.basename().dasherize() + '-view'
  }
}

module.exports = ModuleConfig
