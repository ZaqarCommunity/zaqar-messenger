assert = require('chai').assert
{ SinglePageChat } = require("../../main/coffeescript/SinglePageChat")
{ ButtonSpy } = require("./ButtonSpy")
{ FieldSpy } = require("./FieldSpy")

suite "SinglePageChatTest", ->
  sendButton = new ButtonSpy
  messageField = new FieldSpy
  spg = new SinglePageChat(sendButton, messageField)
  test "constructor registers sendMessageFromField() for click event", ->
    assert.isFunction(sendButton.getEventListener())
    assert.strictEqual(sendButton.getEventListener(), spg.sendMessageFromField)
    assert.strictEqual(sendButton.getEventType(), "click")
  test "sendMessageFromField() should clear message field's value", ->
    messageField.value = "text message"
    spg.sendMessageFromField()
    assert.strictEqual(messageField.value, "")
