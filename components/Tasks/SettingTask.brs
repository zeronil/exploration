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

  print "SettingTask.brs - [executeOperation] settingName = " m.top.settingName ", settingValue = " m.top.settingValue.trim()

  m.settingName = m.top.settingName
  m.settingValue = m.top.settingValue

  if m.settingName <> invalid and Len(m.settingName) > 0 then

    ' If settingName and settingValue are both specified then perform a write;
    ' otherwise, perform a read .

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

     if registrySection.Exists(m.settingName) then
         m.top.settingValueRead = registrySection.Read(m.settingName)
     else
         m.top.settingValueRead = invalid
     endif

     print "SettingTask.brs - [readSetting] Complete (" m.settingName " = " m.top.settingValueRead.trim() ")"

end sub

' =============================================================================
' writeSetting - Write a setting to the registry
' =============================================================================

sub writeSetting()

    print "SettingTask.brs - [writeSetting] " m.settingName " = " m.settingValue.trim()

    registrySection = CreateObject("roRegistrySection", "Settings")
    m.top.settingWriteSuccess = registrySection.Write(m.settingName, m.settingValue)
    registrySection.Flush()

    print "SettingTask.brs - [writeSetting] Complete (success = " m.top.settingWriteSuccess ")"

end sub
