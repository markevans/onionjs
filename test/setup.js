var requirejs = require('requirejs')

requirejs.config({
  baseUrl: 'vendor/assets/javascripts',
  nodeRequire: require
})

global.requirejs = requirejs
