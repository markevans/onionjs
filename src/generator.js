var fs = require('fs'),
    Mustache = require('mustache'),
    config = require('./config')

function generate (templatePath, destPath, object) {
  console.log("Writing to "+destPath)
  var template = fs.readFileSync(templatePath).toString()
  var body = Mustache.render(template, object)
  fs.writeFileSync(destPath, body)
}

module.exports = {
  init: function () {
    generate(__dirname+"/../templates/onion.json", "onion.json")
  },

  createModule: function (name) {
  },

  createModel: function (name) {
  }
}
