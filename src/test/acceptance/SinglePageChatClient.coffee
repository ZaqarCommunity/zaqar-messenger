fs = require "fs"

describe "M1: Single page chat client", ->
  before ->
    casper.start("file://#{fs.workingDirectory}/src/main/resources/chat.html")
  it "page title is set", ->
    casper.then ->
      "head > title".should.have.text("Single page chat client")
  it "has an input field for messages", ->
    casper.then ->
      "input#message[type=\"text\"]".should.be.inDOM
  it "has a button to send messages", ->
    casper.then ->
      buttonSelector = "input#send"
      buttonSelector.should.be.inDOM
      buttonSelector.should.have.attribute("type").that.deep.equals(["button"])
      buttonSelector.should.have.attribute("value").that.deep.equals(["Send"])
