 ' =============================================================================
 ' init - Initializes the Options screen, sets all observers and configures buttons for Options screen
 ' =============================================================================

sub init()

  print "OptionsScreen.brs - [init]"

  m.top.observeField("visible", "onVisibleChange")

  m.buttons = m.top.findNode("Buttons")
  m.buttons.observeField("itemFocused", "onItemFocused")

  ' Create buttons

  m.buttonDefinitions = [
    {title: "Red Banner", color: "0xFF0000"},
    {title: "Purple Banner", color: "0x551A8B"},
    {title: "Green Banner", color: "0x007700"}
  ]

  m.buttons.content = contentList2SimpleNode(m.buttonDefinitions)

  ' Initially selected button

  m.buttons.checkedItem = 0
  m.buttons.focusedColor = m.buttonDefinitions[0].color

end sub

' =============================================================================
' onVisibleChange - When entering Options screen, set the focus to the selected button
' =============================================================================

sub onVisibleChange()

  if m.top.visible then

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

  if m.buttons.itemFocused < m.buttonDefinitions.Count() then
    print "OptionsScreen.brs - [onItemFocused] color = " m.buttonDefinitions[m.buttons.itemFocused].color
    m.buttons.focusedColor = m.buttonDefinitions[m.buttons.itemFocused].color
  end if

end sub

' =============================================================================
' onButtonSelectedChanged
' =============================================================================

sub onButtonSelectedChanged()

  print "OptionsScreen.brs - [onButtonSelectedChanged]" m.top.itemSelected
  m.top.selectedColor = m.buttonDefinitions[m.top.itemSelected].color

end sub

' =============================================================================
' contentList2SimpleNode - Helper function convert AA to Node
' =============================================================================

function contentList2SimpleNode(contentList as Object, nodeType = "ContentNode" as String) as Object

  print "OptionsScreen.brs - [contentList2SimpleNode]"

  result = createObject("roSGNode", nodeType)

  if result <> invalid then

    for each itemAA in contentList
      item = createObject("roSGNode", nodeType)
      item.setFields(itemAA)
      result.appendChild(item)
    end for

  end if

  return result

end function
