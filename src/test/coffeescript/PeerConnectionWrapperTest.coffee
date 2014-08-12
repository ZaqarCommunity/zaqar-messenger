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
{ PeerConnectionWrapper } = require("../../main/coffeescript/PeerConnectionWrapper")
{ RTCPeerConnectionSpy } = require("./RTCPeerConnectionSpy")
{ DataChannelSpy } = require("./DataChannelSpy")

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
      assert.strictEqual(remoteConnectionSpy.addIceCandidateArgument, candidateEvent.candidate)

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
      assert.strictEqual(localConnectionSpy.setLocalDescriptionArgument, sdp)
    test "should call setRemoteDescription on remote connection", ->
      pcw.sendOffer(sdp)
      assert.strictEqual(remoteConnectionSpy.setRemoteDescriptionCalls, 1)
      assert.strictEqual(remoteConnectionSpy.setRemoteDescriptionArgument, sdp)
    test "should call createAnswer on remote connection", ->
      pcw.sendOffer(sdp)
      assert.strictEqual(remoteConnectionSpy.createAnswerCalls, 1)
      assert.isFunction(remoteConnectionSpy.createAnswerArgument)
      assert.deepEqual(remoteConnectionSpy.createAnswerArgument, pcw.sendAnswer)

  suite "sendAnswer", ->
    test "should call setLocalDescription on remote connection", ->
      pcw.sendAnswer(sdp)
      assert.strictEqual(remoteConnectionSpy.setLocalDescriptionCalls, 1)
      assert.strictEqual(remoteConnectionSpy.setLocalDescriptionArgument, sdp)
    test "should call setRemoteDescription on local connection", ->
      pcw.sendAnswer(sdp)
      assert.strictEqual(localConnectionSpy.setRemoteDescriptionCalls, 1)
      assert.strictEqual(localConnectionSpy.setRemoteDescriptionArgument, sdp)

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
