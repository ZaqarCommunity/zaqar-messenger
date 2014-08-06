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
  localConnectionSpy = new RTCPeerConnectionSpy()
  remoteConnectionSpy = new RTCPeerConnectionSpy()
  pc = new PeerConnectionWrapper(localConnectionSpy, remoteConnectionSpy)
  test "should wrap both local and remote RTCPeerConnection instances", ->
    assert.propertyVal(pc, "localPeerConnection", localConnectionSpy)
    assert.propertyVal(pc, "remotePeerConnection", remoteConnectionSpy)
  test "sets its own function as onicecandidate event handler", ->
    assert.isFunction(localConnectionSpy.onicecandidate)
    assert.isFunction(pc.signalIceCandidate)
    assert.deepEqual(pc.signalIceCandidate, localConnectionSpy.onicecandidate)
