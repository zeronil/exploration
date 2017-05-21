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

  print "Parser.brs - [parseResponse] Job" num ", format = " format "(" title ")"

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
    content = createRow(channelItemsArray, title)
  else
    content = createGrid(channelItemsArray, title)
  end if

  ' Add the newly parsed content row/grid to the cache until everything is ready

  contentAA = {}

  if content <> invalid

    contentAA[num.toStr()] = content

    ' If the reference to the UriHandler that created the parser has not yet been assigned,
    ' the assign the reference (the UriHandler will be the parent of Parser since UriHandler
    ' created Parser and maintains a reference to Parser)

    if m.UriHandler = invalid then m.UriHandler = m.top.getparentNode()

    '
    m.UriHandler.contentCache.addFields(contentAA)

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

function createRow(list as object, title as string)

  print "Parser.brs - [createRow]"

  parentNode = createObject("RoSGNode", "ContentNode")

  row = createObject("RoSGNode", "ContentNode")
  row.Title = title

  for each itemAA in list
    item = createObject("RoSGNode","ContentNode")
    addAndSetFields(item, itemAA)
    row.appendChild(item)
  end for

  parentNode.appendChild(row)

  return parentNode

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

function createGrid(list as object, title as string)

  print "Parser.brs - [createGrid]"

  parentNode = createObject("RoSGNode","ContentNode")

  for i = 0 to list.count() step 4

    row = createObject("RoSGNode","ContentNode")

    if i = 0
      row.Title = title
    end if

    for j = i to i + 3

      if list[j] <> invalid
        item = createObject("RoSGNode","ContentNode")
        addAndSetFields(item,list[j])
        row.appendChild(item)
      end if
      
    end for

    parentNode.appendChild(row)

  end for

  return parentNode

end function
