' ********** Copyright 2016 Roku Corp.  All Rights Reserved. **********

' =============================================================================
' init
' =============================================================================

sub init()

  print "LoadingIndicator.brs - [init]"

  m.image = m.top.findNode("image")
  m.image.observeField("loadStatus", "omImageLoadStatusChange")

  m.text = m.top.findNode("text")

  m.rotationAnimation = m.top.findNode("rotationAnimation")
  m.rotationAnimationInterpolator = m.top.findNode("rotationAnimationInterpolator")

  m.fadeAnimation = m.top.findNode("fadeAnimation")

  m.loadingIndicatorGroup = m.top.findNode("loadingIndicatorGroup")
  m.loadingGroup = m.top.findNode("loadingGroup")

  m.background = m.top.findNode("background")

  m.textHeight = 0
  m.textPadding = 0

  ' Image could have been loaded by this time

  omImageLoadStatusChange()

  startAnimation()

end sub

' =============================================================================
' updateLayout - Called when "centered", "height" or "width" changes, or if the
'                parent hieght or width changes (observers are set below)
' =============================================================================

sub updateLayout()

  print "LoadingIndicator.brs - [updateLayout]"

  ' Check for parent node and set observers

  if m.top.getParent() <> invalid
      m.top.getParent().observeField("width", "updateLayout")
      m.top.getParent().observeField("height", "updateLayout")
  end if

  componentWidth = getComponentWidth()
  componentHeight = getComponentHeight()

  m.text.width = componentWidth - m.textPadding * 2
  m.background.width = componentWidth
  m.background.height = componentHeight

  ' IF the "centered" flag is set, then center the component within the parent

  if m.top.centered
      m.top.translation = [(getParentWidth() - componentWidth) / 2, (getParentHeight() - componentHeight) / 2]
  end if

  loadingGroupWidth = max(m.image.width, m.text.width)
  loadingGroupHeight = m.image.height + m.textHeight

  ' Check whether image and text fit into component, if they don't - downscale image

  if m.imageAspectRatio <> invalid

      loadingGroupAspectRatio = loadingGroupWidth / loadingGroupHeight

      if loadingGroupWidth > componentWidth
          m.image.width = m.image.width - (loadingGroupWidth - componentWidth)
          m.image.height = m.image.width / m.imageAspectRatio
          loadingGroupWidth = max(m.image.width, m.text.width)
          loadingGroupHeight = loadingGroupWidth / loadingGroupAspectRatio
      end if

      if loadingGroupHeight > componentHeight
          m.image.height = m.image.height - (loadingGroupHeight - componentHeight)
          m.image.width = m.image.height * m.imageAspectRatio
          loadingGroupHeight = m.image.height + m.textHeight
          loadingGroupWidth = loadingGroupHeight * loadingGroupAspectRatio
      end if

  end if

  ' Determine the center of rotation for the indicator image

  m.image.scaleRotateCenter = [m.image.width / 2, m.image.height / 2]

  ' Position loading group, image and text at the center

  m.loadingGroup.translation = [(componentWidth - loadingGroupWidth) / 2, (componentHeight - loadingGroupHeight) / 2]
  m.image.translation = [(loadingGroupWidth - m.image.width) / 2, 0]
  m.text.translation = [0, m.image.height + m.top.spacing]

end sub

' =============================================================================
' getComponentWidth
' =============================================================================

function getComponentWidth() as Float

  print "LoadingIndicator.brs - [getComponentWidth]"

  ' If this component's width is zero, then use the parent's width

  if m.top.width = 0
    return getParentWidth()
  else
    return m.top.width
  end if

end function

' =============================================================================
' getComponentHeight
' =============================================================================

function getComponentHeight() as Float

  print "LoadingIndicator.brs - [getComponentHeight]"

  ' If this component's height is zero, then use the parent's height

  if m.top.height = 0
    return getParentHeight()
  else
    return m.top.height
  end if

end function

' =============================================================================
' getParentWidth
' =============================================================================

function getParentWidth() as Float

  print "LoadingIndicator.brs - [getParentWidth]"

  ' If the parent's width is not known, then default to 1270

  if m.top.getParent() <> invalid and m.top.getParent().width <> invalid then
    return  m.top.getParent().width
  else
    return 1270
  end if

end function

' =============================================================================
' getParentHeight
' =============================================================================

function getParentHeight() as Float

  print "LoadingIndicator.brs - [getParentHeight]"

  ' If the parent's height is not known, then default to 720

  if m.top.getParent() <> invalid and m.top.getParent().height <> invalid then
    return m.top.getParent().height
  else
    return 720
  end if

end function

' =============================================================================
' changeRotationDirection
' =============================================================================

sub changeRotationDirection()

  print "LoadingIndicator.brs - [changeRotationDirection]"

  if m.top.clockwise
    m.rotationAnimationInterpolator.key = [1, 0]
  else
    m.rotationAnimationInterpolator.key = [0, 1]
  end if

end sub

' =============================================================================
' omImageLoadStatusChange
' =============================================================================

sub omImageLoadStatusChange()

  print "LoadingIndicator.brs - [omImageLoadStatusChange]"

  if m.image.loadStatus = "ready"

    m.imageAspectRatio = m.image.bitmapWidth / m.image.bitmapHeight

    if m.top.imageWidth > 0 and m.top.imageHeight <= 0
      m.image.height = m.image.width / m.imageAspectRatio

    else if m.top.imageHeight > 0 and m.top.imageWidth <= 0
      m.image.width = m.image.height * m.imageAspectRatio

    else if m.top.imageHeight <= 0 and m.top.imageWidth <= 0
      m.image.height = m.image.bitmapHeight
      m.image.width = m.image.bitmapWidth

    end if

    updateLayout()

  end if

end sub

' =============================================================================
' onImageWidthChange
' =============================================================================

sub onImageWidthChange()

  print "LoadingIndicator.brs - [onImageWidthChange]"

  if m.top.imageWidth > 0

    m.image.width = m.top.imageWidth

    if m.top.imageHeight <= 0 and m.imageAspectRatio <> invalid
      m.image.height = m.image.width / m.imageAspectRatio
    end if

    updateLayout()

  end if

end sub

' =============================================================================
' onImageHeightChange
' =============================================================================

sub onImageHeightChange()

  print "LoadingIndicator.brs - [onImageHeightChange]"

  if m.top.imageHeight > 0

    m.image.height = m.top.imageHeight

    if m.top.imageWidth <= 0 and m.imageAspectRatio <> invalid
      m.image.width = m.image.height * m.imageAspectRatio
    end if

    updateLayout()

  end if

end sub

' =============================================================================
' onTextChange
' =============================================================================

sub onTextChange()

  print "LoadingIndicator.brs - [onTextChange]"

  prevTextHeight = m.textHeight

  if m.top.text = ""
    m.textHeight = 0
  else
    m.textHeight = m.text.localBoundingRect().height + m.top.spacing
  end if

  if m.textHeight <> prevTextHeight
    updatelayout()
  end if

end sub

' =============================================================================
' onBackgroundImageChange
' =============================================================================

sub onBackgroundImageChange()

  print "LoadingIndicator.brs - [onBackgroundImageChange]"

  if m.top.backgroundUri <> ""

    previousBackground = m.background

    m.background = m.top.findNode("backgroundImage")
    m.background.opacity = previousBackground.opacity
    m.background.translation = previousBackground.translation
    m.background.width = previousBackground.width
    m.background.height = previousBackground.height
    m.background.uri = m.top.backgroundUri

    previousBackground.visible = false

  end if

end sub

' =============================================================================
' onBackgroundOpacityChange
' =============================================================================

sub onBackgroundOpacityChange()

  print "LoadingIndicator.brs - [onBackgroundOpacityChange]"

  if m.background <> invalid
    m.background.opacity = m.top.backgroundOpacity
  end if

end sub

' =============================================================================
' onTextPaddingChange
' =============================================================================

sub onTextPaddingChange()

  print "LoadingIndicator.brs - [onTextPaddingChange]"

  if m.top.textPadding > 0
    m.textPadding = m.top.textPadding
  else
    m.textPadding = 0
  end if

  updateLayout()

end sub

' =============================================================================
' onControlChange
' =============================================================================

sub onControlChange()

  print "LoadingIndicator.brs - [onControlChange]"

  if m.top.control = "start"

    ' Opacity could be set to 0 by fade animation so restore it

    m.loadingIndicatorGroup.opacity = 1

    startAnimation()

  else if m.top.control = "stop"

    ' If there is fadeInterval set, fully dispose component before stopping spinning animation

    if m.top.fadeInterval > 0
      m.fadeAnimation.duration = m.top.fadeInterval
      m.fadeAnimation.observeField("state", "onFadeAnimationStateChange")
      m.fadeAnimation.control = "start"
    else
      stopAnimation()
    end if

  end if

end sub

' =============================================================================
' onFadeAnimationStateChange - Called when onControlChange() wants to stop an
'                              animation but needs to wait until the active
'                              fade animation completes.
' =============================================================================

sub onFadeAnimationStateChange()

  print "LoadingIndicator.brs - [onFadeAnimationStateChange]"

  if m.fadeAnimation.state = "stopped"
    stopAnimation()
  end if

end sub

' =============================================================================
' startAnimation
' =============================================================================

sub startAnimation()

  print "LoadingIndicator.brs - [startAnimation]"

  ' Don't start animation on devices that don't support it

  m.model = createObject("roDeviceInfo").getModel()
  
  'Get the first character of the model number. Anything less than a 4 corresponds to a device not suited to animations.

  first = Left(m.model, 1).trim()

  if first <> invalid and first.Len() = 1

    firstAsInt = val(first, 10)

    if (firstAsInt) > 3
      m.rotationAnimation.control = "start"
      m.top.state = "running"
    end if

  end if

end sub

' =============================================================================
' stopAnimation
' =============================================================================

sub stopAnimation()

  print "LoadingIndicator.brs - [stopAnimation]"

  m.rotationAnimation.control = "stop"
  m.top.state = "stopped"

end sub

' =============================================================================
' max
' =============================================================================

function max(a as Float, b as Float) as Float

  print "LoadingIndicator.brs - [max]"

  if a > b
    return a
  else
    return b
  end if

end function
