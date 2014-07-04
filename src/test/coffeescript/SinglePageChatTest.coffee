assert = require('chai').assert
{ SinglePageChat } = require("../../main/coffeescript/SinglePageChat")
{ ButtonSpy } = require("./ButtonSpy")
{ FieldSpy } = require("./FieldSpy")

suite "SinglePageChatTest", ->
  sendButton = new ButtonSpy
  messageField = new FieldSpy
  logArea = new FieldSpy
  spg = new SinglePageChat(sendButton, messageField, logArea)
  test "constructor registers sendMessageFromField() for click event", ->
    assert.isFunction(sendButton.getEventListener())
    assert.strictEqual(sendButton.getEventListener(), spg.sendMessageFromField)
    assert.strictEqual(sendButton.getEventType(), "click")
  test "sendMessageFromField() should clear message field's value", ->
    messageField.value = "text message"
    spg.sendMessageFromField()
    assert.strictEqual(messageField.value, "")
  test "sendMessageFromField() should append message to log", ->
    logArea.value = "message 1"
    messageField.value = "message 2"
    spg.sendMessageFromField()
    assert.strictEqual(logArea.value, """
                                      message 1
                                      message 2
                                      """)
