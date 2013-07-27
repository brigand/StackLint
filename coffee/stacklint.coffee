### StackLint (c) FakeRainBrigand 2013
  This file is for abstract and helper functions, and the lint evaluators.
###
root = window ? module.exports

###
  Lints
    These define problems in the question by examining the question structure.
    Each must provide a `test` function which returns true or false
    true means that there is no problem, and the question fails inspection

    If additional data should be made available to the bindings, you may instead return an object, which
    can be accessed via myLint.test().propertyOnReturnedObject

###
lints =
  containsCode:
    test: (question) -> question.code().length is 0

  vagueError:
    test: (question) ->
      text = question.text().join(' ').toLowerCase()
      mentionsError = text.indexOf('error') isnt -1 or text.indexOf('exception') isnt -1
      code = question.code().join(' ').toLowerCase()
      doesntShowError = code.indexOf('error') is -1 and code.indexOf('exception') is -1
      mentionsError and doesntShowError


  missingFiddle:
    test: (question) ->
      fiddleTags = ['javascript', 'jquery', 'html', 'css', 'css3', 'html5', 'mootools', 'knockout']
      tags = question.tags()
      tagString = tags.join ' '

      shouldHaveFiddle = _.any (tagString.indexOf(tag) isnt -1 for tag in fiddleTags)
      missingFiddle = not _.any (link.href.indexOf("jsfiddle.net") isnt -1 for link in question.links())

      console.log shouldHaveFiddle, missingFiddle, tagString
      shouldHaveFiddle and missingFiddle

  longLines:
    test: (question) ->
      lines = question.code().join('\n').split('\n')
      for line in lines
        return true if line.length > 80
      false

  lotsOfCode:
    test: (question) ->
      code = question.code().join('\n')
      chars = code.replace(/\s+/g, "").length # chars - whitespace
      lines = code.split('\n').length
      if chars > 1000 or lines > 30
        {chars, lines}
      else
        false


  lotsOfText:
    test: (question) ->
      text = question.text().join('\n')
      chars = text.replace(/\n+/g, "").length # chars - new lines
      if chars > 1000
        {chars}
      else
        false

  didntTry:
    test: (question) ->
      text = question.text().join(' ').toLowerCase()
      text.indexOf('i tried') is -1 and
        text.indexOf('when i') is -1 and
        text.indexOf('i am trying') is -1

  howCanIDoThis:
    test: (question) ->
      text = question.text().join(' ').toLowerCase()
      code = question.code().join('\n')
      codeChars = code.replace(/\s+/g, "").length

      text.indexOf('how can i do this') isnt -1 and codeChars < 100

  aspRaw:
    test: (question) ->
      tags = question.tags().join(' ')
      asp = tags.indexOf('asp') isnt -1
      css =  tags.indexOf('css') isnt -1
      js =  tags.indexOf('javascript') isnt -1
      source = question.code().join(' ').indexOf("<%=") isnt -1
      asp and source and (css or js)


### Exports ###
root.sl =
  makeLintObject: (question) ->
    output = []
    for name, lint of lints
      lint = _.clone lint
      lint.test = ko.computed lint.test.bind(output, question)
      output[name] = lint
    return output

