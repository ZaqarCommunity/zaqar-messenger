fs = require "fs"

describe "M1: Single page chat client", ->
  before ->
    casper.start("file://#{fs.workingDirectory}/src/main/resources/chat.html")
  it "has an input field for messages", ->
    casper.then ->
      "input#message[type=\"text\"]".should.be.inDOM
