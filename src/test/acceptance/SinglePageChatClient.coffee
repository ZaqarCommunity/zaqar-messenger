fs = require "fs"

describe "M1: Single page chat client", ->

  before ->
    casper.start("file://#{fs.workingDirectory}/src/main/resources/chat.html")

  describe "Base HTML structure", ->
    it "page title is set", ->
      casper.then ->
        "head > title".should.have.text("Single page chat client")

    it "has an input field for messages", ->
      casper.then ->
        fieldSelector = "form#chat > input#message"
        fieldSelector.should.be.inDOM
        fieldSelector.should.have.attribute("type").that.deep.equals(["text"])
        fieldSelector.should.have.attribute("name").that.deep.equals(["message"])

    it "has a button to send messages", ->
      casper.then ->
        buttonSelector = "form#chat > input#send"
        buttonSelector.should.be.inDOM
        buttonSelector.should.have.attribute("type").that.deep.equals(["button"])
        buttonSelector.should.have.attribute("value").that.deep.equals(["Send"])

  describe "Send messages to log", ->
    it "clicking send button should clear message field", ->
      casper.then ->
        @fill("form#chat", {message: "abc"})
        @click("input#send")
        @getFormValues("form#chat").message.should.be.empty
        expect("message").to.have.fieldValue("")

    it "has a text area for logging messages", ->
      casper.then ->
        textAreaSelector = "form#chat > textarea"
        textAreaSelector.should.be.inDOM
        textAreaSelector.should.have.attribute("name").that.deep.equals(["messagesLog"])

    it "appends message to the log when send button is clicked", ->
      casper.then ->
        @fill("form#chat", {message: "def", messagesLog: "abc"})
        expect("messagesLog").to.have.fieldValue("abc")
        expect("message").to.have.fieldValue("def")
        @click("input#send")
        expect("messagesLog").to.have.fieldValue("""
                                                 abc
                                                 def
                                                 """)

    it "appends nothing when message is empty", ->
      casper.then ->
        logContentBefore = @getFormValues("form#chat").messagesLog
        expect("message").to.have.fieldValue("")
        @click("input#send")
        expect("messagesLog").to.have.fieldValue(logContentBefore)
