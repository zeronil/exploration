' =============================================================================
' init - Called when the HeroScreen component is initialized
' =============================================================================

sub init()

  ' Uncomment the print statements to see where and when the functions are called

  print "HeroScreen.brs - [init]"

  ' Get references to child nodes

  m.Background = m.top.findNode("Background")
  m.RowList = m.top.findNode("RowList")

  ' Create a task node to fetch the UI content and populate the screen

  m.UriHandler = CreateObject("roSGNode", "UriHandler")

  ' Create observer for when content is loaded

  m.UriHandler.observeField("responseContent", "onContentLoaded")

  ' Make a request for each "row" in the UI (in the order that you want content filled)

  URLs = [
    ' Uncomment this line to simulate a bad request and make the dialog box appear
    ' "bad request",
    "http://api.delvenetworks.com/rest/organizations/59021fabe3b645968e382ac726cd6c7b/channels/1cfd09ab38e54f48be8498e0249f5c83/media.rss",
    "http://api.delvenetworks.com/rest/organizations/59021fabe3b645968e382ac726cd6c7b/channels/5a438a6cfe68407684832d54c4b58cbb/media.rss",
    "http://api.delvenetworks.com/rest/organizations/59021fabe3b645968e382ac726cd6c7b/channels/4cd8f3ec67c64c16b8f3bf87339503dd/media.rss",
    "http://api.delvenetworks.com/rest/organizations/59021fabe3b645968e382ac726cd6c7b/channels/c7f9e852f45044ceb0ae0d7748d675a5/media.rss"
  ]

  ' "Parser" parameter specifies that the component "Parser.brs" should be used to parse loaded content

  makeRequest(URLs, "Parser")

  ' Observer for when the screen becomes visible (for instance, when returning from from Details Screen)

  m.top.observeField("visible", "onVisibleChange")

  ' Set proper focus to RowList in case of return from Details Screen

  m.top.observeField("focusedChild", "onFocusedChildChange")

end sub

' =============================================================================
' makeRequest - Issues a URL request to the UriHandler component. When content
'               has been loaded, an observer will cause "OnContentLoaded" to be
'               called and the loaded content will be available in m.UriHandler.responseContent
' =============================================================================

sub makeRequest(URLs as object, ParserComponent as String)

  ' Initiate a request for each "row" in the UI

  for i = 0 to URLs.count() - 1

    print "HeroScreen.brs - [makeRequest] num =" i

    context = createObject("roSGNode", "Node")
    uri = { uri: URLs[i] }

    if type(uri) = "roAssociativeArray"

      context.addFields({
        parameters: uri,
        num: i,
        response: {}
      })

      m.UriHandler.request = {
        context: context
        parser: ParserComponent
      }

    end if

  end for

end sub

' =============================================================================
' onContentLoaded - Observer function to handle content loaded by UriHandler
'                   The UriHandler responseContent is assigned to the "content" field,
'                   which is an alias for the RowList content.
' =============================================================================

sub onContentLoaded()
  print "HeroScreen.brs - [onContentLoaded] UriHandler loaded content"
  m.top.numBadRequests = m.UriHandler.numBadRequests
  m.top.content = m.UriHandler.responseContent
end sub

' =============================================================================
' onVisibleChange - Sets proper focus to RowList in case channel returns from Details Screen
' =============================================================================

sub onVisibleChange()
  print "HeroScreen.brs - [onVisibleChange]"
  if m.top.visible then m.rowList.setFocus(true)
end sub

' =============================================================================
' onItemFocused - Handler for focused item in RowList
' =============================================================================

sub onItemFocused()

  print "HeroScreen.brs - [onItemFocused]"

  itemFocused = m.top.itemFocused

  ' When an item gains the key focus, set to a 2-element array,
  ' where element 0 contains the index of the focused row,
  ' and element 1 contains the index of the focused item in that row.

  if itemFocused.Count() = 2 then

    focusedContent = m.top.content.getChild(itemFocused[0]).getChild(itemFocused[1])

    if focusedContent <> invalid then
      m.top.focusedContent = focusedContent
      m.Background.uri = focusedContent.hdBackgroundImageUrl
    end if

  end if

end sub

' =============================================================================
' onFocusedChildChange - Set proper focus to RowList in case of return from Details Screen
' =============================================================================

sub onFocusedChildChange()
  print "HeroScreen.brs - [onFocusedChildChange]"
  if m.top.isInFocusChain() and not m.rowList.hasFocus() then m.rowList.setFocus(true)
end sub
