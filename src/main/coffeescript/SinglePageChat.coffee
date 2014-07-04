$ = (id) -> document?.getElementById(id)

class SinglePageChat
  constructor: (@sendButton = $("send"), @messageField = $("message"), @logArea = $("messagesLog")) ->
    @sendButton.addEventListener("click", @sendMessageFromField)

  sendMessageFromField: ->
    @logArea.value += "\n#{@messageField.value}"
    @messageField.value = ""

(exports ? window).SinglePageChat = SinglePageChat
