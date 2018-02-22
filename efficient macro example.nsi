
#------------------------------------
# efficent way to create install/uninstall procedure
!macro TestFunction UN
    Function ${UN}TestFunction
        ;do stuff
    FunctionEnd
!macroend
!insertmacro TestFunction ""
!insertmacro TestFunction "un."

# how to use previouse macro
Section "Install"
  Call TestFunction
EndSection

Section "Uninstall"
  Call un.TestFuction
SecionEnd
#--------------------------------