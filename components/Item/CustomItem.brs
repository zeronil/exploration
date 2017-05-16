' ********** Copyright 2016 Roku Corp.  All Rights Reserved. **********

' =============================================================================
' init
' =============================================================================

sub init()
  m.Poster = m.top.findNode("poster")
end sub

' =============================================================================
' itemContentChanged - Called when content is assigned to the item
' =============================================================================

sub itemContentChanged()

  m.Poster.loadDisplayMode = "scaleToZoom"

  if m.top.height < 400 and m.top.width < 400
    m.Poster.loadWidth = 300
    m.Poster.loadHeight = 150
  end if

  updateLayout()

  m.Poster.uri = m.top.itemContent.HDPOSTERURL

end sub

' =============================================================================
' updateLayout - Called when the item's width or height changes, or when
'                itemContentChanged() is called
' =============================================================================

sub updateLayout()
  if m.top.height > 0 And m.top.width > 0 then
    m.Poster.width  = m.top.width
    m.Poster.height = m.top.height
  end if
end sub
