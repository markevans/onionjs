var fs = require('fs'),
    ModuleConfig = require('./module_config'),
    ModelConfig = require('./model_config'),
    Mustache = require('mustache'),
    mkdirp = require('mkdirp'),
    path = require('path'),
    ncp = require('ncp').ncp

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
    config = new ModuleConfig(name)
    generate(__dirname+"/../templates/controller.js.mustache", config.controllerPath(), config)
    generate(__dirname+"/../templates/view.js.mustache", config.viewPath(), config)
    generate(__dirname+"/../templates/template.mustache.mustache", config.templatePath(), config)
    generate(__dirname+"/../templates/view.css.mustache", config.cssPath(), config)
  },

  createModel: function (name) {
    config = new ModelConfig(name)
    generate(__dirname+"/../templates/model.js.mustache", config.modelPath(), config)
  },

  install: function (dir) {
    directory = (dir || ".") + "/onion"
    console.log("Copying onion files to directory " + directory)
    ncp(__dirname+"/../../src/onion", directory, function (err) {
     if (err) { return console.error(err) }
    })
  }
}
