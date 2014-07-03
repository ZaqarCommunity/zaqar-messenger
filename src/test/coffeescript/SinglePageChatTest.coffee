assert = require('chai').assert
{ SinglePageChat } = require("../../main/coffeescript/SinglePageChat")
{ ButtonSpy } = require("./ButtonSpy")

suite "SinglePageChatTest", ->
  test "class exists", ->
    new SinglePageChat
  test "registers sendMessage() for click event", ->
    spg = new SinglePageChat
    bs = new ButtonSpy
    spg.registerSendMessageEventHandler(bs)
    assert.isFunction(bs.getEventListener())
    assert.equal(bs.getEventType(), "click")
