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
    dsc: "should have code"

  vagueError:
    test: (question) ->
      text = question.text().join(' ').toLowerCase()
      mentionsError = text.indexOf('error') isnt -1 or text.indexOf('exception') isnt -1
      code = question.code().join(' ').toLowerCase()
      doesntShowError = code.indexOf('error') is -1 and code.indexOf('exception') is -1
      mentionsError and doesntShowError
    dsc: "should show complete error messages"


  missingFiddle:
    test: (question) ->
      fiddleTags = ['javascript', 'jquery', 'html', 'css', 'css3', 'html5', 'mootools', 'knockout']
      tags = question.tags()
      tagString = tags.join ' '

      shouldHaveFiddle = _.any (tagString.indexOf(tag) isnt -1 for tag in fiddleTags)
      missingFiddle = not _.any (link.href.indexOf("jsfiddle.net") isnt -1 for link in question.links())

      shouldHaveFiddle and missingFiddle
    dsc: "often should have a fiddle"

  longLines:
    test: (question) ->
      lines = question.code().join('\n').split('\n')
      for line in lines
        return true if line.length > 80
      false

    dsc: "shouldn't have long lines"

  lotsOfCode:
    test: (question) ->
      code = question.code().join('\n')
      chars = code.replace(/\s+/g, "").length # chars - whitespace
      lines = code.split('\n').length

      if question.tags.contains 'sql'
        if chars > 2500 or lines > 125
          {chars, lines}
        else
          false
      else if chars > 1000 or lines > 30
        {chars, lines}
      else
        false
    dsc: "should have sucinct code"

  lotsOfText:
    test: (question) ->
      text = question.text().join('\n')
      chars = text.replace(/\n+/g, "").length # chars - new lines

      if question.tags.contains 'sql'
        if chars > 2000
          {chars}
        else
          false
      else if chars > 1000
        {chars}
      else
        false

    dsc: "should have consise text"

  didntTry:
    test: (question) ->
      text = question.text().join(' ').toLowerCase()
      not _.any [ _.contains text, x for x in ['i tried', 'when i', 'i am trying'] ]

    dsc: "should show what was tried"

  howCanIDoThis:
    test: (question) ->
      text = question.text().join(' ').toLowerCase()
      code = question.code().join('\n')
      codeChars = code.replace(/\s+/g, "").length

      _.contains(text, 'how can i do this') and codeChars < 100
    dsc: "should show research effort"

  aspRaw:
    test: (question) ->
      tags = question.tags().join(' ')
      asp = _.contains tags, 'asp'
      css = _.contains tags, 'css'
      js =  _.contains tags, 'js'
      source = question.code().join(' ').indexOf("<%=") isnt -1
      asp and source and (css or js)

    dsc: "should provide easily testable code"

url = (self) ->
  self.id() and self.question.title() # Create subscribtions
  location.host + location.pathname

### Exports ###
root.sl =
  makeLintObject: (question) ->
    output = []
    for name, lint of lints
      lint = _.clone lint
      lint.test = ko.computed lint.test.bind(output, question)
      output[name] = lint
    return output

  simpleComment: ->
    "[StackLint](#{ url(this)  })"

  descriptiveComment: ->
    link = "(#{ url(this)  })"

    text = do =>
      description = do => lint.dsc for n, lint of @lint when lint.test()

      if description.length > 1
        [most, last] = [ description[...-1], description.slice(-1) ]

        # [0, 1, 2, 3] -> "0, 1, 2, and 3"
        [most.join(', '), last[0]].join(', and ')
      else if description.length is 1
        description[0]
      else
        "should look like this one"

    "Questions [#{text}]#{link}"



