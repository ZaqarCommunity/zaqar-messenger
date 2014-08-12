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

suite "PeerConnectionWrapperTest", ->
  localConnectionSpy = remoteConnectionSpy = pcw = null
  setup ->
    localConnectionSpy = new RTCPeerConnectionSpy()
    remoteConnectionSpy = new RTCPeerConnectionSpy()
    pcw = new PeerConnectionWrapper(localConnectionSpy, remoteConnectionSpy)

  test "should wrap both local and remote RTCPeerConnection instances", ->
    assert.propertyVal(pcw, "localPeerConnection", localConnectionSpy)
    assert.propertyVal(pcw, "remotePeerConnection", remoteConnectionSpy)
  test "should set its own function as onicecandidate event handler", ->
    assert.isFunction(localConnectionSpy.onicecandidate)
    assert.isFunction(pcw.signalIceCandidate)
    assert.deepEqual(pcw.signalIceCandidate, localConnectionSpy.onicecandidate)

  suite "signalIceCandidate", ->
    test "should call addIceCandidate on remote connection only when event has candidate attribute", ->
      pcw.signalIceCandidate({blah: "blah"})
      assert.strictEqual(remoteConnectionSpy.addIceCandidateCalls, 0)
      pcw.signalIceCandidate({candidate: "candidate"})
      assert.strictEqual(remoteConnectionSpy.addIceCandidateCalls, 1)
    test "should call addIceCandidate with candidate", ->
      event = {candidate: "candidate"}
      pcw.signalIceCandidate(event)
      assert.strictEqual(remoteConnectionSpy.addIceCandidateArgument, event.candidate)

  suite "sendOffer", ->
    sdp = null
    setup ->
      sdp = {sdp: "session description"}

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
