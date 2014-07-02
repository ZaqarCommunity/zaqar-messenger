fs = require "fs"

describe "Running CasperJS + Mocha + Chai", ->
  before ->
    casper.start("file://#{fs.workingDirectory}/src/test/resources/nothing.html")
  it "can check DOM", ->
    casper.then ->
      "html > body > h1".should.be.inDOM
