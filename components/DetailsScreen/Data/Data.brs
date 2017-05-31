 ' =============================================================================
 ' init - Set top interfaces
 ' =============================================================================

sub init()

  print "Data.brs - [init]"

  m.top.isFullScreen  = "true"
  m.top.panelSize = "true"

  ' m.top.observeField("visible", "onVisibleChange")

  m.maskAnimation = m.top.findNode("maskAnimation")
  m.maskAnimation = m.top.findNode("maskAnimation")

end sub

' =============================================================================
' onVisibleChange
' =============================================================================

sub onAnimationChange()

  print "Data.brs - [onAnimationChange] " m.top.animationControl

  if m.top.animationControl = "start" then

    if m.maskAnimation <> invalid
      m.maskAnimation.control = "start"
    end if

  else

    if m.maskAnimation <> invalid
      m.maskAnimation.control = "stop"
    end if

  end if

end sub
