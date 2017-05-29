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

  ' Overhang

  m.OverhangBar = m.top.findNode("OverhangBar")
  m.OverhangBackground = m.top.FindNode("OverhangBackground")
  m.OverhangFadeInColor = m.top.findNode("OverhangFadeInColorInterp")
  m.OverhangBackgroundGray = m.top.findNode("OverhangBackgroundGray")

  ' OptionsScreen node

  m.OptionsScreen = m.top.FindNode("OptionsScreen")
  m.OptionsScreen.observeField("selectedColor", "onOverhangColorChange")

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

  ' Read registry setting for initial background color of Overhang

  readSetting("overhangBackgroundColorIndex")

end sub

' =============================================================================
' onOverhangColorChange - Called when "selectedColor" on OptionsScreen changes
' =============================================================================

sub onOverhangColorChange()

  print "HeroScene.brs - [onOverhangColorChange] index = " m.OptionsScreen.itemSelected ", color = " m.OptionsScreen.selectedColor

  if (m.OptionsScreen.selectedColor <> invalid)
    m.OverhangBackground.color = m.OptionsScreen.selectedColor
    writeSetting("overhangBackgroundColorIndex",StrI(m.OptionsScreen.itemSelected))
  end if

  fadeOutOptionsScreen()

end sub

' =============================================================================
' readSetting - Read a setting from the registry
' =============================================================================

sub readSetting(settingName as String)

    print "HeroScene.brs - [readSetting] " settingName

    m.readSettingTask = createObject("roSGNode", "SettingTask")
    m.readSettingTask.settingName = settingName
    m.readSettingTask.observeField("settingValueRead", "onReadSettingComplete")
    m.readSettingTask.control = "RUN"

end sub

' =============================================================================
' onReadSettingComplete - Called when SettingTask completes reading the
'                         setting value from the registry.
' =============================================================================

sub onReadSettingComplete()

  print "HeroScene.brs - [onReadSettingComplete] " m.readSettingTask.settingName " = " m.readSettingTask.settingValueRead

  ' Overhang color setting - The value that is read is the index for the list item on OptionsScreen

  if m.readSettingTask.settingName = "overhangBackgroundColorIndex"

    ' If a setting value was read, select and set the checkmark for the item on the OptionsScreen.
    ' If a value was not read, default to the first item in the list.

    if m.readSettingTask.settingValueRead <> invalid
      m.OptionsScreen.itemSelected = StrToI(m.readSettingTask.settingValueRead)
      m.OptionsScreen.itemChecked = StrToI(m.readSettingTask.settingValueRead)
    else
      m.OptionsScreen.itemChecked = 0
    end if

  end if

end sub

' =============================================================================
' writeSetting - Write a setting to the registry
' =============================================================================

sub writeSetting(settingName As String, settingValue as String)

    print "HeroScene.brs - [writeSetting] " settingName " = " settingValue

    m.writeSettingTask = createObject("roSGNode", "SettingTask")
    m.writeSettingTask.settingName = settingName
    m.writeSettingTask.settingValue = settingValue
    m.writeSettingTask.observeField("settingWriteSuccess", "onWriteSettingComplete")
    m.writeSettingTask.control = "RUN"

end sub

' =============================================================================
' onWriteSettingComplete - Write a setting to the registry
' =============================================================================

sub onWriteSettingComplete()
  print "HeroScene.brs - [onWriteSettingComplete] Success = " m.writeSettingTask.settingWriteSuccess
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
      m.HeroScreen.visible = true
      m.WarningDialog.visible = true
      m.WarningDialog.message = (m.top.numBadRequests).toStr() + " request(s) for content failed. Press '*' or OK or '<-' to continue."
    else
      m.HeroScreen.visible = true
      m.HeroScreen.setFocus(true)
    end if

  ' Display warning if content for the HeroScreen RowList was not loaded
  ' (the default message is pre-defined in the XML)

  else
    m.WarningDialog.visible = true
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

  m.HeroScreen.visible = false

  m.DetailsScreen.content = m.HeroScreen.focusedContent
  m.DetailsScreen.setFocus(true)
  m.DetailsScreen.visible = true

  ' Since the Overhang in DetailsScreen is translucent, make the OverhangBar invisible so that 
  ' it is not seen behind DetailsScreen

  m.OverhangBar.visible = false

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

    if key = "back" then

      print "HeroScene.brs - [onKeyEvent] BACK key pressed"

      ' If WarningDialog is open then remove and make HeroScreen visible

      if m.WarningDialog.visible = true then
        print "HeroScene.brs - [onKeyEvent] Remove warning"
        m.WarningDialog.visible = false
        m.HeroScreen.setFocus(true)
        isKeyEventHandled = true

      ' If OptionsScreen is displayed, then make HeroScreen visible

      else if m.OptionsScreen.visible = true then
        print "HeroScene.brs - [onKeyEvent] Fade out options"
        fadeOutOptionsScreen()
        isKeyEventHandled = true

      ' If Details open and video player opened, then remove the video player

      else if m.HeroScreen.visible = false and m.DetailsScreen.videoPlayerVisible = true then
        print "HeroScene.brs - [onKeyEvent] Remove video player"
        m.DetailsScreen.videoPlayerVisible = false
        isKeyEventHandled = true

      ' If Details opened then need to transition to HeroScreen

      else if m.HeroScreen.visible = false and m.DetailsScreen.videoPlayerVisible = false then

        print "HeroScene.brs - [onKeyEvent] Fade out details"

        ' Since the Overhang in DetailsScreen is translucent, OverhangBar was made invisible so that
        ' it is not seen

        m.OverhangBar.visible = true
        m.DetailsScreen.visible = false

        m.FadeOutDetails.control = "start"

        m.HeroScreen.visible = true
        m.HeroScreen.setFocus(true)

        isKeyEventHandled = true

      end if

    ' -------------
    ' OK KEY
    ' -------------

    else if key = "OK" then

      print "HeroScene.brs - [onKeyEvent] OK key pressed"

      ' If WarningDialog is open then remove and focus the HeroScreen

      if m.WarningDialog.visible = true then
        m.WarningDialog.visible = false
        m.HeroScreen.setFocus(true)
      end if

    ' -------------
    ' OPTIONS KEY
    ' -------------

    else if key = "options" then

      ' If WarningDialog is open then remove and make HeroScreen visible

      if m.WarningDialog.visible = true then
        print "HeroScene.brs - [onKeyEvent] OPTIONS key pressed - hide warning"
        m.WarningDialog.visible = false
        m.HeroScreen.setFocus(true)

      ' Else make the OptionsScreen visible

      else if m.OptionsScreen.visible = false then

        print "HeroScene.brs - [onKeyEvent] OPTIONS key pressed - Fade in options"

        m.FadeInOptions.control = "start"

        m.HeroScreen.visible = false

        m.OptionsScreen.visible = true
        m.OptionsScreen.setFocus(true)

        m.OverhangBackgroundGray.opacity = 1.0

        isKeyEventHandled = true

      endif

    end if

  end if

  return isKeyEventHandled

end function

' =============================================================================
' fadeOutOptionsScreen
' =============================================================================

sub fadeOutOptionsScreen()

  print "HeroScene.brs - [fadeOutOptionsScreen]"

  m.FadeOutOptions.control = "start"
  m.OptionsScreen.visible = false
  m.HeroScreen.setFocus(true)
  m.HeroScreen.visible = true

end sub
