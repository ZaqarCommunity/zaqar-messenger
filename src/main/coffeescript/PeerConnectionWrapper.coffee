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

class PeerConnectionWrapper
  constructor: (@localPeerConnection, @remotePeerConnection) ->
    @localPeerConnection.onicecandidate = @signalIceCandidate
    @localPeerConnection.ondatachannel = @setupDataChannel

  signalIceCandidate: (event) =>
    if (event.candidate)
      @remotePeerConnection.addIceCandidate(event.candidate)

  setupDataChannel: (event) =>
    @dataChannel = event.channel
    @dataChannel.onmessage = @receiveMessage

  receiveMessage: (event) =>
    console.log("received message: #{event.data}")

  sendMessage: (text) =>
    @dataChannel.send(text)

  sendOffer: (sessionDescription) =>
    @localPeerConnection.setLocalDescription(sessionDescription)
    @remotePeerConnection.setRemoteDescription(sessionDescription)
    @remotePeerConnection.createAnswer(@sendAnswer)

  sendAnswer: (sessionDescription) =>
    @remotePeerConnection.setLocalDescription(sessionDescription)
    @localPeerConnection.setRemoteDescription(sessionDescription)

  connectPeers: =>
    @localPeerConnection.createDataChannel("chat")
    @localPeerConnection.createOffer(@sendOffer)

module.exports = PeerConnectionWrapper
