fs = require "fs"

describe "M1: Single page chat client", ->
  before ->
    casper.start("file://#{fs.workingDirectory}/src/main/resources/chat.html")
  it "page title is set", ->
    casper.then ->
      "head > title".should.have.text("Single page chat client")
  it "has an input field for messages", ->
    casper.then ->
      fieldSelector = "form#chat > input#message"
      fieldSelector.should.be.inDOM
      fieldSelector.should.have.attribute("type").that.deep.equals(["text"])
  it "has a button to send messages", ->
    casper.then ->
      buttonSelector = "form#chat > input#send"
      buttonSelector.should.be.inDOM
      buttonSelector.should.have.attribute("type").that.deep.equals(["button"])
      buttonSelector.should.have.attribute("value").that.deep.equals(["Send"])
