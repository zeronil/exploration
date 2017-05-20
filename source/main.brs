' =============================================================================
' Main - First function called when channel application starts
' =============================================================================

sub Main(input as Dynamic)

  print "################"
  print "Start of Channel"
  print "################"

  ' Add deep linking support here. Input is an associative array containing
  ' parameters that the client defines. Examples include "options, contentID, etc."
  ' See guide here: https://sdkdocs.roku.com/display/sdkdoc/External+Control+Guide
  ' For example, if a user clicks on an ad for a movie that your app provides,
  ' you will have mapped that movie to a contentID and you can parse that ID
  ' out from the input parameter here.
  ' Call the service provider API to look up
  ' the content details, or right data from feed for id

  if input <> invalid

    print "main.brs - [Main] Received Input (write code here to check it!)"

    if input.reason <> invalid

      print "main.brs - [Main] Input reason: " + input.reason

      if input.reason = "ad" then
        print "main.brs - [Main] Channel launched from ad (do ad stuff here)"
      end if

    end if

    if input.contentID <> invalid
      m.contentID = input.contentID
      print "main.brs - [Main] Launch/prep content for contentID: " + input.contentID
    end if

  end if

  showHeroScene()

end sub

' =============================================================================
' showHeroScene - Creates the screen and initializes the scene, then shows the
'                 main homepage. Also handles closing of the channel.
' =============================================================================

sub showHeroScene()

  print "main.brs - [showHeroScene]"

  ' The roSGScreen object is a Scene Graph canvas that displays the contents of a Scene Graph Scene node tree

  screen = CreateObject("roSGScreen")
  m.port = CreateObject("roMessagePort")
  screen.setMessagePort(m.port)

  ' CreateScene() takes one argument, the name of the Scene component to create.
  ' Channels will typically extend Scene with their own application specific Scene type, such as MyScene.

  scene = screen.CreateScene("HeroScene")
  screen.show()

  while(true)

    msg = wait(0, m.port)
    msgType = type(msg)

    if msgType = "roSGScreenEvent"
      if msg.isScreenClosed() then return
    end if

  end while

end sub
