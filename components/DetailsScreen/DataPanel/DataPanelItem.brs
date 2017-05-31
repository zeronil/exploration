 ' =============================================================================
 ' init - Set top interfaces
 ' =============================================================================

sub init()

  print "DataPanelItem.brs - [init]"

  m.itemLabel = m.top.findNode("itemLabel")
  m.itemValue = m.top.findNode("itemValue")

end sub

' =============================================================================
' onLabelChanged
' =============================================================================

sub onLabelChange()

  print "DataPanelItem.brs - [onLabelChange] " m.top.label

  if m.top.label <> invalid then
    m.itemLabel.text = m.top.label + ":"
  else
    m.itemLabel.text = ""
  end if

end sub

' =============================================================================
' onValueChanged
' =============================================================================

sub onValueChange()

  print "DataPanelItem.brs - [onValueChange] " m.top.value

  if m.top.value <> invalid then
    m.itemValue.text = m.top.value
  else
    m.itemValue.text = ""
  end if

end sub
