# This installs two files, app.exe and logo.ico, creates a start menu shortcut, builds an uninstaller, and
# adds uninstall information to the registry for Add/Remove Programs
 
# To get started, put this script into a folder with the two files (app.exe, logo.ico, and license.rtf -
# You'll have to create these yourself) and run makensis on it
 
# If you change the names "app.exe", "logo.ico", or "license.rtf" you should do a search and replace - they
# show up in a few places.
# All the other settings can be tweaked by editing the !defines at the top of this script
!define APPNAME "App Name"
!define COMPANYNAME "Company Name"
!define DESCRIPTION "A short description goes here"
# These three must be integers
!define VERSIONMAJOR 1
!define VERSIONMINOR 1
!define VERSIONBUILD 1
# These will be displayed by the "Click here for support information" link in "Add/Remove Programs"
# It is possible to use "mailto:" links in here to open the email client
!define HELPURL "http://..." # "Support Information" link
!define UPDATEURL "http://..." # "Product Updates" link
!define ABOUTURL "http://..." # "Publisher" link
# This is the size (in kB) of all the files copied into "Program Files"
;!define INSTALLSIZE 7233
 
RequestExecutionLevel admin ;Require admin rights on NT6+ (When UAC is turned on)
 
InstallDir "$PROGRAMFILES\${COMPANYNAME}\${APPNAME}"
 
# rtf or txt file - remember if it is txt, it must be in the DOS text format (\r\n)
LicenseData "license.rtf"
# This will be in the installer/uninstaller's title bar
Name "${COMPANYNAME} - ${APPNAME}"
Icon "logo.ico"
outFile "${APPNAME}.exe"

 
!include LogicLib.nsh
; !include MUI.nsh
 
# replaced by Modern User Interface block
# Just three pages - license agreement, install location, and installation
page license
page directory
Page instfiles

; !insertmacro MUI_PAGE_LICENSE "license.rtf"
; !insertmacro MUI_PAGE_DIRECTORY
; #!insertmacro MUI_PAGE_STARTMENU "page_id" "variable"
; !insertmacro MUI_PAGE_FINISH

; !insertmacro MUI_UNPAGE_CONFIRM
; !insertmacro MUI_UNPAGE_INSTFILES




# Verify user admin
!macro VerifyUserIsAdmin
UserInfo::GetAccountType
pop $0
${If} $0 != "admin" ;Require admin rights on NT4+
        messageBox mb_iconstop "Administrator rights required!"
        setErrorLevel 740 ;ERROR_ELEVATION_REQUIRED
        quit
${EndIf}
!macroend


# .onInit & un.onInit functions 
!macro onInit UN_ARG
	function ${UN_ARG}onInit
		setShellVarContext all

		${If} ${UN_ARG} == "un."
		#Verify the uninstaller - last chance to back out
		MessageBox MB_OKCANCEL "Permanantly remove ${APPNAME}?" IDOK next
			Abort
		next:
		${EndIf}
		!insertmacro VerifyUserIsAdmin
	functionEnd
!macroend
!insertmacro "onInit" "." 		; .onInit 	function
!insertmacro "onInit" "un."		; un.onInit function

Section Install
	# Files for the install directory - to build the installer, these should be in the same directory as the install script (this file)
	setOutPath $INSTDIR

	Call makeFilesFunction ; install files
	Call makeUninstallerFile
	Call makeStartMenu
	Call makeRegistryInformation
SectionEnd

Section un.Install
	# Files for the install directory - to build the installer, these should be in the same directory as the install script (this file)
	setOutPath $INSTDIR

	Call un.makeStartMenu		; remove start menu
	Call un.makeUninstallerFile ; remove uninstaller file
	Call un.makeFilesFunction 	; remove files
	Call un.makeRegistryInformation
SectionEnd



# makeFilesFunction 	with:	File 	"app.exe" and
# un.makeFilesFunction 	with: 	Delete 	"app.exe"
!macro makeFilesFunction UN_ARG CMD_ARG
    Function ${UN_ARG}makeFilesFunction
        ${CMD_ARG} "app.exe"
        ${CMD_ARG} "logo.ico"
        ${CMD_ARG} "README.txt"

        # Try to remove the install directory - this will only happen if it is empty
        StrCmp ${UN_ARG} "" 0 next ; goes to un: when ${UN_ARG} =! ""
        next: 
        rmDir $INSTDIR
    FunctionEnd
!macroend
!insertmacro makeFilesFunction "" "File"
!insertmacro makeFilesFunction "un." "Delete"

# write & delete uninstaller
!macro makeUninstallerFile UN_ARG CMD_ARG
	Function ${UN_ARG}makeUninstallerFile
		# Uninstaller - See function un.onInit and section "uninstall" for configuration
		${CMD_ARG} "$INSTDIR\uninstall.exe"
	FunctionEnd
!macroend
!insertmacro "makeUninstallerFile" "" 	 "writeUninstaller"
!insertmacro "makeUninstallerFile" "un." "delete"

# Start Menu
Function makeStartMenu
	createDirectory "$SMPROGRAMS\${COMPANYNAME}"
	createShortCut  "$SMPROGRAMS\${COMPANYNAME}\${APPNAME}.lnk" "$INSTDIR\app.exe" "" "$INSTDIR\logo.ico"
FunctionEnd
Function un.makeStartMenu
	# Remove Start Menu launcher
	delete "$SMPROGRAMS\${COMPANYNAME}\${APPNAME}.lnk"
	# Try to remove the Start Menu folder - this will only happen if it is empty
	rmDir "$SMPROGRAMS\${COMPANYNAME}"
FunctionEnd


Function makeRegistryInformation
	# Registry information for add/remove programs
	WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${COMPANYNAME} ${APPNAME}" "DisplayName" "${COMPANYNAME} - ${APPNAME} - ${DESCRIPTION}"
	WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${COMPANYNAME} ${APPNAME}" "UninstallString" "$\"$INSTDIR\uninstall.exe$\""
	WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${COMPANYNAME} ${APPNAME}" "QuietUninstallString" "$\"$INSTDIR\uninstall.exe$\" /S"
	WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${COMPANYNAME} ${APPNAME}" "InstallLocation" "$\"$INSTDIR$\""
	WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${COMPANYNAME} ${APPNAME}" "DisplayIcon" "$\"$INSTDIR\logo.ico$\""
	WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${COMPANYNAME} ${APPNAME}" "Publisher" "$\"${COMPANYNAME}$\""
	WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${COMPANYNAME} ${APPNAME}" "HelpLink" "$\"${HELPURL}$\""
	WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${COMPANYNAME} ${APPNAME}" "URLUpdateInfo" "$\"${UPDATEURL}$\""
	WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${COMPANYNAME} ${APPNAME}" "URLInfoAbout" "$\"${ABOUTURL}$\""
	WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${COMPANYNAME} ${APPNAME}" "DisplayVersion" "$\"${VERSIONMAJOR}.${VERSIONMINOR}.${VERSIONBUILD}$\""
	WriteRegDWORD HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${COMPANYNAME} ${APPNAME}" "VersionMajor" ${VERSIONMAJOR}
	WriteRegDWORD HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${COMPANYNAME} ${APPNAME}" "VersionMinor" ${VERSIONMINOR}
	# There is no option for modifying or repairing the install
	WriteRegDWORD HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${COMPANYNAME} ${APPNAME}" "NoModify" 1
	WriteRegDWORD HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${COMPANYNAME} ${APPNAME}" "NoRepair" 1
	# Set the INSTALLSIZE constant (!defined at the top of this script) so Add/Remove Programs can accurately report the size
	;WriteRegDWORD HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${COMPANYNAME} ${APPNAME}" "EstimatedSize" ${INSTALLSIZE}
FunctionEnd
Function un.makeRegistryInformation
	# Remove uninstaller information from the registry
	DeleteRegKey HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${COMPANYNAME} ${APPNAME}"
FunctionEnd


