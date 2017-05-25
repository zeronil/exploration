' =============================================================================
' init
' =============================================================================

sub init()
  m.hasFocus = false
  m.poster = m.top.findNode("poster")
  m.posterBackground = m.top.findNode("posterBackground")
  m.backgroundRectangle = m.top.findNode("backgroundRectangle")
  m.contentRectangle = m.top.findNode("contentRectangle")
  m.detailGroup = m.top.findNode("detailGroup")
  m.detailGroupAnimation = m.top.findNode("detailGroupAnimation")
  m.titleLabel = m.top.findNode("titleLabel")
  m.titleShadowLabel = m.top.findNode("titleShadowLabel")
  m.detailMaskGroup = m.top.findNode("detailMaskGroup")
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
  title = m.top.itemContent.title

  ' When the item has focus and the focusPercent changes, then focus is being removed.
  ' Clear the local focus flag for the item  and stop watching for key color changes
  ' (the key color can change via OptionsScreen).

  if m.hasFocus and focusPercent < 1.0 then

      print "CustomItem.brs [itemFocusChanged] Lost focus on " message.getField() " (" title ")"

      m.hasFocus = false
      m.detailGroup.visible = false

      m.global.unobserveField("keyColor")

  ' Else if the item is not focused and becomes fully focused (focusPercent = 1),
  ' then set the local focus flag and animate in the detail overlay. Also, begin
  ' watching the key color in case the user changes it via OptionsScreen.

  else if not m.hasFocus and focusPercent = 1 and message.getField() = "focusPercent" then

      print "CustomItem.brs [itemFocusChanged] Gained focus on focusPercent (" title ")"

      m.hasFocus = true

      m.titleLabel.text = title
      m.titleShadowLabel.text = title
      m.titleShadowLabel.color = m.global.keyColor
      m.backgroundRectangle.color = m.global.keyColor

      m.detailGroup.opacity = 0.0
      m.detailGroup.visible = true
      m.detailGroupAnimation.control = "start"

      m.global.observeField("keyColor", "handleKeyColorChanged")

  end if

end sub

' =============================================================================
' handleKeyColorChanged - Called when the item has focus and the user changes
'                         the keyColor via OptionsScreen.
' =============================================================================

sub handleKeyColorChanged()
  m.backgroundRectangle.color = m.global.keyColor
  m.titleShadowLabel.color = m.global.keyColor
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

    if m.top.height > 400 then
      contentReservedHeight = m.top.height * .25
      m.titleLabel.font = "font:LargeBoldSystemFont"
      m.titleShadowLabel.font = "font:LargeBoldSystemFont"
    else
      contentReservedHeight = 100
      m.titleLabel.font = "font:SmallBoldSystemFont"
      m.titleShadowLabel.font = "font:SmallBoldSystemFont"
    end if

    detailGroupHeight = contentReservedHeight
    detailGroupWidth = m.top.width
    detailGroupYOffset = m.top.height - contentReservedHeight

    m.detailGroup.width  = detailGroupWidth
    m.detailGroup.height = detailGroupHeight
    m.detailGroup.translation = [0, detailGroupYOffset]

    m.backgroundRectangle.width  = detailGroupWidth
    m.backgroundRectangle.height = detailGroupHeight

    m.detailMaskGroup.width  = detailGroupWidth
    m.detailMaskGroup.height = detailGroupHeight
    m.detailMaskGroup.maskSize = [detailGroupWidth, detailGroupHeight]

    contentHeight = detailGroupHeight * 0.96
    contentBorder = detailGroupHeight * 0.04
    contentWidth = detailGroupWidth

    m.contentRectangle.width  = contentWidth
    m.contentRectangle.height = contentHeight
    m.contentRectangle.translation = [0, contentBorder]

    m.titleLabel.width  = contentWidth - 10
    m.titleLabel.height = contentHeight
    m.titleLabel.translation = [5, contentBorder]

    shadowYOffset = contentBorder + 2

    m.titleShadowLabel.width  = contentWidth - 10
    m.titleShadowLabel.height = contentHeight
    m.titleShadowLabel.translation = [7, shadowYOffset]

  end if

end sub
