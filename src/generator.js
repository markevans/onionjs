var fs = require('fs'),
    Mustache = require('mustache'),
    config = require('./config')
    S = require('string'),
    mkdirp = require('mkdirp'),
    path = require('path')

S.extendPrototype()

function generate (templatePath, destPath, object) {
  console.log("Writing to "+destPath)
  var template = fs.readFileSync(templatePath).toString()
  var body = Mustache.render(template, object)
  mkdirp.sync(path.dirname(destPath))
  fs.writeFileSync(destPath, body)
}

module.exports = {
  init: function () {
    generate(__dirname+"/../templates/onion.json", "onion.json")
  },

  createModule: function (name) {
    module = new Module(name)
    generate(__dirname+"/../templates/controller.js.mustache", module.controllerPath(), module)
    generate(__dirname+"/../templates/view.js.mustache", module.viewPath(), module)
    generate(__dirname+"/../templates/template.mustache.mustache", module.templatePath(), module)
    generate(__dirname+"/../templates/view.css.mustache", module.cssPath(), module)
  },

  createModel: function (name) {
  }
}

/////// Module ///////
function Module (name) {
  this.name = name
}
Module.prototype = {
  controllerPath: function () {
    return "js/controllers/" + this.controllerBasename() + ".js"
  },

  viewPath: function () {
    return "js/views/" + this.viewBasename() + ".js"
  },

  templatePath: function () {
    return "templates/" + this.basename() + ".mustache"
  },

  cssPath: function () {
    return "css/" + this.basename() + ".css"
  },

  underscored: function () {
    return this.name.camelize().replace(/Controller$/, '').underscore()
  },

  namespace: function () {
    return this.underscored().split('/').slice(0, -2).join('/')
  },

  basename: function () {
    var parts = this.underscored().split('/')
    return parts[parts.length-1]
  },

  moduleDirname: function () {
    return this.namespace() || this.basename()
  },

  controllerBasename: function () {
    return this.basename() + "_controller"
  },

  controllerName: function () {
    return this.controllerBasename().capitalize().camelize()
  },

  viewBasename: function () {
    return this.basename() + "_view"
  },

  viewName: function () {
    return this.viewBasename().capitalize().camelize()
  },

  viewCssClass: function () {
    return this.viewBasename().dasherize()
  }
}
