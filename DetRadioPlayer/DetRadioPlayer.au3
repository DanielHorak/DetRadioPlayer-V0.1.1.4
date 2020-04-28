#include <WinAPI.au3>
#include <IE.au3>
#include <EditConstants.au3>
#include <MsgBoxConstants.au3>
#include <AutoItConstants.au3>
#include <WinAPIFiles.au3>
#include <GUIConstantsEx.au3>
#include <WindowsConstants.au3>
#include <EditConstants.au3>
#include <FileConstants.au3>
#include <ColorConstants.au3>
#include <FontConstants.au3>

Func OnLoadN()
 Local $OpenFileDataFileText = FileOpenDialog("Vyber soubor pro spuštení radia - DetRadioPlayer", "\Radio", "Rádio (*.radio)", BitOR($FD_FILEMUSTEXIST, $FD_MULTISELECT))

If $OpenFileDataFileText == "" Then
   Local $DataMsgBoxError = MsgBox(1 + 48, "Chyba - DetRadioPlayer", "Nemáte vybraný soubor!")
   If $DataMsgBoxError == 1 Then
      OnLoadN()
   Else
	  FileDelete(@ScriptDir & "\" & "Data.filename")
	  FileWrite(@ScriptDir & "\" & "Data.filename", "data-null")
	  Exit
   EndIf
   Else
FileDelete(@ScriptDir & "\" & "Data.filename")
FileWrite(@ScriptDir & "\" & "Data.filename", $OpenFileDataFileText)

  OnLoadM()
EndIf
EndFunc

OnLoadM()
Func OnLoadM()
      Local $Width = 642
      Local $Height =442
        $DataGuiJkA = GUICreate("DetRadioPlayer - Radio přehrávač", $Width, $Height)
   GUISetBkColor(0xbafff9)
   Local $sFont = "Open Sans"
   GUISetFont(10, $FW_BOLD, $GUI_FONTNORMAL, $sFont)

   Local $OneMenu = GUICtrlCreateMenu("&Soubor")
   Local $TwoMenu = GUICtrlCreateMenu("&Info")
   Local $ThreeMenu = GUICtrlCreateMenu("&Zavřít aplikaci")

    Local $OpenRadio = GUICtrlCreateMenuItem("Otevřít seznam radio stanic", $OneMenu)
	Local $OpenInfoNa = GUICtrlCreateMenuItem("Návod", $TwoMenu)
    Local $OpenInfo = GUICtrlCreateMenuItem("Informace o aplikaci", $TwoMenu)
	Local $CloseApp = GUICtrlCreateMenuItem("Zavřít aplikaci DetFile", $ThreeMenu)

	Local $DataFile = FileRead(@ScriptDir & "\" & "Data.filename")
    Local $DataNameRadio = FileReadLine($DataFile, 2)
	Local $DataInfoRadio = FileReadLine($DataFile, 4)
	Local $DataURLPlayRadio = FileReadLine($DataFile, 6)
 If $DataFile == "data-null" Then
    Local $DataInfoFile = GUICtrlCreateLabel("     " & "Název radia:" & "   " & "Nebylo vybráno žádné radio..." & "   ", 10, 10)
    GUICtrlSetBkColor($DataInfoFile, $COLOR_AQUA)
 Else
	Local $DataInfoFile = GUICtrlCreateLabel("     " & "Název radia:" & "   " & $DataNameRadio & "   ", 10, 10)
    GUICtrlSetBkColor($DataInfoFile, $COLOR_AQUA)
 EndIf

    Local $DataInfoFileB = GUICtrlCreateLabel("     " & "Informace:   ", 10, 110)
    GUICtrlSetBkColor($DataInfoFileB, $COLOR_AQUA)

 If $DataInfoRadio == "" Then
    GUICtrlCreateEdit("## --- Nebylo vybráno žádné radio --- ##", 3, 130, 636, 289, $ES_READONLY)
 Else
	GUICtrlCreateEdit($DataInfoRadio, 3, 130, 636, 289, $ES_READONLY)
 EndIf

        $iCtrlID = _MediaPlayerEmbeded($DataURLPlayRadio, 0, 30, 642, 70)

        GUISetState()
        While 1
            Switch GUIGetMsg()
			Case $GUI_EVENT_CLOSE
				    FileDelete(@ScriptDir & "\" & "Data.filename")
                    FileWrite(@ScriptDir & "\" & "Data.filename", "data-null")
                    Exit
				 Case $OpenRadio
                     GUIDelete($DataGuiJkA)
					 OnLoadN()
			     Case $OpenInfoNa
                     ShellExecuteWait(@ScriptDir & "/" & "DetRadioPlayerInfo.xps")
			     Case $OpenInfo
                     ShellExecuteWait(@ScriptDir & "/" & "DetRadioPlayerInfo.xps")
			     Case $CloseApp
					FileDelete(@ScriptDir & "\" & "Data.filename")
                    FileWrite(@ScriptDir & "\" & "Data.filename", "data-null")
					Exit
            EndSwitch
        WEnd
    EndFunc
    Func _MediaPlayerEmbeded($sFileName, $iLeft, $iTop, $iWidth, $iHeight)
        Local $oShell, $sInnerHTML, $iCtrlID

        $sInnerHTML = '<object id="player" height="100%" width="100%" align="middle" ' & _
                'classid="CLSID:6BF52A52-394A-11d3-B153-00C04F79FAA6"> ' & _
                ' <param name="URL" value="' & $sFileName & '">' & _
                ' <param name="uiMode" value="none"> ' & _
                ' <param name="fullScreen" value="false"> ' & _
                ' <param name="ShowControls" value="true"> ' & _
                ' <param name="ShowStatusBar" value="true"> ' & _
                ' <param name="ShowDisplay" value="true"> ' & _
                ' <embed type="application/x-mplayer2" ' & _
                ' pluginspage = "http://www.microsoft.com/Windows/MediaPlayer/" ' & _
                ' SRC="' & $sFileName & '"' & _
                '</embed></object>'

        $oShell = ObjCreate("Shell.Explorer")
        $iCtrlID = GUICtrlCreateObj($oShell, $iLeft, $iTop, $iWidth, $iHeight)

        $oShell.navigate("about:blank")
        While $oShell.Busy()
            Sleep(10)
        WEnd
        With $oShell.document
            .write('<head><title></title><script language="javascript"></script></HEAD>')
            .write('<body onselectstart="return false" oncontextmenu="return false" onclick="return false" ondragstart="return false" ondragover="return false">')
            .body.innerHTML = $sInnerHTML
            .body.topmargin = 0
            .body.leftmargin = 0
            .body.scroll = "no"
            .body.bgcolor = 0x000000
            .body.style.borderWidth = 0
        EndWith

        Return $iCtrlID
    EndFunc

    Func WM_NCHITTEST($hWnd, $iMsg, $wParam, $lParam)
        #forceref $hWnd, $iMsg, $wParam, $lParam

        Local $iDef = _WinAPI_DefWindowProc($hWnd, $iMsg, $wParam, $lParam)

        Switch $iDef
            Case $HTSYSMENU, $HTBOTTOM, $HTBOTTOMLEFT, $HTBOTTOMRIGHT, $HTLEFT, $HTRIGHT, $HTTOP, $HTTOPLEFT, $HTTOPRIGHT
                Return $HTCAPTION
        EndSwitch

        Return $iDef
	 EndFunc
