class ButtonSpy
  getEventListener: -> @eventListener
  getEventType: -> @eventType
  addEventListener: (type, listener) ->
    @eventType = type
    @eventListener = listener

(exports ? window).ButtonSpy = ButtonSpy
