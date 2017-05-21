' =============================================================================
' select - Helper function to select only a certain range of content
' =============================================================================

function select(array as object, first as integer, last as integer) as object

  print "UriHandler.brs - [select]"

  result = []

  for i = first to last
    result.push(array[i])
  end for

  return result

end function

' =============================================================================
' addAndSetFields - Helper function to add and set fields of a content node
' =============================================================================

function addAndSetFields(node as object, associativeArray as object)

  'This gets called for every content node -- commented out since it's pretty verbose
  'print "UriHandler.brs - [AddAndSetFields]"

  fieldsToAdd = {}
  fieldsToSet = {}

  for each field in associativeArray

    if node.hasField(field)
      fieldsToSet[field] = associativeArray[field]
    else
      fieldsToAdd[field] = associativeArray[field]
    end if

  end for

  node.setFields(fieldsToSet)
  node.addFields(fieldsToAdd)

end function
