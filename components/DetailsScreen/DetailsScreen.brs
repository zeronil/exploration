' ********** Copyright 2016 Roku Corp.  All Rights Reserved. **********

 ' =============================================================================
 ' init - Initializes the Details screen, sets all observers and configures buttons for Details screen
 ' =============================================================================

function init()

  print "DetailsScreen.brs - [init]"

  m.top.observeField("visible", "onVisibleChange")
  m.top.observeField("focusedChild", "onFocusedChildChange")

  m.buttons = m.top.findNode("Buttons")
  m.videoPlayer = m.top.findNode("VideoPlayer")
  m.poster = m.top.findNode("Poster")
  m.description = m.top.findNode("Description")
  m.background = m.top.findNode("Background")
  m.fadeIn = m.top.findNode("fadeinAnimation")
  m.fadeOut = m.top.findNode("fadeoutAnimation")

  ' Create buttons

  result = []

  for each button in ["Play", "Second button"]
    result.push({title : button})
  end for

  m.buttons.content = contentList2SimpleNode(result)

end function

' =============================================================================
' onVisibleChange
' =============================================================================

sub onVisibleChange()

  ' If entering Details screen, set the focus to the first button

  if m.top.visible

    print "DetailsScreen.brs - [onVisibleChange] Focus first button"

    m.fadeIn.control="start"
    m.buttons.jumpToItem = 0
    m.buttons.setFocus(true)

  ' Else exiting video, so stop the video playback

  else

    print "DetailsScreen.brs - [onVisibleChange] Stop video playback"

    m.fadeOut.control="start"

    m.videoPlayer.visible = false
    m.videoPlayer.control = "stop"

    m.poster.uri=""
    m.background.uri=""

  end if

end sub

' =============================================================================
' onFocusedChildChange - Set focus to Buttons when returning from Video PLayer
' =============================================================================

sub onFocusedChildChange()

  print "DetailsScreen.brs - [onFocusedChildChange]"

  if m.top.isInFocusChain() and not m.buttons.hasFocus() and not m.videoPlayer.hasFocus() then
    m.buttons.setFocus(true)
  end if

end sub

' =============================================================================
' onVideoVisibleChange - Set focus to buttons and stop video if returning to Details from Playback
' =============================================================================

sub onVideoVisibleChange()

  print "DetailsScreen.brs - [onVideoVisibleChange] Set button focus and stop video playback (end)"

  if m.videoPlayer.visible = false and m.top.visible = true
    m.buttons.setFocus(true)
    m.videoPlayer.control = "stop"

  end if

end sub

' =============================================================================
' onItemSelected - Button press handler
' =============================================================================

sub onItemSelected()

  print "DetailsScreen.brs - [onItemSelected]"

  ' First button in the list is Play

  if m.top.itemSelected = 0
    m.videoPlayer.visible = true
    m.videoPlayer.setFocus(true)
    m.videoPlayer.control = "play"
    m.videoPlayer.observeField("state", "onVideoPlayerStateChange")
  end if

end sub

' =============================================================================
' onVideoPlayerStateChange - Event handler for Video player message
' =============================================================================

sub onVideoPlayerStateChange()

  print "DetailsScreen.brs - [onVideoPlayerStateChange] " m.videoPlayer.state

  'Error handling

  if m.videoPlayer.state = "error"
    m.videoPlayer.visible = false

  ' Active playback handling

  else if m.videoPlayer.state = "playing"

  ' Playback complete handling

  else if m.videoPlayer.state = "finished"
    m.videoPlayer.visible = false

  end if

end sub

' =============================================================================
' onContentChange
' =============================================================================

sub onContentChange()

  print "DetailsScreen.brs - [onContentChange]"

  m.description.content = m.top.content
  m.description.Description.width = "1120"
  m.videoPlayer.content = m.top.content
  m.top.streamUrl  = m.top.content.url
  m.poster.uri = m.top.content.hdBackgroundImageUrl
  m.background.uri = m.top.content.hdBackgroundImageUrl

end sub

' =============================================================================
' contentList2SimpleNode - Helper function convert AA to Node
' =============================================================================

function contentList2SimpleNode(contentList as Object, nodeType = "ContentNode" as String) as Object

  print "DetailsScreen.brs - [contentList2SimpleNode]"

  result = createObject("roSGNode", nodeType)

  if result <> invalid

    for each itemAA in contentList
      item = createObject("roSGNode", nodeType)
      item.setFields(itemAA)
      result.appendChild(item)
    end for

  end if

  return result

end function
