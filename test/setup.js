var requirejs = require('requirejs')

requirejs.config({
  baseUrl: 'vendor/assets/javascripts',
  nodeRequire: require
})

chai = requirejs('chai')

global.requirejs = requirejs
global.expect = chai.expect
