

ko.observable.fn.contains = (values...) ->
  data = this()
  for value in values
    return true if data.indexOf value isnt -1
  false

