 ' =============================================================================
 ' init - Initializes the Options screen, sets all observers and configures buttons for Options screen
 ' =============================================================================

function init()

  print "OptionsScreen.brs - [init]"

  m.top.observeField("visible", "onVisibleChange")
  m.top.observeField("focusedChild", "onFocusedChildChange")

  m.buttons = m.top.findNode("Buttons")
  ' m.background = m.top.findNode("Background")

  ' Create buttons

  result = []

  for each button in ["First button", "Second button"]
    result.push({title : button})
  end for

  m.buttons.content = contentList2SimpleNode(result)

end function

' =============================================================================
' onVisibleChange
' =============================================================================

sub onVisibleChange()

  ' If entering Options screen, set the focus to the first button

  if m.top.visible

    print "OptionsScreen.brs - [onVisibleChange] Visible - focus first button"

    ' m.fadeIn.control="start"
    m.buttons.jumpToItem = 0
    m.buttons.setFocus(true)

  ' Else exiting video, so stop the video playback

  else

    print "OptionsScreen.brs - [onVisibleChange] Not visible"

    ' m.fadeOut.control="start"
    ' m.background.uri=""

  end if

end sub

' =============================================================================
' onItemSelected - Button press handler
' =============================================================================

sub onItemSelected()

  print "OptionsScreen.brs - [onItemSelected]" m.top.itemSelected

  ' First button in the list is Play

  if m.top.itemSelected = 0
  end if

end sub

' =============================================================================
' onContentChange
' =============================================================================

sub onContentChange()

  print "OptionsScreen.brs - [onContentChange]"

  ' m.poster.uri = m.top.content.hdBackgroundImageUrl
  ' m.background.uri = m.top.content.hdBackgroundImageUrl

end sub

' =============================================================================
' contentList2SimpleNode - Helper function convert AA to Node
' =============================================================================

function contentList2SimpleNode(contentList as Object, nodeType = "ContentNode" as String) as Object

  print "OptionsScreen.brs - [contentList2SimpleNode]"

  result = createObject("roSGNode", nodeType)

  if result <> invalid

    for each itemAA in contentList
      item = createObject("roSGNode", nodeType)
      item.setFields(itemAA)
      result.appendChild(item)
    end for

  end if

  return result

end function
