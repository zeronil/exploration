' =============================================================================
' init
' =============================================================================

sub init()
  m.hasFocus = false
  m.poster = m.top.findNode("poster")
  m.posterBackground = m.top.findNode("posterBackground")
  m.focusRectangle = m.top.findNode("focusRectangle")
  m.focusRectangleAnimation = m.top.findNode("focusRectangleAnimation")
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
' itemFocusChanged
'
'   focusPercent - Message sent to the row item that is losing focus and the row item gaining focus
'   rowFocusPercent - Message sent to multiple items in the row that is losing focus and multiple items in the row item gaining focus
'
' =============================================================================

sub itemFocusChanged(message as object)

  ' print "CustomItem.brs [itemFocusChanged] hasFocus = " m.hasFocus ", focus =" message.getData() ", field = " message.getField()

  focusPercent = message.getData()

  if m.hasFocus then

    if focusPercent = 0 then
      print "CustomItem.brs [itemFocusChanged] Lost focus on " message.getField() ": uri = " m.poster.uri
      m.hasFocus = false
      ' unobserveField("m.global.keyColor")
    end if

    m.focusRectangle.visible = false

  else

    if focusPercent = 1 and message.getField() = "focusPercent" then

      print "CustomItem.brs [itemFocusChanged] Gained focus on focusPercent: color = " m.global.keyColor " uri = " m.poster.uri

      m.hasFocus = true
      m.focusRectangle.opacity = 0.0
      m.focusRectangle.visible = true
      m.focusRectangle.color = m.global.keyColor
      m.focusRectangleAnimation.control = "start"

      ' observeField("m.global.keyColor", "handleKeyColorChanged")

    end if

  end if

end sub

sub handleKeyColorChanged()
  m.focusRectangle.color = m.global.keyColor
end sub

' =============================================================================
' hasFocus
' =============================================================================

sub hasFocus(isFocused as Boolean)

  ' print "CustomItem.brs [itemFocusChanged] field = " message.getField() ", value =" message.getData() ", uri = " m.poster.uri
  print "CustomItem.brs [itemFocusChanged] isFocused = " isFocused ", uri = " m.poster.uri

end sub

' =============================================================================
' updateLayout - Called when the item's width or height changes, or when
'                the function itemContentChanged is called
' =============================================================================

sub updateLayout()

  ' print "CustomItem.brs - [updateLayout] "

  if m.top.height > 0 And m.top.width > 0 then

    m.poster.width  = m.top.width
    m.poster.height = m.top.height

    m.posterBackground.width  = m.top.width
    m.posterBackground.height = m.top.height

    m.focusRectangle.width  = m.top.width
    m.focusRectangle.height = m.top.height / 2
    m.focusRectangle.translation = [0, m.focusRectangle.height]

  end if

end sub
