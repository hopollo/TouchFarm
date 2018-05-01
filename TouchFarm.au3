#cs ----------------------------------------------------------------------------

 AutoIt Version: 3.3.14.5
 Author:         HoPollo

 Script Function:
	Template AutoIt script.

#ce ----------------------------------------------------------------------------

#RequireAdmin
#include <ButtonConstants.au3>
#include <EditConstants.au3>
#include <GUIConstantsEx.au3>
#include <File.au3>
#include <Array.au3>
#include <WinAPIFiles.au3>
#include <StaticConstants.au3>
#include <WindowsConstants.au3>
#include <ScrollBarsConstants.au3>
#include <MsgBoxConstants.au3>
#include <ImageSearch.au3>
#include <GuiEdit.au3>
#include <StaticConstants.au3>

Global $config = "config.ini"

Global $imageUrl = IniRead($config, "basic", "Image_Folder", "")
Global $targetUrl = IniRead($config, "basic", "Target_Folder", "")

Global $debugMode = IniRead($config, "basic", "Debug_Mode", False)

Global $succes[] = ["claim1.png","claim2.png"]

Global $spell = IniRead($config, "settings", "Button_Spell", "")
Global $closeBtn = IniRead($config, "settings", "Button_Close", "")
Global $readyBtn = IniRead($config, "settings", "Button_Ready", "")
Global $endTurnBtn = IniRead($config, "settings", "Button_Pass", "")
Global $specBtn = IniRead($config, "settings", "Button_Spectate", "")

Global $meColor = IniRead($config, "settings", "Color_Player", 0x689B00)
Global $enemyColor = IniRead($config, "settings", "Color_Enemy", 0x808090)
Global $popupColor = IniRead($config, "settings", "Color_Popup", 0x2E2D28)

Global $sleep = IniRead($config, "basic", "Timer", 250)
Global $boostStats = IniRead($config, "settings", "Boost_Stats", False)

Global $nbrDePa = IniRead($config, "gameplay", "Max_Pa", 6)
Global $nbrDePm = IniRead($config, "gameplay", "Max_Pm", 3)
Global $nbrDePo = IniRead($config, "gameplay", "Max_Po", 6)
Global $nbrDeCout = IniRead($config, "gameplay", "Cost_Per_Hit", 3)

Global $barTurnState = 0xFFE348
Global $fullHp = IniRead($config, "settings", "Color_Full_Hp", 0xDA6D62)
Global $lowHp = IniRead($config, "settings", "Color_Low_Hp", 0x968E7C)

Global $mapMaxLeft = IniRead($config, "settings", "Game_Map_Max_Left", 71)
Global $mapMaxTop = IniRead($config, "settings", "Game_Map_Max_Top", 36)
Global $mapMaxRight = IniRead($config, "settings", "Game_Map_Max_Right", 1155)
Global $mapMaxBottom = IniRead($config, "settings", "Game_Map_Max_Bottom", 737)

Global $healing = False
Global $specLock = False

;Global $mapMax[] = [$mapMaxLeft, $mapMaxRight, $mapMaxTop, $mapMaxBottom]

Global $reason = "Thanks for using this program, see you next time."

HotKeySet ("{ESC}","ExitScript")

#Region ### START Main GUI ###
Global $Form1 = GUICreate("TouchFarm", 197, 268, 192, 124)
WinSetOnTop($Form1, "", 1)
Global $journal = GUICtrlCreateEdit("", 0, 0, 196, 209, BitOR($ES_AUTOVSCROLL,$ES_READONLY,$WS_VSCROLL))
GUICtrlSetData(-1, "")
GUICtrlSetState(-1, $GUI_DISABLE)
GUICtrlSetCursor (-1, 2)
$GUI_EVENT_START = GUICtrlCreateButton("Start", 56, 240, 75, 25)
GUICtrlSetFont(-1, 8, 800, 0, "MS Sans Serif")
GUICtrlSetBkColor(-1, 0x008080)
$GUI_EVENT_TARGET = GUICtrlCreateButton("+", 170, 240, 25, 25)
GUICtrlSetFont(-1, 8, 800, 0, "MS Sans Serif")
GUICtrlSetBkColor(-1, 0x008080)
GUICtrlCreateLabel("PA | PM", 9, 209, 50)
$GUI_EVENT_PA = GUICtrlCreateInput($nbrDePa, 10, 222, 15, 16)
$GUI_EVENT_PM = GUICtrlCreateInput($nbrDePm, 30, 222, 15, 16)
GUICtrlCreateLabel("ATK | PO", 2, 238, 50)
$GUI_EVENT_ATK = GUICtrlCreateInput($nbrDeCout, 10, 251, 15, 16)
$GUI_EVENT_PO = GUICtrlCreateInput($nbrDePo, 30, 251, 15, 16)
Opt("GUICoordMode", 2)
GUISetCoord(1153, 231)
GUICtrlSetState($GUI_EVENT_PA, 128)
GUICtrlSetState($GUI_EVENT_PM, 128)
GUICtrlSetState($GUI_EVENT_ATK, 128)
GUICtrlSetState($GUI_EVENT_PO, 128)
GUISetState(@SW_SHOW)
#EndRegion ### END Main GUI ###

#Region ### START Target GUI ###
$Form2 = GUICreate("Form1", 192, 233, 192, 124)
$Close = GUICtrlCreateButton("Close", 8, 208, 171, 17)
GUICtrlSetFont(-1, 8, 800, 0, "MS Sans Serif")
GUICtrlSetBkColor(-1, 0x008080)
GUICtrlSetCursor (-1, 0)
$Available = GUICtrlCreateLabel("Available", 24, 8, 47, 17)
$Current = GUICtrlCreateLabel("Current", 128, 8, 38, 17)
GUICtrlCreateGroup("", 96, 0, 1, 201)
GUICtrlSetBkColor(-1, 0xFFFFFF)
GUICtrlCreateGroup("", -99, -99, 1, 1)
#EndRegion ### END Target GUI ###

While 1
   $nMsg = GUIGetMsg()
   Switch $nMsg
	  Case $GUI_EVENT_CLOSE
		 ExitScript()
	  Case $GUI_EVENT_START
		 GUICtrlSetData($GUI_EVENT_START, "ESC = exit")
		 Requierments()

   EndSwitch
WEnd

Func FreshStart()
   Sleep(100)

   GUICtrlSetData($GUI_EVENT_START, "Start")

   Requierments()
EndFunc

Func info($messageJournal, $autresInfos = "")
   GUICtrlSetData($journal, GUICtrlRead($journal) & @CRLF & $messageJournal)
   $end = StringLen(GUICtrlRead($journal))
   _GUICtrlEdit_SetSel($journal, $end, $end)
   _GUICtrlEdit_Scroll($journal, $SB_SCROLLCARET)
EndFunc

Func debug($messageJournal, $autresInfos = "")
   If $debugMode = True Then
	  $sleep = 500
	  GUICtrlSetData($journal, GUICtrlRead($journal) & @CRLF & $messageJournal)
	  $end = StringLen(GUICtrlRead($journal))
	  _GUICtrlEdit_SetSel($journal, $end, $end)
	  _GUICtrlEdit_Scroll($journal, $SB_SCROLLCARET)
   EndIf
EndFunc

Func Requierments()
   Global $Pa = GUICtrlRead($GUI_EVENT_PA)
   GLobal $cost = GUICtrlRead($GUI_EVENT_ATK)
   Global $Pm = GUICtrlRead($GUI_EVENT_PM)
   Global $Po = GUICtrlRead($GUI_EVENT_PO)


   ;TODO (HoPollo) : Add dir check requierments maybe ?
   $file = FileExists($config)
   $process = ProcessExists("Lindo.exe")
   $lindo = "[TITLE:Lindo]"
   $focus = WinActive($lindo)
   $state = WinGetState($lindo)

   Select
	  Case $file = 0
		 MsgBox(0,"Fatal error","Unable to reach config.ini, make sure it's in the main folder")
	  Case $process = 0
		 $btn = MsgBox($MB_RETRYCANCEL,"Error","Unable to find : Lindo, make sure you launched it & press OK")
		 If $btn = 4 Then
			info("Unable to find the game.")
			FreshStart()
		 ElseIf $btn = 2 Then
			ExitScript()
		 EndIf

	  Case $focus = 0
		 WinActivate($lindo)
		 If 0 Then info("Unable to give Lindo the focus")

	  Case $state <> 32
		 WinSetState($lindo, "", @SW_MAXIMIZE)
   EndSelect

  RestrictionCheck()
EndFunc

Func RestrictionCheck()
   ;TODO (HoPollo) : Restric to positive numbers only
   If $Pa < $cost Or $Pa <= 0 Or $Pm <= 0 Or $Po <= 0 Or $cost <= 0 Then
	  MsgBox(0, "Error", "Wrong number around Pa/Pm/Atk/Po")
	  FreshStart()
   Else
	  If $debugMode Then debug("Debug mode : ON")
	  If $debugMode Then debug("Sleeps time :" & $sleep & "ms")
	  If Not $debugMode Then info("Steps :" & $sleep & "ms")
   EndIf

   ReadTargets()
EndFunc

Func ReadTargets()

   Global $targetInfo = _FileListToArrayRec($targetUrl, "*", $FLTAR_FILES, $FLTAR_NORECUR, $FLTAR_SORT)
   If @error Then
	  info("Unable to retrieve target info from config files")
	  FreshStart()
   EndIf

   Dim $foo[0]

   debug("Found : " & $targetInfo[0] & @CRLF)
   info("Current targets :" & @CRLF)

   For $i = 1 To $targetInfo[0]
	  info($targetInfo[$i] & @CRLF)
	  _ArrayAdd($foo, $targetInfo[$i])
   Next

   Global $selectedTarget = Random(0, UBound($foo)-1, 1)
   info("Choosen : " & $foo[$selectedTarget] & @CRLF)
   $read = IniRead($targetUrl & $foo[$selectedTarget], "basic", "colors","")
   debug("Read -> " & $read & @CRLF)

   Dim $pixels[0]
   _ArrayAdd($pixels, $read)
   $rdm = Random(0, Ubound($pixels) - 1, 1)
   ;Code by Theo
   Global $pixelString = $pixels[$rdm]
   Global $splitArr = StringSplit($pixelString, ", ")

   Start()
EndFunc

Func Start()
   info("Searching...")
   While 1
	  Global $1 = PixelSearch($mapMaxLeft, $mapMaxTop, $mapMaxRight, $mapMaxBottom, $enemyColor, 2)
	  Global $2 = PixelSearch($mapMaxLeft, $mapMaxTop, $mapMaxRight, $mapMaxBottom, $meColor, 2)

	  Global $4 = PixelGetColor(1177, 59) ; HealthColor(middle)

	  Global $5 = _ImageSearch($imageUrl & $closeBtn)
	  Global $8 = PixelGetColor(1357, 585) ; Turn Bar(start from bottom)
	  Global $9 = _ImageSearch($imageUrl & $succes[0])
	  Global $10 = PixelGetColor(1211, 552)

	  If IsArray($1) And IsArray($2) And $8 = 0xFFE348 Then
		 Positionning()
	  ElseIf $4 = $lowHp And $healing = False Then
		 Regen()
	  ElseIf $4 = $fullHp Then
		 RunAround()
	  ElseIf IsArray($5) Then
		 ClosePopup()
	  ElseIf $8 = 0x1FDDDD Then
		 Start()
	  ElseIf IsArray($9) Then
		 ClaimSucces()
	  ElseIf $10 = 0xC6F152 And $boostStats = True Then
		 BoostStats()
	  EndIf

	  $attemps = 0
	  $a = 0
	  Do
		 $a = $a + 1
		 debug("Color picked : " & $splitArr[$a] & " out of " & $splitArr[0])
		 Global $scan = PixelSearch($mapMaxLeft, $mapMaxTop, $mapMaxRight, $mapMaxBottom, $splitArr[$a], 1)
		 If Not @error Then
			debug("Color : Succes (" & $splitArr[$a] & ")")
			$attempps = 0 + $splitArr[0]
			AttackTarget()
		 Else
			$attemps = $attemps + 1
			debug("Color : Fail n°" & $attemps)
		 EndIf
	  Until $attemps = $splitArr[0]
   WEnd
EndFunc

Func AttackTarget()
   info("Fight incoming...")
   Sleep($sleep)

   MouseClick("", $scan[0], $scan[1], 2, 15)

   Start()
EndFunc

Func RunAround()
   info("Running to find...")
   Sleep(250)

   ;TODO (HoPollo) : Implement random map switching
;~    Local $direction = Random(0, UBound($mapMax) - 1, 1)
;~    MouseClick("", $maxMap[$direction])

   Start()
EndFunc

Func Positionning()
   info("Combat detected")
   If $specLock = False Then CombatSettings()

   $healing = False
   Sleep($sleep)

   Local $ready = _ImageSearch($imageUrl & $readyBtn)
   Local $endTurn = _ImageSearch($imageUrl & $endTurnBtn)

   If IsArray($ready) Then
	  debug("Rdy Btn founded")
	  Sleep($sleep)
	  MouseClick("", $ready[0], $ready[1])
   ElseIf IsArray($endTurn) Then
	  SearchingCoord()
   EndIf

   SearchingCoord()
EndFunc

Func CombatSettings()
   Sleep($sleep)

   MouseClick("", 1168, 94) ; Develop top menu slider

   $lock = _ImageSearch($imageUrl & $specBtn)
   If IsArray($lock) Then
	  MouseClick("", $lock[0], $lock[1])
	  $specLock = True
   EndIf
EndFunc

Func SearchingCoord()
   debug("Searching Coord...")
   Sleep($sleep)

   $foundedMob = False
   $foundedMe = False
   $maxTry = 2

   Do
	  debug("Searching pixel Mob + Me(Creature)")
	  Sleep($sleep)

	  Global $meCreature = PixelSearch($mapMaxLeft, $mapMaxTop, $mapMaxRight, $mapMaxBottom, $meColor,2)
	  Global $mobCreature = PixelSearch($mapMaxLeft, $mapMaxTop, $mapMaxRight, $mapMaxBottom, $enemyColor,2)

	  If IsArray($meCreature) Then
		 debug("Me(Creature) found")
		 $foundedMe = True
	  Else
		 debug("Me undetected")
	  EndIf

	  If IsArray($mobCreature) Then
		 debug("Mob(Creature) found")
		 Sleep($sleep)
		 $foundedMob = True
	  Else
		 $maxTry = $maxTry - 1
		 debug("Mob undetected : "& $maxTry)
		 Sleep($sleep)
		 If $maxTry = 0 Then ;repart de Zero au cas ou
			Start()
		 EndIf
	  EndIf
   Until $foundedMob And $foundedMe

   debug("Mob & me found, next step...")
   Sleep($sleep)

   $bar = PixelGetColor(1358, 584) ;check if it's his turn to play
   $spellState = _ImageSearch($imageUrl & $spell) ;check if main spell available state

   If $bar = $barTurnState And IsArray($spellState) Then
	  debug("Turn started + Spell available")
	  Sleep($sleep)

	  $xMeStartPoint = $meCreature[0] - 30 ; To start from the middle of the player case
	  $yMeStartPoint = $meCreature[1] + 40 ; To start from the middle of the player case

	  Local $inRange = PixelSearch($xMeStartPoint - (40 * $Po), $yMeStartPoint - (25 * $Po), $xMeStartPoint + (40 * $Po), $yMeStartPoint + (25 * $Po), $enemyColor, 2)
	  If IsArray($inRange) Then
		 debug("Mob founded in range")
		 $relances = $Pa / $cost
		 $combo = Int($relances)

		 Do
			MouseClick("", $spellState[0], $spellState[1]) ; Click on main spell
			MouseClick("", $inRange[0], $inRange[1] + 5)	; Click a bit too high, so Y is compensated
			$combo = $combo - 1
			debug("Combo : " & $combo &"/"& Int($relances))
		 Until $combo = 0

		 EndTurn()
	  Else
		 Chase()
	  EndIf
   EndIf

   SearchingCoord()
EndFunc

Func Chase()
   debug("Chasing...")
   Sleep($sleep)

   ;TODO (HoPollo) : Implement chasing feature

   EndTurn()
EndFunc

Func EndTurn()
   debug("End turn...")

   Sleep($sleep)

   Local $result = _ImageSearch($imageUrl & $endTurnBtn)
   If IsArray($result) Then MouseClick("", $result[0], $result[1])

   SearchingCoord()
EndFunc

Func ClosePopup()
   debug("Popup detected")

   $cross = _ImageSearch($imageUrl & $closeBtn)
   If Not @error Then MouseClick("", $cross[0], $cross[1])

   Start()
EndFunc

Func ClaimSucces()
   debug("Succes detected")
   $claimed = False
   Sleep($sleep)

   MouseClick("", $9[0], $9[1])

   Do
	  Local $claimBtn = _ImageSearch($imageUrl & $succes[1])
	  If Not @error Then
		 MouseClick("", $claimBtn[0], $claimBtn[1])
		 Sleep($sleep) ; important to wait a bit or the close popup will close it instantly
		 $claimed = True
	  EndIf
   Until $claimed

   Start()
EndFunc

Func Regen()
   info("Healing...")
   ;TODO (HoPollo) : Maybe replace all mouseclick by imagesearch for better accuracy/detection ?
   Local $regen1 = _ImageSearch($imageUrl & "regen1.png")
   If Not @error Then MouseClick("",$regen1[0], $regen1[1])

   Sleep($sleep)

   MouseClick("", 1125, 735)
   Sleep(200)
   MouseClick("", 578, 685)
   $healing = True

   While $healing
	  Sleep(3000)
	  $maxHp = PixelGetColor(1208, 44)
	  If $maxHp = 0xD46B61 Then ExitLoop
   WEnd

   Start()
EndFunc

Func BoostStats()
   info("Stats pts available")
   MouseClick("", 1194, 569) ;Stats
   Sleep(200)
   MouseClick("", 392, 553) ;+ heart(force)
   Sleep(200)
   MouseClick("", 617, 366, 5, 30) ; rigt arrow
   Sleep(200)
   MouseClick("", 628, 480) ; Confirm
EndFunc

Func ExitScript()
   info($reason)
   Sleep($sleep + 1000)

   Exit
EndFunc