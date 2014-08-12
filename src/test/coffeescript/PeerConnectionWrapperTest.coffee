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
  localConnectionSpy = remoteConnectionSpy = pc = null
  setup ->
    localConnectionSpy = new RTCPeerConnectionSpy()
    remoteConnectionSpy = new RTCPeerConnectionSpy()
    pc = new PeerConnectionWrapper(localConnectionSpy, remoteConnectionSpy)

  test "should wrap both local and remote RTCPeerConnection instances", ->
    assert.propertyVal(pc, "localPeerConnection", localConnectionSpy)
    assert.propertyVal(pc, "remotePeerConnection", remoteConnectionSpy)
  test "should set its own function as onicecandidate event handler", ->
    assert.isFunction(localConnectionSpy.onicecandidate)
    assert.isFunction(pc.signalIceCandidate)
    assert.deepEqual(pc.signalIceCandidate, localConnectionSpy.onicecandidate)

  suite "signalIceCandidate", ->
    test "signalIceCandidate should call addIceCandidate on remote connection only when event has candidate attribute", ->
      pc.signalIceCandidate({blah: "blah"})
      assert.strictEqual(remoteConnectionSpy.addIceCandidateCalls, 0)
      pc.signalIceCandidate({candidate: "candidate"})
      assert.strictEqual(remoteConnectionSpy.addIceCandidateCalls, 1)
    test "signalIceCandidate should call addIceCandidate with candidate", ->
      event = {candidate: "candidate"}
      pc.signalIceCandidate(event)
      assert.strictEqual(remoteConnectionSpy.addIceCandidateArgument, event.candidate)

  suite "sendOffer", ->
    test "sendOffer should call setLocalDescription on local connection", ->
      sdp = {sdp: "session description"}
      pc.sendOffer(sdp)
      assert.strictEqual(localConnectionSpy.setLocalDescriptionCalls, 1)
      assert.strictEqual(localConnectionSpy.setLocalDescriptionArgument, sdp)
    test "sendOffer should call setRemoteDescription on remote connection", ->
      sdp = {sdp: "session description"}
      pc.sendOffer(sdp)
      assert.strictEqual(remoteConnectionSpy.setRemoteDescriptionCalls, 1)
      assert.strictEqual(remoteConnectionSpy.setRemoteDescriptionArgument, sdp)
