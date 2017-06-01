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
  m.buttons.itemSelected = 0
  m.buttons.focusedColor = m.buttonDefinitions[0].color

  ' Make sure a default color scheme is set

  if not m.global.hasField("keyColor")
    m.global.addFields( {keyColor: m.top.selectedColor, keyColorTint: m.top.selectedColorTint} )
  end if

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

  m.global.keyColor = m.top.selectedColor
  m.global.keyColorTint = m.top.selectedColorTint

  print "OptionsScreen.brs - [onButtonSelectedChanged]" m.top.itemSelected " (keyColor = " m.global.keyColor " " m.top.selectedColor ")"

end sub

' =============================================================================
' contentList2SimpleNode - Helper function convert AA to Node
' =============================================================================

function contentList2SimpleNode(contentList as Object, nodeType = "ContentNode" as String) as Object

  print "OptionsScreen.brs - [contentList2SimpleNode] " nodeType

  result = createObject("roSGNode", nodeType)

  if result <> invalid then

    for each itemAA in contentList

      item = createObject("roSGNode", nodeType)

      ' If the node does not have the property found in the associative array, then
      ' create the property in the node (as a string)

      for each property in itemAA

        if not item.hasField(property) then
          item.addField(property, "string", false)
        end if

      end for

      ' Set the property value for all properties found in the associative array item
      ' and append the node to the root node

      item.setFields(itemAA)
      result.appendChild(item)

    end for

  end if

  return result

end function
