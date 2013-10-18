var fs = require('fs')

module.exports = {

  readFile: function (path) {
    if ( fs.existsSync(path) ) {
      return JSON.parse(fs.readFileSync(path).toString())
    } else {
      return {}
    }
  },

  defaultConfig: function () {
    return this.__defaultConfig__ = this.__defaultConfig__ || this.readFile(__dirname+'/../templates/onion.json')
  },

  config: function () {
    return this.__config__ = this.__config__ || this.readFile('onion.json')
  },

  get: function () {
    var args = Array.prototype.slice.call(arguments)
    return this.fetch(this.config(), args) || this.fetch(this.defaultConfig(), args)
  },

  fetch: function (object, keys) {
    var value = object, i
    for(i = 0; i < keys.length; i++) {
      value = value[keys[i]]
      if (value == undefined) {
        return undefined
      }
    }
    return value
  }

}
