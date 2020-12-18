/**
 * Copyright (c) 2020 SafetyCT - https://www.safetyct.com
 * Copyright (c) 2016-2017 Baas geo-information
 * 
 * Operationele Informatie Voorziening Windows installer creation file.
 * 
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 * 
 *     http://www.apache.org/licenses/LICENSE-2.0
 * 
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 *
 * Author: Bart Baas <info@baasgeo.com> and Joost Deen <j.deen@safetyct.com>
 */
 
 /**
 * Issues
 * 
 * Register setting 'askToSaveProjectChanges' zou voor alle gebruikers op false moeten staan
 * 
 */

; Define your application name
!define APPNAME "OIV"
!define QGISVERSION "QGIS3.4"
!define APPTITLE "Operationele Informatie Voorziening"
!define COMPANY "Baas geo-information"

!define VERSION 3.0.9

!define APPNAMEANDVERSION "${APPNAME} ${VERSION}"
!define WEBSITE "http://www.baasgeo.com"
!define REG_APPSETTINGS "Software\Baasgeo\${APPNAME}"
!define REG_UNINSTALL "Software\Microsoft\Windows\CurrentVersion\Uninstall\${APPNAME}"
!define REG_ENVIRONMENT "SYSTEM\CurrentControlSet\Control\Session Manager\Environment"

; Might be the same as !define
Var Host
Var Dbname

; Main Install settings
Name "${APPNAMEANDVERSION}"
BrandingText "${WEBSITE}"
;InstallDir "$APPDATA\${APPNAME}-${VERSION}"
OutFile "output\${APPNAME}-${VERSION}-${QGISVERSION}.exe"

; Compression options
CRCCheck on

; For Vista
RequestExecutionLevel admin

; Plugins
!include MUI2.nsh ; Modern interface
!include StrFunc.nsh ; String functions
; Need to load this manually from StrFunc
${StrRep}
!include LogicLib.nsh ; ${If} ${Case} etc.
!include nsDialogs.nsh ; For Custom page layouts (Radio buttons etc)
!include winmessages.nsh ; Include for some of the windows messages defines
!include TextFunc.nsh ; For ConfigWrite functions

; Version Information (Version tab for EXE properties)
VIProductVersion "${VERSION}.0"
VIAddVersionKey ProductName "${APPTITLE}"
VIAddVersionKey FileDescription "${APPNAME} Installer"
VIAddVersionKey ProductVersion "${VERSION}"
VIAddVersionKey FileVersion "${VERSION}"
VIAddVersionKey CompanyName "${COMPANY}"
VIAddVersionKey LegalCopyright "${COMPANY}"
VIAddVersionKey Comments "${WEBSITE}"

; Interface Settings
!define MUI_ICON "pictogram.ico"
!define MUI_UNICON "${NSISDIR}\Contrib\Graphics\Icons\win-uninstall.ico"
!define MUI_HEADERIMAGE
!define MUI_HEADERIMAGE_RIGHT
!define MUI_HEADERIMAGE_BITMAP header.bmp
!define MUI_WELCOMEFINISHPAGE_BITMAP side_left.bmp

; "Are you sure you wish to cancel" popup.
!define MUI_ABORTWARNING

; Optional text settings here
!define MUI_FINISHPAGE_LINK " Installer created and maintained by ${COMPANY}"
!define MUI_FINISHPAGE_LINK_LOCATION "${WEBSITE}"

; Install Page order
; This is the main list of installer things to do 
!insertmacro MUI_PAGE_WELCOME                                 ; Hello
Page custom CheckUserType                                     ; Die if not admin
!insertmacro MUI_PAGE_LICENSE "license.txt"                   ; Show license
!insertmacro MUI_PAGE_COMPONENTS							  ; Components page
Page custom nsDialogHost nsDialogHostLeave					  ; Set web server port
Page custom Ready                                             ; Summary page
!insertmacro MUI_PAGE_INSTFILES                               ; Actually do the install
!insertmacro MUI_PAGE_FINISH                                  ; Done

; Uninstall Page order
!insertmacro MUI_UNPAGE_CONFIRM   ; Are you sure you wish to uninstall?
!insertmacro MUI_UNPAGE_INSTFILES ; Do the uninstall

; Set languages (first is default language)
!insertmacro MUI_LANGUAGE "English"
!insertmacro MUI_RESERVEFILE_LANGDLL

; Install options page headers
LangString TEXT_READY_TITLE ${LANG_ENGLISH} "Ready to Install"
LangString TEXT_READY_SUBTITLE ${LANG_ENGLISH} "${APPNAME} is ready to be installed"
LangString TEXT_CREDS_TITLE ${LANG_ENGLISH} "${APPNAME} Administrator"
LangString TEXT_CREDS_SUBTITLE ${LANG_ENGLISH} "Set administrator credentials"
LangString TEXT_HOST_TITLE ${LANG_ENGLISH} "${APPNAME} Web Server Host"
LangString TEXT_HOST_SUBTITLE ${LANG_ENGLISH} "Set the host that ${APPNAME} will respond on"

; Check the user type, and quit if it's not an administrator.
; Taken from Examples/UserInfo that ships with NSIS.
Function CheckUserType
  ClearErrors
  UserInfo::GetName
  IfErrors Win9x
  Pop $0
  UserInfo::GetAccountType
  Pop $1
  StrCmp $1 "Admin" Admin NoAdmin

  NoAdmin:
    MessageBox MB_ICONSTOP "Sorry, you must have administrative rights in order to install ${APPNAME}."
    Quit

  Win9x:
    MessageBox MB_ICONSTOP "This installer is not supported on Windows 9x/ME."
    Quit
		
  Admin:
  StrCpy $1 "" ; zero out variable
	
FunctionEnd

; Set the web server host
Function nsDialogHost

  !insertmacro MUI_HEADER_TEXT "$(TEXT_HOST_TITLE)" "$(TEXT_HOST_SUBTITLE)"
  nsDialogs::Create 1018

  ;Syntax: ${NSD_*} x y width height text
  ${NSD_CreateLabel} 0 0 100% 36u "Set the database host and name that ${APPNAME} will respond on."

  ${NSD_CreateLabel} 20u 40u 60u 14u "Host database:"  
  ${NSD_CreateComboBox} 80u 38u 120u 14u $0
  Pop $0
  ${NSD_CB_AddString} $0 localhost
  ${NSD_CB_SelectString} $0 $Host
  
  ${NSD_CreateLabel} 20u 60u 60u 14u "Database name:"  
  ${NSD_CreateText} 80u 58u 120u 14u $1
  Pop $1
  ${NSD_SetText} $1 $Dbname

  ${NSD_CreateLabel} 20u 80u 100% 14u "Example valid database hosts are: localhost, data.geoatlas.nl" 

  nsDialogs::Show

FunctionEnd

Function nsDialogHostLeave
	# Read form
	${NSD_GetText} $0 $Host
	${NSD_GetText} $1 $Dbname

FunctionEnd

; Summary page before install
Function Ready

  nsDialogs::Create 1018
  !insertmacro MUI_HEADER_TEXT "$(TEXT_READY_TITLE)" "$(TEXT_READY_SUBTITLE)"

  ;Syntax: ${NSD_*} x y width height text
  ${NSD_CreateLabel} 0 0 100% 24u "Please review the settings below and click the Back button if \
                                   changes need to be made.  Click the Install button to continue."

  ; Directory
  ${NSD_CreateLabel} 10u 25u 35% 24u "Installation directory:"
  ${NSD_CreateLabel} 40% 25u 60% 24u "$INSTDIR"

  ; Install type
  ${NSD_CreateLabel} 10u 45u 35% 24u "Database settings:"
  ${NSD_CreateLabel} 10u 55u 35% 24u "Host:"
  ${NSD_CreateLabel} 40% 55u 60% 24u $Host

  ; Data dir
  ${NSD_CreateLabel} 10u 65u 35% 24u "Database name:"
  ${NSD_CreateLabel} 40% 65u 60% 24u $Dbname
  
  ; Data dir
  ${NSD_CreateLabel} 10u 75u 35% 24u "User:"
  ${NSD_CreateLabel} 40% 75u 60% 24u "oiv_tekenaar1"

  ; Port
  ${NSD_CreateLabel} 10u 85u 35% 24u "Port:"
  ${NSD_CreateLabel} 40% 85u 60% 24u "5432"

  nsDialogs::Show

FunctionEnd

!macro setVars

  ReadRegStr $Host HKLM "${REG_APPSETTINGS}" "Host"
  ReadRegStr $Dbname HKLM "${REG_APPSETTINGS}" "Dbname"

  ; Populates defaults on first display, and resets to default user blanked any of the values
  ${If} $Host == ""
	StrCpy $Host "localhost"
  ${EndIf}
  ${If} $Dbname == ""
	StrCpy $Dbname "oiv_prod"
  ${EndIf}

!macroend

Function .onInit

	; This is needed to set programdata dir
	setShellVarContext all
	StrCpy $INSTDIR "$APPDATA\${APPNAME}-${VERSION}"
	
	Call VersionCheck
	!insertmacro setVars
	
FunctionEnd

; The main install section
Section "${APPNAME} (required)" SectionMain

	SectionIn RO ; Makes this install mandatory
	SetOverwrite on
	
	; Uninstall old version first
	Call RemovePrevious 

	; Section Files
	CreateDirectory "$INSTDIR"
	SetOutPath "$INSTDIR"
	File /a license.txt
	File /a nircmd.exe
	File /a dos2unix.exe
	File /r ..\config\ini
	
	; Create service file
	File /a ..\config\pg_service.conf
		${ConfigWrite} "$INSTDIR\pg_service.conf" "host=" "$Host" $R0
		${ConfigWrite} "$INSTDIR\pg_service.conf" "dbname=" "$Dbname" $R1
		
	; set variable
	DetailPrint "Set windows variable PGSERVICEFILE to $INSTDIR\pg_service.conf"
	WriteRegStr HKLM "${REG_ENVIRONMENT}" "PGSERVICEFILE" "$INSTDIR\pg_service.conf"
	; make sure windows knows about the change
	SendMessage ${HWND_BROADCAST} ${WM_WININICHANGE} 0 "STR:Environment" /TIMEOUT=5000
	; convert eol to unix 
	nsExec::ExecToLog "$INSTDIR\dos2unix.exe $INSTDIR\pg_service.conf"

	; Registry
	DetailPrint "Write ${APPNAME} settings to registry"
	WriteRegStr HKLM "${REG_APPSETTINGS}" "" "$INSTDIR"
	WriteRegStr HKLM "${REG_APPSETTINGS}" "Name" "${APPTITLE}"
	WriteRegStr HKLM "${REG_APPSETTINGS}" "Version" "${VERSION}"
	WriteRegStr HKLM "${REG_APPSETTINGS}" "Publisher" "${COMPANY}"
	WriteRegStr HKLM "${REG_APPSETTINGS}" "WebSite" "${WEBSITE}"
	WriteRegStr HKLM "${REG_APPSETTINGS}" "Host" "$Host"
	WriteRegStr HKLM "${REG_APPSETTINGS}" "Dbname" "$Dbname"

	; User settings
	WriteRegStr HKCU "Software\QGIS\QGIS3\Qgis" "askToSaveProjectChanges" "false"

SectionEnd

Section "Objecten" SectionObjecten

	; Section Files
	CreateDirectory "$INSTDIR"
	SetOutPath "$INSTDIR"
	File /a ..\config\objecten\OIV_Objecten.qgz
	File /a ..\config\objecten\objecten.ico
	File /r ..\config\objecten\ui
	File /r ..\config\objecten\svg
 
	; Create desktop shortcuts
	;ReadRegStr $R0 HKLM "Software\QGIS" "InstallPath"
	ReadRegStr $R0 HKCR "QGIS Project\Shell\open\command" ""
	${StrRep} $R1 $R0 "%1" "$INSTDIR\OIV_Objecten.qgz"

	SetShellVarContext all

	CreateShortCut "$desktop\${APPNAME} Objecten.lnk" \
					"$INSTDIR\nircmd.exe"  \
					'exec hide $R1 --customizationfile "$INSTDIR\ini\oiv.ini"' \
					"$INSTDIR\objecten.ico" 0
 
SectionEnd
 
Section "Bluswater" SectionBluswater
 
	; Section Files
	CreateDirectory "$INSTDIR"
	SetOutPath "$INSTDIR"
	File /a ..\config\bluswater\Bluswater_Beheer.qgs
	File /a ..\config\bluswater\bluswater.ico
	File /r ..\config\bluswater\svg
 
	; Create desktop shortcuts
	;ReadRegStr $R0 HKLM "Software\QGIS" "InstallPath"
	ReadRegStr $R0 HKCR "QGIS Project\Shell\open\command" ""
	${StrRep} $R1 $R0 "%1" "$INSTDIR\Bluswater_Beheer.qgs"

	SetShellVarContext all

	CreateShortCut "$desktop\${APPNAME} Bluswater.lnk" \
					"$INSTDIR\nircmd.exe"  \
					'exec hide $R1 --customizationfile "$INSTDIR\ini\oiv.ini"' \
					"$INSTDIR\bluswater.ico" 0
 
SectionEnd

Section "Plugin v3.0" SectionPlugin
 
	; Get install path
	SetRegView 64 
	ReadRegStr $R0 HKLM "SOFTWARE\QGIS 3.4" "InstallPath"
	StrCpy $R1 "$R0\apps\qgis-ltr\python\plugins"
	
	; Section Files
	CreateDirectory "$R1"
	SetOutPath "$R1"
	File /r ..\plugin\oiv
	
	SetRegView 32
	WriteRegStr HKLM "${REG_APPSETTINGS}" "PluginDir" "$R1\oiv"
 
SectionEnd

; What happens at the end of the install.
Section -FinishSection

	; For the Add/Remove programs area
	WriteRegStr HKLM "${REG_UNINSTALL}" "DisplayName" "${APPTITLE}"
	WriteRegStr HKLM "${REG_UNINSTALL}" "Version" "${VERSION}"
	WriteRegStr HKLM "${REG_UNINSTALL}" "UninstallString" "$INSTDIR\uninstall.exe"
	WriteRegStr HKLM "${REG_UNINSTALL}" "InstallLocation" "$INSTDIR"
	WriteRegStr HKLM "${REG_UNINSTALL}" "DisplayIcon" "$INSTDIR\pictogram.ico"
	WriteRegStr HKLM "${REG_UNINSTALL}" "HelpLink" "${WEBSITE}"
	WriteRegStr HKLM "${REG_UNINSTALL}" "Publisher" "${COMPANY}"
	
	WriteUninstaller "$INSTDIR\uninstall.exe"

SectionEnd

Function VersionCheck

	ReadRegStr $R0 HKLM "${REG_UNINSTALL}" "UninstallString"
	ReadRegStr $R1 HKLM "${REG_UNINSTALL}" "Version"

	StrCmp $R1 ${VERSION} uninst done
  
;Run the uninstaller
uninst:
	ClearErrors
	Exec "$R0" ; Run the uninstaller
	Quit
  
done:
	StrCpy $R0 "" ; zero out variable
	StrCpy $R1 "" ; zero out variable

FunctionEnd

Function RemovePrevious

	ReadRegStr $R0 HKLM "${REG_UNINSTALL}" "UninstallString"

	StrCmp $R0 "" done
		nsExec::ExecToLog "$R0 /S" ; uninstall silently
  
done:
	StrCpy $R0 "" ; zero out variable

FunctionEnd

; Uninstall section
Section Uninstall

  ; delete variable
  DeleteRegValue "HKLM" "${REG_ENVIRONMENT}" "PGSERVICEFILE"
  ; make sure windows knows about the change
  SendMessage ${HWND_BROADCAST} ${WM_WININICHANGE} 0 "STR:Environment" /TIMEOUT=5000

  ; Delete plugin
  ReadRegStr $R0 HKLM "${REG_APPSETTINGS}" "PluginDir"
  RMDir /r "$R0"
  
  ; Delete Shortcuts
  SetShellVarContext all
  Delete "$desktop\${APPNAME} *.lnk"
  
  ;Remove from registry...
  DeleteRegKey HKLM "${REG_UNINSTALL}"
  DeleteRegKey HKLM "${REG_APPSETTINGS}"

  ; Delete self
  Delete "$INSTDIR\uninstall.exe"

  ; Delete files/folders
  RMDir /r "$INSTDIR\ui"
  RMDir /r "$INSTDIR\ini"
  RMDir /r "$INSTDIR\svg"
  Delete "$INSTDIR\*.*"

  RMDir "$INSTDIR\" ; no /r!

SectionEnd

; The End
