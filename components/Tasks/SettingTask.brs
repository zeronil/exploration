' =============================================================================
' init
' =============================================================================

sub init()

  print "SettingTask.brs - [init]"
  m.top.functionName = "executeOperation"

end sub

' =============================================================================
' executeOperation
' =============================================================================

sub executeOperation()

  print "SettingTask.brs - [executeOperation] settingName = " m.top.settingName ", settingValue = " m.top.settingValue

  m.settingName = m.top.settingName
  m.settingValue = m.top.settingValue

  if m.settingName <> invalid and Len(m.settingName) > 0 then

    if m.settingValue <> invalid and Len(m.settingValue) > 0 then
      writeSetting()
    else
      readSetting()
    end if

  else
    print "SettingTask.brs - [executeOperation] settingName is missing"
  end if

end sub

' =============================================================================
' readSetting - Read a setting from the registry
' =============================================================================

sub readSetting()

    print "SettingTask.brs - [readSetting] " m.settingName

     registrySection = CreateObject("roRegistrySection", "Settings")

     if registrySection.Exists(m.settingName)
         m.top.readValue = registrySection.Read(m.settingName)
     else
         m.top.readValue = invalid
     endif

     print "SettingTask.brs - [readSetting] Complete ("; m.top.readValue; ")"

end sub

' =============================================================================
' writeSetting - Write a setting to the registry
' =============================================================================

sub writeSetting()

    print "SettingTask.brs - [writeSetting] " m.settingName " = " m.settingValue

    registrySection = CreateObject("roRegistrySection", "Settings")
    m.top.writeSuccess = registrySection.Write(m.settingName, m.settingValue)
    registrySection.Flush()

    print "SettingTask.brs - [writeSetting] Complete ("; m.top.result; ")"

end sub
