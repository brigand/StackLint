### StackLint (c) FakeRainBrigand 2013
  This file uses jQuery, anyorigin.com, and various techniques to extract data from a stackoverflow question
###

throw "soparse.coffee doesn't function without a browser environment" unless window?
throw "jQuery required to access the stackoverflow question" unless ($ = jQuery)?
root = window

anyorigin = "http://anyorigin.com/get?url="
stackquestion = "stackoverflow.com/questions"

class StackQuestion
  constructor: (questionId) ->
    @id = ko.observable questionId ? ''
    @title = ko.observable 'Loading Question'
    @url = ko.observable ''
    @html = ko.observable ''
    @tags = ko.observableArray []
    @code = ko.observableArray []
    @text = ko.observableArray []
    @links = ko.observableArray []
    @user = ko.observable ''

    @handleId questionId if questionId?
    @id.subscribe @handleId.bind this

  handleId: (questionId) ->
    # Download the page using the anyorigin service
    $.getJSON "#{anyorigin}#{stackquestion}/#{questionId}/&callback=?", (data) =>

      # Load our HTML into a virtual div
      @el = $(data.contents).find('#content')
      @el.remove('script')

      # Call these functions which interact with out invisible div to find information
      @title @parseTitle()
      @url @parseUrl()
      @tags @parseTags()
      @code @parseCode()
      @text @parseText()
      @links @parseLinks()
      @user @parseUser()


  parseTitle: ->
    @el.find('#question-header a').text()

  parseUrl: ->
    "http://stackoverflow.com" + @el.find('#question-header a').attr('href')

  parseTags: ->
    tags = []
    @el.find('.post-taglist a').each ->
      tags.push this.innerText
    tags

  parseCode: ->
    code = []
    @el.find('.postcell pre').each ->
      code.push this.innerText
    code

  parseText: ->
    text = []
    @el.find('.postcell .post-text p').each ->
      text.push this.innerText
    text

  parseLinks: ->
    links = []
    @el.find('.postcell .post-text a').each ->
      links.push
        href: this.href
        text: this.innerText
    links

  parseUser: ->
    a = @el.find('.user-details a').get(0)

    {
      url: "http://stackoverflow.com" + a.pathname
      name: a.innerText
    }



root.StackQuestion = StackQuestion