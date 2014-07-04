$ = (id) -> document?.getElementById(id)

class SinglePageChat
  constructor: (@sendButton = $("send"), @messageField = $("message"), @logArea = $("messagesLog")) ->
    @sendButton.addEventListener("click", @sendMessageFromField)

  sendMessageFromField: ->
    @logArea.value += "\n#{@messageField.value}" unless @messageField.value.length is 0
    @messageField.value = ""

(exports ? window).SinglePageChat = SinglePageChat
