 ' =============================================================================
 ' init - Set top interfaces
 ' =============================================================================

sub init()

  print "DataPanel.brs - [init]"

  m.top.isFullScreen  = "true"
  m.top.panelSize = "true"

  m.metadataLayoutGroup = m.top.findNode("metadataLayoutGroup")
  m.maskAnimation = m.top.findNode("maskAnimation")

end sub

' =============================================================================
' onContentChange
' =============================================================================

sub onContentChange()

  print "DataPanel.brs - [onContentChange]"

  metadata = m.top.content

  if metadata <> invalid and m.metadataLayoutGroup <> invalid then

    print "DataPanel.brs - [onContentChange] Assign metadata"

    if m.metadataLayoutGroup.getChildCount() > 0 then
      m.metadataLayoutGroup.removeChildrenIndex(m.metadataLayoutGroup.getChildCount(), 0)
    end if

    for each item in metadata

      dataItem = createObject("roSGNode", "DataPanelItem")
      dataItem.label = item
      dataItem.value = metadata[item]

      m.metadataLayoutGroup.appendChild(dataItem)

    end for

  end if

end sub

' =============================================================================
' onVisibleChange
' =============================================================================

sub onAnimationChange()

  print "DataPanel.brs - [onAnimationChange] " m.top.animationControl

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
