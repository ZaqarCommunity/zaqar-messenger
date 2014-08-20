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

assert = require('chai').assert
PeerConnectionWrapper = require("../../main/coffeescript/PeerConnectionWrapper")
SinglePageChat = require("../../main/coffeescript/SinglePageChat")
ButtonSpy = require("./ButtonSpy")
FieldSpy = require("./FieldSpy")
RTCPeerConnectionSpy = require("./RTCPeerConnectionSpy")
DataChannelSpy = require("./DataChannelSpy")

suite "SinglePageChatTest", ->
  sendButton = connectButton = messageField = logArea = spg = null

  setup ->
    sendButton = new ButtonSpy()
    connectButton = new ButtonSpy()
    messageField = new FieldSpy()
    logArea = new FieldSpy()
    spg = new SinglePageChat(sendButton, connectButton, messageField, logArea)

  suite "before connection", ->

    test "constructor registers sendMessageFromField() for click event", ->
      assert.isFunction(sendButton.getEventListener())
      assert.strictEqual(sendButton.getEventListener(), spg.sendMessageFromField)
      assert.strictEqual(sendButton.getEventType(), "click")

    test "constructor registers connect() for click event", ->
      assert.isFunction(connectButton.getEventListener())
      assert.strictEqual(connectButton.getEventListener(), spg.connect)
      assert.strictEqual(connectButton.getEventType(), "click")

    test "constructor should create two connection wrappers around two RTCPeerConnections", ->
      assert.instanceOf(spg.localPeer, PeerConnectionWrapper)
      assert.instanceOf(spg.remotePeer, PeerConnectionWrapper)
      assert.instanceOf(spg.localPeer.localPeerConnection, RTCPeerConnectionSpy)
      assert.instanceOf(spg.localPeer.remotePeerConnection, RTCPeerConnectionSpy)
      assert.instanceOf(spg.remotePeer.localPeerConnection, RTCPeerConnectionSpy)
      assert.instanceOf(spg.remotePeer.remotePeerConnection, RTCPeerConnectionSpy)

    test "constructor should set remote RTCPeerConnection.handleMessageData", ->
      assert.isFunction(spg.remotePeer.handleMessageData)
      assert.strictEqual(spg.remotePeer.handleMessageData, spg.receiveMessageInLogArea)

    test "begins in not connected state", ->
      assert.isFalse(spg.isConnected())

  suite "when connected", ->
    dataChannel = null
    setup ->
      dataChannel = new DataChannelSpy()
      spg.localPeer.localPeerConnection.setDataChannel(dataChannel)
      spg.connect()
      spg.remotePeer.setupDataChannel({channel: dataChannel})

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

    test "sendMessageFromField() should append nothing when message is empty", ->
      logArea.value = "message 1"
      messageField.value = ""
      spg.sendMessageFromField()
      assert.strictEqual(logArea.value, """
                                        message 1
                                        """)

    test "sendMessageFromField() should call PeerConnectionWrapper.sendMessage()", ->
      messageField.value = "text message"
      spg.sendMessageFromField()
      assert.strictEqual(dataChannel.sendCalls, 1)
      assert.strictEqual(dataChannel.sendArgument, "text message")

    test "sendMessageFromField() should not call PeerConnectionWrapper.sendMessage() when message is empty", ->
      messageField.value = ""
      spg.sendMessageFromField()
      assert.strictEqual(dataChannel.sendCalls, 0)

    test "receiveMessageInLogArea() should append message to log", ->
      logArea.value = "message 1"
      spg.receiveMessageInLogArea("message 2")
      assert.strictEqual(logArea.value, """
                                        message 1
                                        message 2
                                        """)

    test "reports connected after PeerConnectionWrapper is done", ->
      spg.localPeer.localPeerConnection.iceConnectionState = "connected"
      spg.localPeer.remotePeerConnection.iceConnectionState = "connected"
      assert.isTrue(spg.isConnected())
