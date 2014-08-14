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
RTCPeerConnectionSpy = require("./RTCPeerConnectionSpy")
DataChannelSpy = require("./DataChannelSpy")

suite "PeerConnectionWrapperTest", ->
  localConnectionSpy = remoteConnectionSpy = pcw = null
  sdp = {sdp: "session description"}
  setup ->
    localConnectionSpy = new RTCPeerConnectionSpy()
    remoteConnectionSpy = new RTCPeerConnectionSpy()
    pcw = new PeerConnectionWrapper(localConnectionSpy, remoteConnectionSpy)

  test "should wrap both local and remote RTCPeerConnection instances", ->
    assert.propertyVal(pcw, "localPeerConnection", localConnectionSpy)
    assert.propertyVal(pcw, "remotePeerConnection", remoteConnectionSpy)
  test "should set its own function as onicecandidate event handler on local connection", ->
    assert.isFunction(localConnectionSpy.onicecandidate)
    assert.isFunction(pcw.signalIceCandidate)
    assert.deepEqual(pcw.signalIceCandidate, localConnectionSpy.onicecandidate)
  test "should set its own function as ondatachannel event handler on local connection", ->
    assert.isFunction(localConnectionSpy.ondatachannel)
    assert.isFunction(pcw.setupDataChannel)
    assert.deepEqual(pcw.setupDataChannel, localConnectionSpy.ondatachannel)

  suite "success/error callbacks", ->
    test "should have a success callback function", ->
      assert.isFunction(pcw.successCallback)
    test "success callback should log its arguments", ->
      pcw.successCallback({success: true})
      #TODO Mock console.log() and assert this
    test "should have a failure callback function", ->
      assert.isFunction(pcw.failureCallback)
    test "failure callback should log its arguments", ->
      pcw.failureCallback({success: false})
      #TODO Mock console.error() and assert this
    test "failure callback should return its arguments", ->
      assert.strictEqual(pcw.failureCallback("error"), "error")

  suite "signalIceCandidate", ->
    candidateEvent = {candidate: "candidate"}
    nonCandidateEvent = {blah: "blah"}

    test "should call addIceCandidate on remote connection only when event has candidate attribute", ->
      pcw.signalIceCandidate(nonCandidateEvent)
      assert.strictEqual(remoteConnectionSpy.addIceCandidateCalls, 0)
      pcw.signalIceCandidate(candidateEvent)
      assert.strictEqual(remoteConnectionSpy.addIceCandidateCalls, 1)
    test "should call addIceCandidate with candidate in event", ->
      pcw.signalIceCandidate(candidateEvent)
      assert.deepEqual(remoteConnectionSpy.addIceCandidateArgument, [candidateEvent.candidate, pcw.successCallback, pcw.failureCallback])

  suite "setupDataChannel", ->
    channelEvent = {channel: {onmessage: "empty"}}

    test "should set data channel to the one received", ->
      pcw.setupDataChannel(channelEvent)
      assert.deepEqual(pcw.dataChannel, channelEvent.channel)
    test "should set its own function as onmessage event handler on data channel", ->
      pcw.setupDataChannel(channelEvent)
      assert.isFunction(pcw.dataChannel.onmessage)
      assert.deepEqual(pcw.dataChannel.onmessage, pcw.receiveMessage)

  suite "sendOffer", ->
    test "should call setLocalDescription on local connection", ->
      pcw.sendOffer(sdp)
      assert.strictEqual(localConnectionSpy.setLocalDescriptionCalls, 1)
      assert.deepEqual(localConnectionSpy.setLocalDescriptionArgument, [sdp, pcw.successCallback, pcw.failureCallback])
    test "should call setRemoteDescription on remote connection", ->
      pcw.sendOffer(sdp)
      assert.strictEqual(remoteConnectionSpy.setRemoteDescriptionCalls, 1)
      assert.deepEqual(remoteConnectionSpy.setRemoteDescriptionArgument, [sdp, pcw.successCallback, pcw.failureCallback])
    test "should call createAnswer on remote connection with callbacks", ->
      pcw.sendOffer(sdp)
      assert.strictEqual(remoteConnectionSpy.createAnswerCalls, 1)
      assert.isFunction(arg) for arg in remoteConnectionSpy.createAnswerArgument
      assert.deepEqual(remoteConnectionSpy.createAnswerArgument, [pcw.sendAnswer, pcw.failureCallback])

  suite "sendAnswer", ->
    test "should call setLocalDescription on remote connection", ->
      pcw.sendAnswer(sdp)
      assert.strictEqual(remoteConnectionSpy.setLocalDescriptionCalls, 1)
      assert.deepEqual(remoteConnectionSpy.setLocalDescriptionArgument, [sdp, pcw.successCallback, pcw.failureCallback])
    test "should call setRemoteDescription on local connection", ->
      pcw.sendAnswer(sdp)
      assert.strictEqual(localConnectionSpy.setRemoteDescriptionCalls, 1)
      assert.deepEqual(localConnectionSpy.setRemoteDescriptionArgument, [sdp, pcw.successCallback, pcw.failureCallback])

  suite "send/receive messages", ->
    test "receiveMessage should print message data", ->
      messageEvent = {data: "test message"}
      pcw.receiveMessage(messageEvent)
      #TODO Mock console.log() and assert this
    test "sendMessage should call send on data channel", ->
      dataChannelSpy = new DataChannelSpy()
      channelEvent = {channel: dataChannelSpy}
      pcw.setupDataChannel(channelEvent)
      pcw.sendMessage("test message")
      assert.strictEqual(dataChannelSpy.sendCalls, 1)
      assert.strictEqual(dataChannelSpy.sendArgument, "test message")

  suite "connectPeers", ->
    test "should call createDataChannel on local connection with channel name", ->
      pcw.connectPeers()
      assert.strictEqual(localConnectionSpy.createDataChannelCalls, 1)
      assert.strictEqual(localConnectionSpy.createDataChannelArgument, "chat")
    test "should call createOffer on local connection with callbacks", ->
      pcw.connectPeers()
      assert.strictEqual(localConnectionSpy.createOfferCalls, 1)
      assert.isFunction(arg) for arg in localConnectionSpy.createOfferArgument
      assert.deepEqual(localConnectionSpy.createOfferArgument, [pcw.sendOffer, pcw.failureCallback])
