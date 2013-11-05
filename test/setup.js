var requirejs = require('requirejs')

requirejs.config({
  baseUrl: 'src',
  nodeRequire: require
})

chai = requirejs('chai')
sinon = requirejs('sinon')

global.requirejs = requirejs
global.assert = chai.assert
global.expect = chai.expect
global.sinon = sinon
