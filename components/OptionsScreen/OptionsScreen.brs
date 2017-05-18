 ' =============================================================================
 ' init - Initializes the Options screen, sets all observers and configures buttons for Options screen
 ' =============================================================================

function init()

  print "OptionsScreen.brs - [init]"

  m.top.observeField("visible", "onVisibleChange")

  m.buttons = m.top.findNode("Buttons")
  m.buttons.observeField("itemFocused", "onItemFocused")

  ' Create buttons

  result = []

  for each button in ["Red Banner", "Purple Banner"]
    result.push({title : button})
  end for

  ' Initially selected button

  m.buttons.checkedItem = 0

  m.buttons.content = contentList2SimpleNode(result)

end function

' =============================================================================
' onVisibleChange - When entering Options screen, set the focus to the first button
' =============================================================================

sub onVisibleChange()

  if m.top.visible

    print "OptionsScreen.brs - [onVisibleChange] Visible - focus first button"

    m.buttons.jumpToItem = m.buttons.checkedItem
    m.buttons.setFocus(true)

  end if

end sub

' =============================================================================
' onItemFocused
' =============================================================================

sub onItemFocused()

  print "OptionsScreen.brs - [onItemFocused]" m.buttons.itemFocused

  if m.buttons.itemFocused = 0
    m.buttons.focusedColor = "0xFF0000"
  else if m.buttons.itemFocused = 1
    m.buttons.focusedColor = "0x551A8B"
  end if

end sub

' =============================================================================
' onInitialItemSelectedChanged
' =============================================================================

sub onInitialItemSelectedChanged()

  print "OptionsScreen.brs - [onInitialItemSelectedChanged]" m.top.initialItemSelected

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
