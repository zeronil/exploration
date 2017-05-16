' ********** Copyright 2016 Roku Corp.  All Rights Reserved. **********

 ' =============================================================================
 ' init - Set top interfaces
 ' =============================================================================

sub init()

  print "Description.brs - [init]"

  m.top.Title  = m.top.findNode("Title")
  m.top.Description = m.top.findNode("Description")
  m.top.ReleaseDate = m.top.findNode("ReleaseDate")

end sub

' =============================================================================
' onContentChanged
' =============================================================================

sub onContentChanged()

  print "Description.brs - [onContentChanged]"

  item = m.top.content

  ' TITLE

  title = item.title.toStr()

  if title <> invalid then
    m.top.Title.text = title.toStr()
  end if

  ' DESCRIPTION

  value = item.description

  if value <> invalid then

    if value.toStr() <> "" then
      m.top.Description.text = value.toStr()
    else
      m.top.Description.text = "No description"
    end if

  end if

  ' RELEASE DATE

  value = item.ReleaseDate

  if value <> invalid then

    if value <> ""
      m.top.ReleaseDate.text = value.toStr()
    else
      m.top.ReleaseDate.text = "No Release Date"
    end if

  end if

end sub
