' =============================================================================
' init
' =============================================================================

sub init()
  print "Parser.brs - [init]"
end sub

' =============================================================================
' parseResponse - Parses the response string as XML
'                 The parsing logic will be different for different RSS feeds
' =============================================================================

sub parseResponse()

  contentString = m.top.response.content
  num = m.top.response.num
  format = m.top.response.format
  title = m.top.response.title

  print "Parser.brs - [parseResponse] Job" num ", format = " format " (" title ")"

  if contentString = invalid then return

  xml = CreateObject("roXMLElement")

  ' Return invalid if string can't be parsed

  if not xml.Parse(contentString) return

  if xml <> invalid then
    channelRoot = xml.getChildElements()
    channelElementsArray = channelRoot.getChildElements()
  end if

  channelItemsArray = []

  ' Process each channel element
  ' <title>, <link>, <description>, <pubDate>, <image>, and lots of <item>'s

  for each channelElement in channelElementsArray

  ' Get all channel <item>s

    if channelElement.getName() = "item"

      channelItemElements = channelElement.getChildElements()

      if channelItemElements <> invalid then

        channelItem = {}

        ' Get all <item> attributes

        for each channelItemElement in channelItemElements

           ' Build the channelItem associative array using the tag name and text text

           channelItem[channelItemElement.getName()] = channelItemElement.gettext()

          if channelItemElement.getName() = "media:content" then

            channelItem.stream = {url : channelItemElement.url}
            channelItem.url = channelItemElement.getAttributes().url
            channelItem.streamformat = "mp4"

            ' Get child elements of the <media:content> element

            mediaContent = channelItemElement.getChildElements()

          ' Add the channel item to the array of channel items

            for each mediaContentItem in mediaContent

              if mediaContentItem.getName() = "media:thumbnail" then
                channelItem.hdposterurl = mediaContentItem.getAttributes().url
                channelItem.hdbackgroundimageurl = mediaContentItem.getAttributes().url
                channelItem.uri = mediaContentItem.getAttributes().url
              end if

            end for

          end if

        end for

        channelItemsArray.push(channelItem)

      end if

    end if

  end for

  ' Logic for creating a "row" vs. a "grid"

  if format = "row"
    rowListContent = createRow(channelItemsArray, title)
  else
    rowListContent = createGrid(channelItemsArray, title)
  end if

  ' If content nodes were created

  if rowListContent <> invalid

    ' If the reference to the UriHandler that created the parser has not yet been assigned,
    ' the assign the reference (the UriHandler will be the parent of Parser since UriHandler
    ' created Parser and maintains a reference to Parser)

    if m.UriHandler = invalid then m.UriHandler = m.top.getParent()

    ' Add the row/grid created for the job to the cache while waiting for
    ' all requests to be processed. When contentCache changes, the event loop
    ' in UriHandler will call the UriHandler's updateContent function.

    content = {}
    content[num.toStr()] = rowListContent

    m.UriHandler.contentCache.addFields(content)

  ' Else no content for the request

  else
    print "Parser.brs - [parseResponse] Error: content was invalid"
  end if

end sub

' =============================================================================
' createRow - Create a row of content
'
'             NOTE: SGHelperFunctions is included by Parser.xml and makes
'                   available the addAndSetFields function.
'
' =============================================================================

function createRow(channelItemsArray as object, title as string)

  print "Parser.brs - [createRow] title = " title

  ' A RowList node should have a single ContentNode node as the root node in its content field.
  ' One child ContentNode node should be added to the root node for each row in the list (these nodes
  ' can be thought of as row nodes). Each row node should contain one child ContentNode node for each
  ' item in the row (these nodes can be thought of as item nodes).

  rowParentNode = createObject("RoSGNode", "ContentNode")

  ' Row

  row = createObject("RoSGNode", "ContentNode")
  row.title = title

  ' Row items

  for each item in channelItemsArray
    rowItem = createObject("RoSGNode", "ContentNode")
    addAndSetFields(rowItem, item)
    row.appendChild(rowItem)
  end for

  ' Just one row being added to the RowList

  rowParentNode.appendChild(row)

  return rowParentNode

end function

' =============================================================================
' createGrid - Create a grid of content - simple splitting of a feed to different rows
'              with the title of the row hidden. Set the for loop parameters to adjust
'              how many columns there should be in the grid.
'
'              NOTE: SGHelperFunctions is included by Parser.xml and makes
'                    available the addAndSetFields function.
'
' =============================================================================

function createGrid(channelItemsArray as object, title as string)

  print "Parser.brs - [createGrid]"

  ' A RowList node should have a single ContentNode node as the root node in its content field.
  ' One child ContentNode node should be added to the root node for each row in the list (these nodes
  ' can be thought of as row nodes). Each row node should contain one child ContentNode node for each
  ' item in the row (these nodes can be thought of as item nodes).

  rowParentNode = createObject("RoSGNode", "ContentNode")

  ' Create rows with 4 items per row

  for firstItemInRow = 0 to channelItemsArray.count() step 4

    ' Create the row node

    row = createObject("RoSGNode", "ContentNode")

    ' Set a title for the first row only

    if firstItemInRow = 0 then
      row.title = title
    end if

    ' Add the row items to the row

    for item = firstItemInRow to firstItemInRow + 3

      if channelItemsArray[item] <> invalid then
        rowItem = createObject("RoSGNode", "ContentNode")
        addAndSetFields(rowItem, channelItemsArray[item])
        row.appendChild(rowItem)
      end if

    end for

    ' Add the row to the parent node

    rowParentNode.appendChild(row)

  end for

  return rowParentNode

end function
