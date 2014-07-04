assert = require('chai').assert
{ SinglePageChat } = require("../../main/coffeescript/SinglePageChat")
{ ButtonSpy } = require("./ButtonSpy")
{ FieldSpy } = require("./FieldSpy")

suite "SinglePageChatTest", ->
  bs = new ButtonSpy
  fs = new FieldSpy
  spg = new SinglePageChat(bs, fs)
  test "constructor registers sendMessageFromField() for click event", ->
    assert.isFunction(bs.getEventListener())
    assert.strictEqual(bs.getEventListener(), spg.sendMessageFromField)
    assert.strictEqual(bs.getEventType(), "click")
  test "sendMessageFromField() should clear message field's value", ->
    fs.value = "text message"
    spg.sendMessageFromField()
    assert.strictEqual(fs.value, "")
