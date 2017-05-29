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
    {title: "Red Theme", color: "0x990000", tint: "0xFF5555"},
    {title: "Purple Theme", color: "0x551A8B", tint: "0xB27DFB"},
    {title: "Green Theme", color: "0x007700", tint: "0x448844"}
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

  m.top.selectedColor = m.buttonDefinitions[m.top.itemSelected].color
  m.top.selectedColorTint = m.buttonDefinitions[m.top.itemSelected].tint

  ' Save the selected color as a global "keyColor" (the keyColor is used by CustomItem
  ' as the highlight color for selected RowList itens)

  if not m.global.hasField("keyColor")
    m.global.addFields( {keyColor: m.top.selectedColor, keyColorTint: m.top.selectedColorTint} )
  else
    m.global.keyColor = m.top.selectedColor
    m.global.keyColorTint = m.top.selectedColorTint
  end if

  print "OptionsScreen.brs - [onButtonSelectedChanged]" m.top.itemSelected " (keyColor = " m.global.keyColor " " m.top.selectedColor ")"

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
