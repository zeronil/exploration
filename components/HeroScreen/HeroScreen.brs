' =============================================================================
' init - Called when the HeroScreen component is initialized
' =============================================================================

sub init()

  ' Get the Roku device model that the application is running on

  deviceInfo = CreateObject("roDeviceInfo")
  deviceModel = deviceInfo.getModel()

  ' Set the height of the colored part of the overhang depending upon the device

  if deviceModel = "4200X" then
    overhangHeight = 140
  else
    overhangHeight = 150
  end if

  ' Add device specific data to global variables

  m.global.addFields({deviceModel: deviceModel, overhangHeight: overhangHeight})

  print "HeroScreen.brs - [init] " m.global.deviceModel " (overhangHeight =" m.global.overhangHeight ")"

  ' Get references to child nodes

  m.FadingBackground = m.top.findNode("FadingBackground")
  m.RowList = m.top.findNode("RowList")

  ' Create a task node to fetch the UI content and populate the screen

  m.UriHandler = CreateObject("roSGNode", "UriHandler")

  ' Create observer for when content is loaded

  m.UriHandler.observeField("responseContent", "onContentLoaded")

  ' Make a request for each "row" in the UI (in the order that you want content filled)
  '
  '   showRowLabel - Specifies whether the row label on the left edge of each row is displayed.
  '   showRowCounter - Specifies whether the "X of Y" label on the right edge of each row is displayed (only visible for focused row).
  '   rowHeight - The height of the row of the list. The value overrides the height specified in the RowList itemSize field.
  '   rowItemSize - The width and height of the items in the row.

  requests = [
    ' Uncomment this line to simulate a bad request and make the dialog box appear
    ' "bad request",
    {
      uri: "http://api.delvenetworks.com/rest/organizations/59021fabe3b645968e382ac726cd6c7b/channels/1cfd09ab38e54f48be8498e0249f5c83/media.rss",
      format: "row",
      title: "Super Big Hits",
      showRowLabel: false,
      showRowCounter: true,
      rowHeight: 800,
      rowItemSize: [1600, 700]
    },
    {
      uri: "http://api.delvenetworks.com/rest/organizations/59021fabe3b645968e382ac726cd6c7b/channels/5a438a6cfe68407684832d54c4b58cbb/media.rss",
      format: "row",
      title: "Super Action",
      showRowLabel: true,
      showRowCounter: true,
      rowHeight: 300,
      rowItemSize: [375, 200]
    },
    {
      uri: "http://api.delvenetworks.com/rest/organizations/59021fabe3b645968e382ac726cd6c7b/channels/4cd8f3ec67c64c16b8f3bf87339503dd/media.rss",
      format: "row",
      title: "Super Drama",
      showRowLabel: true,
      showRowCounter: true,
      rowHeight: 500,
      rowItemSize: [375, 400]
    },
    {
      uri: "http://api.delvenetworks.com/rest/organizations/59021fabe3b645968e382ac726cd6c7b/channels/c7f9e852f45044ceb0ae0d7748d675a5/media.rss",
      format: "grid",
      title: "Super Grid",
      showRowLabel: true,
      showRowCounter: false,
      rowHeight: 220,
      rowItemSize: [375, 200]
    }
  ]

  ' "Parser" parameter specifies that the component "Parser.brs" should be used to parse loaded content

  makeRequest(requests, "Parser")

  ' Observer for when the screen becomes visible (for instance, when returning from the DetailsScreen)

  m.top.observeField("visible", "onVisibleChange")

  ' Set focus to RowList if returning from DetailsScreen

  m.top.observeField("focusedChild", "onFocusedChildChange")

end sub

' =============================================================================
' makeRequest - Issues a URL request to the UriHandler component. When content
'               has been loaded, an observer will cause "OnContentLoaded" to be
'               called and the loaded content will be available in m.UriHandler.responseContent
' =============================================================================

sub makeRequest(requests as object, ParserComponent as String)

  m.UriHandler.numRequests = requests.count()

  ' Initiate a request for each "row" in the UI

  for i = 0 to requests.count() - 1

    print "HeroScreen.brs - [makeRequest] num =" i

    context = createObject("roSGNode", "Node")
    parameters = requests[i]

    if type(parameters) = "roAssociativeArray" then

      context.addFields({
        parameters: parameters,
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

  ' The metadata values are defined in the data for each request (see the init function above)
  ' and is propagated through to the UriHandler, which will attached the metadata to the
  ' response for each request that was fulfilled.

  m.top.contentShowRowLabel = m.UriHandler.responseContent.metadata.showRowLabel
  m.top.contentShowRowCounter = m.UriHandler.responseContent.metadata.showRowCounter
  m.top.contentRowHeights = m.UriHandler.responseContent.metadata.rowHeights
  m.top.contentRowItemSize = m.UriHandler.responseContent.metadata.rowItemSize

  m.top.content = m.UriHandler.responseContent.data

end sub

' =============================================================================
' onItemFocused - Handler for focused item in RowList
' =============================================================================

sub onItemFocused()

  print "HeroScreen.brs - [onItemFocused]"

  itemFocusedIndexes = m.top.itemFocused

  ' When an item gains the focus, set to a 2-element array,
  ' where element 0 contains the index of the focused row,
  ' and element 1 contains the index of the focused item
  ' in that row.

  if itemFocusedIndexes.Count() = 2 then

    focusedContent = m.top.content.getChild(itemFocusedIndexes[0]).getChild(itemFocusedIndexes[1])

    ' focusedContent is assigned to an interface field so that HeroScene can provide
    ' content data to DetailsScreen when a RowList item is focused. Also, a fullscreen
    ' (blurred) image for the selected item is assigned the the screen's background.

    if focusedContent <> invalid then
      m.top.focusedContent = focusedContent
      m.FadingBackground.uri = focusedContent.hdBackgroundImageUrl
    end if

  end if

end sub

' =============================================================================
' onVisibleChange - Sets focus to RowList in case channel returns from DetailsScreen
' =============================================================================

sub onVisibleChange()
  print "HeroScreen.brs - [onVisibleChange]"
  if m.top.visible then m.rowList.setFocus(true)
end sub

' =============================================================================
' onFocusedChildChange - Set focus to RowList in case of return from DetailsScreen
'                        or the LoadingIndicator is removed, etc.
' =============================================================================

sub onFocusedChildChange()
  print "HeroScreen.brs - [onFocusedChildChange]"
  if m.top.isInFocusChain() and not m.rowList.hasFocus() then m.rowList.setFocus(true)
end sub
