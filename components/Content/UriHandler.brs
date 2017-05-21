' ********** Copyright 2016 Roku Corp.  All Rights Reserved. **********

' A context node has a parameters and response field
' - parameters corresponds to everything related to an HTTP request
' - response corresponds to everything related to an HTTP response
'
' Component Variables:
'   m.port: the UriFetcher message port
'   m.jobsById: an AA containing a history of HTTP requests/responses

' =============================================================================
' init - UriFetcher constructor
'        Sets the execution function for the UriFetcher and tells the UriFetcher to run
' =============================================================================

sub init()

  print "UriHandler.brs - [init]"

  ' Fields for checking if content has been loaded.
  ' Each row is assumed to be a different request for a rss feed

  m.top.numRowsReceived = 0
  m.top.numBadRequests = 0
  m.top.contentSet = false

  ' Stores the content if not all requests are ready

  m.top.contentCache = createObject("roSGNode", "ContentNode")

  ' Setting callbacks for url request and response.
  ' Specifying a message port instead of a function sends an roSGNodeEvent message to the
  ' port (roMessagePort) when the observed field changes value.

  m.port = createObject("roMessagePort")

  m.top.observeField("request", m.port)
  m.top.observeField("contentCache", m.port)

  ' Setting the task thread function

  m.top.functionName = "go"
  m.top.control = "RUN"

end sub

' =============================================================================
' go - The "Task" function has an event loop which calls the appropriate
'      functions for handling requests made by the HeroScreen and responses
'      when requests are finished
'
'      Variables:
'         m.jobsById: AA storing HTTP transactions where:
'	                    key: id of HTTP request
'                     val: an AA containing:
'                          key: context
'                          val: a node containing request info
'                          key: xfer
'                          val: the roUrlTransfer object'
'
' =============================================================================

sub go()

  print "UriHandler.brs - [go]"

  ' Holds requests by id

  m.jobsById = {}

	' The event loop waits for requests ("request") and for the results from completed requests ("contentCache")

  while true

    message = wait(0, m.port)
    messageType = type(message)

    ' If a request was made, running GetField() on the message gets the name of the field that changed,
    ' and running GetData() on the message gets the new field value at the time of the change.

    if messageType = "roSGNodeEvent" then

      messageField = message.getField()

      print "UriHandler.brs - [go] Received event type '"; messageType; "' with field '"; messageField; "'"

      ' New request received

      if messageField = "request" then

        if addRequest(message.getData()) <> true then print "Invalid request"

      ' Content for a successful request has been parsed by Parser

      else if messageField = "contentCache" then

        updateContent()

      else

        print "UriHandler.brs - [go] Error: unrecognized field '"; messageField ; "'"

      end if

    ' If a response was received from the roUrlTransfer.AsyncGetToString call
    ' (initiated by addRequest()), then process the reponse.

    else if messageType = "roUrlEvent" then

      processResponse(message)

    ' Handle unexpected cases

    else
  	  print "UriHandler.brs - [go] Error: unrecognized event type '"; messageType ; "'"
    end if

  end while

end sub

' =============================================================================
' addRequest - Makes the HTTP request
'
'              Parameters:
'	                request: an associative array containing the request params/context
'
'              Variables:
'                 m.jobsById: used to store a history of HTTP requests
'
'              Return value:
'                 True if request succeeds
'              	  False if invalid request
'
' =============================================================================

function addRequest(request as Object) as Boolean

  ' A request must be an associative array with a context property and a parser property.

  if type(request) = "roAssociativeArray" then

  ' The context will have the request parameters, which includes the "uri", the "format"
  ' (the format determines how the results will be displayed) and the row/grid "title".

    context = request.context

    parser = request.parser
    requestNumber = context.num + 1

    print "UriHandler.brs - [addRequest] Request number" requestNumber " of" m.top.numRows

    ' Create a Parser node if one has not previously been created

    if type(parser) = "roString" then

      ' Create the parser and watch for the parsed result to be set

      if m.Parser = invalid then

        m.Parser = createObject("roSGNode", parser)
        m.Parser.observeField("parsedContent", m.port)

      else

        print "UriHandler.brs - [addRequest] Parser already created"

      end if

    else

      print "UriHandler.brs - [addRequest] Error: Incorrect type for Parser: " ; type(parser)
      return false

    end if

    ' The request's context is always a "roSGNode" (to which fields are added by the requester)

    if type(context) = "roSGNode"

      ' The context's "parameters" property value is an associative array with the following properties:
      '   - uri: address of the content to load
      '   - format: how the data should be formatted ("row" or "grid")
      '   - title: The title to be displayed for the row or grid

      parameters = context.parameters

      if type(parameters) = "roAssociativeArray" then

        ' Get the URI for the content to load

        uri = parameters.uri

        if type(uri) = "roString" then

          urlXfer = createObject("roUrlTransfer")
          urlXfer.setUrl(uri)
          urlXfer.setPort(m.port)

          ' Get a unique number for the urlXfer object that can be used to identify whether events originated from this object
          ' (note that the integer is converted to a string for the idKey).

          idKey = stri(urlXfer.getIdentity()).trim()

          ' Start a GET request to a server, but do not wait for the transfer to complete.
          ' When the GET completes, a roUrlEvent will be sent to the message port and processed by the event loop in the "go" function above.
          ' The event will contain the response data which will be sent to the parser by the "processResponse" function below.
          ' If false is returned then the request could not be issued and no events will be delivered.

          ok = urlXfer.AsyncGetToString()

          ' Save data about the transfer job using the roUrlTransfer object's unique ID.
          ' The data consists of the original request object ("context") and the request's roUrlTransfer object ("xfer").

          if ok then
            m.jobsById[idKey] = {context: request, xfer: urlXfer}
          else
            print "UriHandler.brs - [addRequest] Error: request couldn't be issued"
          end if

  		    print "UriHandler.brs - [addRequest] Initiating transfer '"; idkey; "' for URI '"; uri; "'"; " succeeded: "; ok

        else
          print "UriHandler.brs - [addRequest] Error: invalid uri: "; uri
          m.top.numBadRequests++
  			end if

      else
        print "UriHandler.brs - [addRequest] Error: parameters is the wrong type: " + type(parameters)
        return false
      end if

  	else
      print "UriHandler.brs - [addRequest] Error: context is the wrong type: " + type(context)
  		return false
  	end if

  else

    print "UriHandler.brs - [addRequest] Error: request is the wrong type: " + type(request)
    return false

  end if

  return true

end function

' =============================================================================
' processResponse - Processes the HTTP response. Called in the event loop when a
'                   request initiated by a roUrlTransfer completes (see addRequest function)
'
'                   Parameters:
'
'                      message: a roUrlEvent (https://sdkdocs.roku.com/display/sdkdoc/roUrlEvent)
'                               The event "message" contains the response data.
'
' =============================================================================

sub processResponse(message as Object)

  print "UriHandler.brs - [processResponse]"

  ' Get the unique id of the roUrlTransfer that sent the event

  idKey = stri(message.GetSourceIdentity()).trim()

  ' Find the transfer job associated with the idKey

  job = m.jobsById[idKey]

  ' If the transfer job was found

  if job <> invalid then

    ' The job "context" is the original request data

    originalRequestFields = job.context.context

    parameters = originalRequestFields.parameters
    jobNumber = originalRequestFields.num

    print "UriHandler.brs - [processResponse] Response for job number"; jobNumber; " with transfer id = '"; idkey; "'"

    result = {
      code: message.GetResponseCode(),
      headers: message.GetResponseHeaders(),
      content: message.GetString(),
      format: parameters.format,
      title: parameters.title,
      num: jobNumber
    }

    ' ---------------------------------
    ' Ths point would be a good place to handle various error codes and retry, etc.
    ' ---------------------------------

    ' The transfer job has completed, so remove the job from the associative array

    m.jobsById.delete(idKey)

    ' Assign the transfer result data to the original request

    originalRequestFields.response = result

    ' If the response was normal (200 code) then assign the response data to the parser's "response" field.
    ' This will cause the parser to process the result and assign the parsed content to the UriHandler's
    ' "contentCache" field. When a value is assigned to "contentCache", a message is added to the UriHandler queue,
    ' which will cause updateContent() to be called (see below)

    if message.GetResponseCode() = 200 then

      m.Parser.response = result

    ' If an error occurred retrieve the request content, then increment the number of bad requests and the number of
    ' rows received (for a good request, the number of rows received is increments when updateContent() is executed).

    else

      print "UriHandler.brs - [processResponse] Error: status code was: " + (message.GetResponseCode()).toStr()
      m.top.numBadRequests++
      m.top.numRowsReceived++

    end if

  else

    print "UriHandler.brs - [processResponse] Error: event for unknown job "; idkey

  end if

end sub

' =============================================================================
' updateContent - Callback function for when content has finished parsing. This is
'                 executed by the event loop when the Parser assings the parsed
'                 content to the "contentCache" interface field.
' =============================================================================

sub updateContent()

  print "UriHandler.brs - [updateContent]"

  ' Received another row of content

  m.top.numRowsReceived++

  ' Return if the content is already set (data for
  ' all requests has been received)

  if m.top.contentSet then return

  ' Set the UI if all content from all streams are ready
  ' Note: This technique is hindered by slowest request
  ' Need to think of a better asynchronous method here!

  if m.top.numRows = m.top.numRowsReceived then

    parent = createObject("roSGNode", "ContentNode")

    for i = 0 to (m.top.numRowsReceived - 1)

      oldParent = m.top.contentCache.getField(i.toStr())

      if oldParent <> invalid then
        for j = 0 to (oldParent.getChildCount() - 1)
          oldParent.getChild(0).reparent(parent,true)
        end for
      end if

    end for

    print "UriHandler.brs - [updateContent] All content has finished loading"

    m.top.contentSet = true
    m.top.responseContent = parent

  else

    print "UriHandler.brs - [updateContent] Not all content has finished loading yet"

  end if

end sub
