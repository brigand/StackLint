

ko.observable.fn.contains = (values...) ->
  data = this()
  for value in values
    return true if data.indexOf value isnt -1
  false


# Knockout Copy Functions #
ko.bindingHandlers.zclip =
  init: (element, valueAccessor) ->
    try
      zclip = new ZeroClipboard element
    catch e
      console.error "ZeroClipboard was unable to load", e

    $(element).data 'zclip', zclip

  update: (element, valueAccessor) ->
    value = ko.unwrap(valueAccessor())
    zclip = $(element).data 'zclip'
    zclip.setText value if zclip?

