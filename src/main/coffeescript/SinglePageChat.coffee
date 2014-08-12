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

$ = (id) -> document?.getElementById(id)

PeerConnectionWrapper = require("./PeerConnectionWrapper")
RTCPeerConnection = window?.RTCPeerConnection or window?.webkitRTCPeerConnection or window?.mozRTCPeerConnection or require("../../test/coffeescript/RTCPeerConnectionSpy")

class SinglePageChat
  constructor: (@sendButton = $("send"), @connectButton = $("connect"), @messageField = $("message"), @logArea = $("messagesLog")) ->
    @sendButton.addEventListener("click", @sendMessageFromField)
    @connectButton.addEventListener("click", @connect)
    @connected = false
    lp = new RTCPeerConnection(null)
    rp = new RTCPeerConnection(null)
    @localPeer = new PeerConnectionWrapper(lp, rp)
    @remotePeer = new PeerConnectionWrapper(rp, lp)

  sendMessageFromField: =>
    @logArea.value += "\n#{@messageField.value}" unless @messageField.value.length is 0
    @messageField.value = ""

  connect: =>

  isConnected: =>
    @connected

module.exports = SinglePageChat
