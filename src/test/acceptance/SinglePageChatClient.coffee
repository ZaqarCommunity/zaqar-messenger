###
Copyright 2014 Etienne Dysli Metref

This file is part of Zaquar Messenger.

Zaquar Messenger is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

Zaquar Messenger is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with Zaquar Messenger.  If not, see <http://www.gnu.org/licenses/>.
###

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

  describe "WebRTC connect to self", ->
    it "has a connect button", ->
      casper.then ->
        buttonSelector = "form#chat > input#connect"
        buttonSelector.should.be.inDOM
        buttonSelector.should.have.attribute("type").that.deep.equals(["button"])
        buttonSelector.should.have.attribute("value").that.deep.equals(["Connect"])

    xit "clicking connect button should establish connection", ->
      casper.then ->
        @click("input#connect")
        expect("function () { return spg.isConnected() }").to.evaluate.to.true
