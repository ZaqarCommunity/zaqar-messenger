$ = (id) -> document?.getElementById(id)

class SinglePageChat
  constructor: (@sendButton = $("send"), @messageField = $("message")) ->
    @sendButton.addEventListener("click", @sendMessageFromField)

  sendMessageFromField: ->

(exports ? window).SinglePageChat = SinglePageChat
