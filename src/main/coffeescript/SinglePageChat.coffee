class SinglePageChat
  registerSendMessageEventHandler: (button) ->
    button.addEventListener("click", @sendMessage)
  sendMessage: ->

(exports ? window).SinglePageChat = SinglePageChat
