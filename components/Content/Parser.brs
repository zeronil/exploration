' ********** Copyright 2016 Roku Corp.  All Rights Reserved. **********

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

  print "Parser.brs - [parseResponse]"

  contentString = m.top.response.content
  num = m.top.response.num

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

  ' For the 3 rows before the "grid"

  list = [
    {
        Title:"Big Hits"
        ContentList : channelItemsArray
    }
    {
        Title:"Action"
        ContentList : channelItemsArray
    }
    {
        Title:"Drama"
        ContentList : channelItemsArray
    }
  ]

  'Logic for creating a "row" vs. a "grid"

  if num = 3
    content = createGrid(channelItemsArray)
  else
    content = createRow(list, num)
  end if

  'Add the newly parsed content row/grid to the cache until everything is ready

  contentAA = {}

  if content <> invalid
    contentAA[num.toStr()] = content
    if m.UriHandler = invalid then m.UriHandler = m.top.getParent()
    m.UriHandler.contentCache.addFields(contentAA)
  else
    print "Error: content was invalid"
  end if

end sub

' =============================================================================
' createRow - Create a row of content
' =============================================================================

function createRow(list as object, num as Integer)

  print "Parser.brs - [createRow]"

  Parent = createObject("RoSGNode", "ContentNode")
  row = createObject("RoSGNode", "ContentNode")
  row.Title = list[num].Title

  for each itemAA in list[num].ContentList
    item = createObject("RoSGNode","ContentNode")
    AddAndSetFields(item, itemAA)
    row.appendChild(item)
  end for

  Parent.appendChild(row)

  return Parent

end function

' =============================================================================
' createGrid - Create a grid of content - simple splitting of a feed to different rows
'              with the title of the row hidden. Set the for loop parameters to adjust
'              how many columns there should be in the grid.
' =============================================================================

function createGrid(list as object)

  print "Parser.brs - [createGrid]"

  Parent = createObject("RoSGNode","ContentNode")

  for i = 0 to list.count() step 4

    row = createObject("RoSGNode","ContentNode")

    if i = 0
      row.Title = "The Grid"
    end if

    for j = i to i + 3
      if list[j] <> invalid
        item = createObject("RoSGNode","ContentNode")
        AddAndSetFields(item,list[j])
        row.appendChild(item)
      end if
    end for

    Parent.appendChild(row)

  end for

  return Parent

end function
