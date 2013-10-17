#!/usr/bin/env node

var program = require('commander')
    generator = require('../src/generator')

program
  .version('0.0.1')

program
  .command("init")
  .action(function () {
    generator.init()
  })

program
  .command("module [name]")
  .usage("module name")
  .action(function (name) {
    if(!name) program.help()
    generator.createModule(name)
  })

program
  .command("model [name]")
  .action(function (name) {
    if(!name) program.help()
    generator.createModel(name)
  })

if (process.argv.length == 2) program.help()
program.parse(process.argv)

