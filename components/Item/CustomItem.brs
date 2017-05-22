' ********** Copyright 2016 Roku Corp.  All Rights Reserved. **********

' =============================================================================
' init
' =============================================================================

sub init()
  m.poster = m.top.findNode("poster")
  m.posterBackground = m.top.findNode("posterBackground")
end sub

' =============================================================================
' itemContentChanged - Called when content is assigned to the item
' =============================================================================

sub itemContentChanged()

  m.poster.loadDisplayMode = "scaleToFill"

  if m.top.height < 400 and m.top.width < 400
    m.poster.loadWidth = 300
    m.poster.loadHeight = 150
  end if

  updateLayout()

  m.poster.uri = m.top.itemContent.HDPOSTERURL

end sub

' =============================================================================
' updateLayout - Called when the item's width or height changes, or when
'                itemContentChanged() is called
' =============================================================================

sub updateLayout()

  if m.top.height > 0 And m.top.width > 0 then

    m.poster.width  = m.top.width
    m.poster.height = m.top.height

    ' print "CustomItem.brs - [updateLayout] " m.posterBackground

    m.posterBackground.width  = m.top.width
    m.posterBackground.height = m.top.height

  end if

end sub
