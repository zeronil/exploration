 ' =============================================================================
 ' init - Set top interfaces
 ' =============================================================================

sub init()

  print "description.brs - [init]"

  m.titleGroup  = m.top.findNode("titleGroup")
  m.titleShadow  = m.top.findNode("titleShadow")

  m.top.title  = m.top.findNode("title")
  m.top.releaseDate = m.top.findNode("releaseDate")
  m.top.description = m.top.findNode("description")

end sub

' =============================================================================
' onContentChanged
' =============================================================================

sub onContentChanged()

  print "description.brs - [onContentChanged]"

  item = m.top.content

  ' Title - Display title text (with a shadow) if title text is available

  value = item.title.toStr()
  ' value = invalid

  if value <> invalid and value.toStr().Len() > 0 then
    m.top.title.text = value.toStr()
    m.titleShadow.text = value.toStr()
    m.titleGroup.visible = true
    hasTitle = true
  else
    hasTitle = false
    m.titleGroup.visible = false
  end if

  ' Release Date - Display the release date if a release date is available

  value = item.pubDate
  ' value = invalid

  if value <> invalid and value.toStr().Len() > 0 then

    hasReleaseDate = true
    m.top.releaseDate.visible = true

    ' The date string is GMT, so split the string to seperate the time (e.g., 12:00:00 GMT)
    ' from the date

    regex = CreateObject("roRegex", "\s\d\d:", "")
    splitAtTime = regex.split(value.toStr())

    if splitAtTime.Count() = 2 then
      m.top.releaseDate.text = splitAtTime[0]
    else
      m.top.releaseDate.text = value.toStr()
    end if

  end if

  ' Description - Display content description if description text is available

  value = item.description

  if value <> invalid and value.toStr().Len() > 0 then
      m.top.description.text = value.toStr()
      m.top.description.visible = true
  else
    m.top.description.visible = false
  end if

  ' Format the three sections vertically ("title", "releaseDate" and "description") based on what
  ' data is available for the item

  if hasTitle and hasReleaseDate then
    m.top.itemSpacings = "[15.0]"
  else if hasTitle then
    m.top.itemSpacings = "[-20.0, 15]"
  else
    m.top.itemSpacings = "[-35.0]"
  end if

end sub
