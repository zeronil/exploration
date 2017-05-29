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
  m.detailsOverhang = m.top.findNode("detailsOverhang")
  m.overhangBackground = m.top.findNode("overhangBackground")
  m.hudRectangle = m.top.findNode("HUDRectangle")
  m.backgroundPoster = m.top.findNode("backgroundPoster")
  m.background2Poster = m.top.findNode("background2Poster")
  m.backgroundPosterAnimation = m.top.findNode("backgroundPosterParallelAnimation")
  m.fadeInBackgroundGroup = m.top.findNode("fadeInBackgroundGroup")
  m.fadeOutBackgroundGroup = m.top.findNode("fadeOutBackgroundGroup")

  ' Create buttons

  result = []

  for each button in ["Play", "Data"]
  result.push({title: button})
  end for

  m.buttons.content = contentList2SimpleNode(result)

end function

' =============================================================================
' onKeyEvent - Called when a key on the remote is pressed
' =============================================================================

function onKeyEvent(key as String, isPressed as Boolean) as Boolean

  print "DetailsScreen.brs - [onKeyEvent] key = "; key; ", isPressed = "; isPressed

  isKeyEventHandled = false

  ' There doesn't seem to be a way to disable the "Options" in the Overhang in "HeroScene",
  ' so if the options button is pressed, set the flag that the key has been handled so that
  ' it doesn't propagate to "HeroScene"

  if key = "options" then
    isKeyEventHandled = true
  end if

  return isKeyEventHandled

end function

' =============================================================================
' onVisibleChange
' =============================================================================

sub onVisibleChange()

  ' If entering Details screen, set the focus to the first button

  if m.top.visible

    print "DetailsScreen.brs - [onVisibleChange] Set up DetailsScreen"

    ' Focus first button

    m.buttons.jumpToItem = 0
    m.buttons.setFocus(true)

    ' Set the color of the button (focused)

    m.buttons.focusBitmapBlendColor = m.global.keyColorTint

    ' Set the color of the Overhang and the H.U.D. area at the bottom to the global keyColor

    m.overhangBackground.color = m.global.keyColor
    m.hudRectangle.color = m.global.keyColor

    ' Start the animation of the background images

    m.backgroundPoster.opacity = "0.0"
    m.background2Poster.opacity = "0.2"
    m.fadeInBackgroundGroup.control = "start"
    m.backgroundPosterAnimation.control = "start"

  ' Else exiting DetailsScreen

  else

    print "DetailsScreen.brs - [onVisibleChange] Tear down DetailsScreen"

    ' Begin to fade out the DetailsScreen

    m.fadeOutBackgroundGroup.control = "start"

    ' Stop the animation of the background images

    m.backgroundPosterAnimation.control = "stop"

    ' Make sure the Video component is not playing a video and is not visible

    m.videoPlayer.visible = false
    m.videoPlayer.control = "stop"

    ' Remove the Poster images

    m.poster.uri = ""
    m.backgroundPoster.uri = ""
    m.background2Poster.uri = ""

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

  print "DetailsScreen.brs - [onVideoVisibleChange]"

  if m.videoPlayer.visible = false and m.top.visible = true

    ' Make sure the buttons have the focus

    m.buttons.setFocus(true)

    ' Make sure the Video component is not playing a video

    m.videoPlayer.control = "stop"

    ' Re-start the background image animation

    m.backgroundPosterAnimation.control = "start"

  end if

end sub

' =============================================================================
' onItemSelected - Button press handler
' =============================================================================

sub onItemSelected()

  print "DetailsScreen.brs - [onItemSelected] button = " m.top.itemSelected

  ' First button in the list is Play

  if m.top.itemSelected = 0

    ' Stop the background image animation

    m.backgroundPosterAnimation.control = "stop"

    ' Make the Video component visible and begin playback

    m.videoPlayer.visible = true
    m.videoPlayer.setFocus(true)
    m.videoPlayer.control = "play"

    ' Watch for changes to the state of the Video component (e.g., video playback stopped)

    m.videoPlayer.observeField("state", "onVideoPlayerStateChange")

  end if

end sub

' =============================================================================
' onVideoPlayerStateChange - Event handler for Video player message
' =============================================================================

sub onVideoPlayerStateChange()

  print "DetailsScreen.brs - [onVideoPlayerStateChange] " m.videoPlayer.state

  'Error handling

  if m.videoPlayer.state = "error" then

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

  ' Set the Overhang title to the name of the selected media (if available)

  if m.top.content.title <> invalid and Len(m.top.content.title) > 0 then
    m.detailsOverhang.title = m.top.content.title
  else
    m.detailsOverhang = "Exploration"
  end if

  ' Initialize the Description component that present information about the selected media item

  m.description.content = m.top.content
  m.description.Description.width = "1120"

  ' Assign the selected media content to the Video component

  m.videoPlayer.content = m.top.content

  ' Initialize the Poster images with the URI of the the content's background image

  m.poster.uri = m.top.content.hdBackgroundImageUrl
  m.backgroundPoster.uri = m.top.content.hdBackgroundImageUrl
  m.background2Poster.uri = m.top.content.hdBackgroundImageUrl

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
