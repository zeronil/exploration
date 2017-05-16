' =============================================================================
' init - First function that runs for the scene on channel startup
'        Note that the child nodes in HeroScene.xml will be constructed
'        BEFORE the init() function below is run (and init functions for
'        the HeroScene child components will be called, etc.).
' =============================================================================

sub init()

  ' To see print statements/debug info, telnet on port 8089

  print "HeroScene.brs - [init]"

  ' HeroScreen Node with RowList

  m.HeroScreen = m.top.FindNode("HeroScreen")

  ' Overhang Node

  m.OverhangBar = m.top.FindNode("OverhangBar")

  ' OptionsScreen node

  m.OptionsScreen = m.top.FindNode("OptionsScreen")

  ' DetailsScreen node with description & video player

  m.DetailsScreen = m.top.FindNode("DetailsScreen")

  ' The spinning wheel node

  m.LoadingIndicator = m.top.findNode("LoadingIndicator")

  ' Dialog box node. Appears if content can't be loaded

  m.WarningDialog = m.top.findNode("WarningDialog")

  ' Transitions between screens

  m.FadeInOptions = m.top.findNode("FadeInOptions")
  m.FadeOutOptions = m.top.findNode("FadeOutOptions")
  m.FadeInDetails = m.top.findNode("FadeInDetails")
  m.FadeOutDetails = m.top.findNode("FadeOutDetails")

  ' Set focus to the scene

  m.top.setFocus(true)

end sub

' =============================================================================
' onHeroContentChange - Hero RowList Content handler function.
'                       When content for HeroScreen is set (see content interface field), stops
'                       the loadingIndicator and focuses on HeroScreen.
' =============================================================================

sub onHeroContentChange()

  print "HeroScene.brs - [onHeroContentChange]"

  m.loadingIndicator.control = "stop"

  ' If content to display is available

  if m.top.content <> invalid

    ' Warn the user if there was a bad request (numBadRequests from UrlHandler propagated through HeroScreen)

    if m.top.numBadRequests > 0
      m.HeroScreen.visible = "true"
      m.WarningDialog.visible = "true"
      m.WarningDialog.message = (m.top.numBadRequests).toStr() + " request(s) for content failed. Press '*' or OK or '<-' to continue."
    else
      m.HeroScreen.visible = "true"
      m.HeroScreen.setFocus(true)
    end if

  ' Display warning if content for the HeroScreen RowList was not loaded
  ' (the default message is pre-defined in the XML)

  else
    m.WarningDialog.visible = "true"
  end if

end sub

' =============================================================================
' onHeroRowItemSelected - Row item selected handler function
'                         (see rowItemSelected interface field propagated through HeroScreen).
'                         On select any item on home scene, show Details node and hide Grid.
' =============================================================================

sub onHeroRowItemSelected()

  print "HeroScene.brs - [onHeroRowItemSelected]"

  m.FadeInDetails.control = "start"
  m.HeroScreen.visible = "false"
  m.DetailsScreen.content = m.HeroScreen.focusedContent
  m.DetailsScreen.setFocus(true)
  m.DetailsScreen.visible = "true"

end sub

' =============================================================================
' onKeyEvent - Called when a key on the remote is pressed
' =============================================================================

function onKeyEvent(key as String, isPressed as Boolean) as Boolean

  print "HeroScene.brs - [onKeyEvent] key = "; key; ", isPressed = "; isPressed

  isKeyEventHandled = false

  if isPressed then

    ' -------------
    ' BACK KEY
    ' -------------

    if key = "back"

      print "HeroScene.brs - [onKeyEvent] BACK key pressed"

      ' If WarningDialog is open then remove and make HeroScreen visible

      if m.WarningDialog.visible = true
        print "HeroScene.brs - [onKeyEvent] Remove warning"
        m.WarningDialog.visible = "false"
        m.HeroScreen.setFocus(true)
        isKeyEventHandled = true

      ' If OptionsScreen is displayed, then make HeroScreen visible 

      else if m.OptionsScreen.visible = true
        print "HeroScene.brs - [onKeyEvent] Fade out options"
        m.OverhangBar.color = "0x333333FF"
        m.FadeOutOptions.control = "start"
        m.OptionsScreen.visible = "false"
        m.HeroScreen.setFocus(true)
        m.HeroScreen.visible = "true"
        isKeyEventHandled = true

      ' If Details open and video player opened, then remove the video player

      else if m.HeroScreen.visible = false and m.DetailsScreen.videoPlayerVisible = true
        print "HeroScene.brs - [onKeyEvent] Remove video player"
        m.DetailsScreen.videoPlayerVisible = false
        isKeyEventHandled = true

      ' If Details opened then need to transition to HeroScreen

      else if m.HeroScreen.visible = false and m.DetailsScreen.videoPlayerVisible = false
        print "HeroScene.brs - [onKeyEvent] Fade out details"
        m.FadeOutDetails.control = "start"
        m.HeroScreen.visible = "true"
        m.DetailsScreen.visible = "false"
        m.HeroScreen.setFocus(true)
        isKeyEventHandled = true

      end if

    ' -------------
    ' OK KEY
    ' -------------

    else if key = "OK"

      print "HeroScene.brs - [onKeyEvent] OK key pressed"

      ' If WarningDialog is open then remove and make HeroScreen visible

      if m.WarningDialog.visible = true
        m.WarningDialog.visible = "false"
        m.HeroScreen.setFocus(true)
      end if

    ' -------------
    ' OPTIONS KEY
    ' -------------

    else if key = "options"

      ' If WarningDialog is open then remove and make HeroScreen visible

      if m.WarningDialog.visible = true
        print "HeroScene.brs - [onKeyEvent] OPTIONS key pressed - hide warning"
        m.WarningDialog.visible = "false"
        m.HeroScreen.setFocus(true)

      ' Else make the OptionsScreen visible

      else
        print "HeroScene.brs - [onKeyEvent] OPTIONS key pressed - Fade in options"
        m.FadeInOptions.control = "start"
        m.HeroScreen.visible = "false"
        m.OptionsScreen.setFocus(true)
        m.OptionsScreen.visible = "true"
        isKeyEventHandled = true

      endif

    end if

  end if

  return isKeyEventHandled

end function
