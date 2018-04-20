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
#include <ProgressConstants.au3>
#include <StaticConstants.au3>
#include <WindowsConstants.au3>
#include <ScrollBarsConstants.au3>
#include <MsgBoxConstants.au3>
#include <ImageSearch.au3>
#include <GuiEdit.au3>

Global $imageUrl = "/imgs/"
Global $targetImage[] = ["target1.png","target2.png","target3.png"]
Global $spell = "spell.png"
Global $popupCross = "close.png"
Global $succes[] = ["claim1.png","claim2.png"]

Global $meColor = 0x689B00
Global $enemyColor = 0x808090
Global $popupColor = 0x2E2D28

Global $healing = False
Global $specLock = False

Global $debugMode = True
Global $sleep = 250

Global $barTurnState = 0xFFE348
Global $spellAvailableState = 0x92300B

Global $crossPopupColor = 0x4B5C07
Global $fullHp = 0xDA6D62
Global $lowHp = 0x968E7C

Global $mapMaxLeft = 71
Global $mapMaxTop = 36
Global $mapMaxRight = 1155
Global $mapMaxBottom = 737

;Global $mapMax[] = [$mapMaxLeft, $mapMaxRight, $mapMaxTop, $mapMaxBottom]

Global $reason = "Thanks for using this program, see you next time."

HotKeySet ("{ESC}","ExitScript")

Global $Form1 = GUICreate("TouchFarm", 197, 268, 192, 124)
WinSetOnTop($Form1, "", 1)
Global $journal = GUICtrlCreateEdit("", 0, 0, 196, 209, BitOR($ES_AUTOVSCROLL,$ES_READONLY,$WS_VSCROLL))
GUICtrlSetData(-1, "")
GUICtrlSetState(-1, $GUI_DISABLE)
GUICtrlSetCursor (-1, 2)
$GUI_EVENT_START = GUICtrlCreateButton("Start", 56, 240, 75, 25)
GUICtrlCreateLabel("PA | PM", 9, 209, 50)
$GUI_EVENT_PA = GUICtrlCreateInput("6", 10, 222, 15, 16)
$GUI_EVENT_PM = GUICtrlCreateInput("3", 30, 222, 15, 16)
GUICtrlCreateLabel("ATK | PO", 2, 238, 50)
$GUI_EVENT_ATK = GUICtrlCreateInput("3", 10, 251, 15, 16)
$GUI_EVENT_PO = GUICtrlCreateInput("7", 30, 251, 15, 16)
Opt("GUICoordMode", 2)
GUISetCoord(1153, 231)
GUISetState(@SW_SHOW)

Func FreshStart()
   Sleep(100)

   GUICtrlSetData($GUI_EVENT_START, "Start")
   GUICtrlSetState($GUI_EVENT_START, 64)
   GUICtrlSetState($GUI_EVENT_PA, 64)
   GUICtrlSetState($GUI_EVENT_PM, 64)
   GUICtrlSetState($GUI_EVENT_ATK, 64)
   GUICtrlSetState($GUI_EVENT_PO, 64)

   Requierments()
EndFunc

While 1
   $nMsg = GUIGetMsg()
   Switch $nMsg
	  Case $GUI_EVENT_CLOSE
		 ExitScript()
	  Case $GUI_EVENT_START
		 GUICtrlSetData($GUI_EVENT_START, "ESC = exit")
		 GUICtrlSetState($GUI_EVENT_START, 128)
		 GUICtrlSetState($GUI_EVENT_PA, 128)
		 GUICtrlSetState($GUI_EVENT_PM, 128)
		 GUICtrlSetState($GUI_EVENT_ATK, 128)
		 GUICtrlSetState($GUI_EVENT_PO, 128)
		 Requierments()
   EndSwitch
WEnd

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

   $process = ProcessExists("Lindo.exe")
   $lindo = "[TITLE:Lindo]"
   $focus = WinActive($lindo)
   $state = WinGetState($lindo)

   Select
	  Case $process = 0
		 $btn = MsgBox($MB_RETRYCANCEL,"Error","Unable to find : Lindo, make sure you launched it & press OK")
		 If $btn = 1 Then
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

   Start()
EndFunc

Func Start()
   info("Searching...")
   While 1

	  Global $1 = PixelSearch($mapMaxLeft, $mapMaxTop, $mapMaxRight, $mapMaxBottom, $enemyColor, 2)
	  Global $2 = PixelSearch($mapMaxLeft, $mapMaxTop, $mapMaxRight, $mapMaxBottom, $meColor, 2)

	  ; ISSUE : Detection from image is very bad
	  Local $randomImageOfTarget = Random(0, UBound($targetImage)-1, 1)
	  Global $3 = _ImageSearch($targetImage[$randomImageOfTarget], 100, 0)
	  debug("Scan : " & $targetImage[$randomImageOfTarget] & "->" & $3)

	  Global $4 = PixelGetColor(1177, 59) ; HealthColor(middle)

	  Global $6 = PixelSearch(71, 36, 324, 16, $popupColor) ; Left of gamescreen
	  Global $7 = PixelSearch(282, 141, 1128, 647, $popupColor) ; Center of gamescreen
	  Global $8 = PixelGetColor(1357, 585) ; Turn Bar(start from bottom)
	  Global $9 = _ImageSearch($succes[0])

	  If IsArray($1) And IsArray($2) And $8 = 0xFFE348 Then
		 Positionning()
	  ElseIf IsArray($3) Then
         debug("Mob(Image) found")
         AttackTarget()
	  ElseIf $4 = $lowHp And $healing = False Then
		 Regen()
	  ElseIf $4 = $fullHp Then
		 RunAround()
	  ElseIf IsArray($6) Or IsArray($7) Then
		 ClosePopup()
	  ElseIf $8 = 0x1FDDDD Then
		 debug("XpBar detected")
		 Start()
	  ElseIf IsArray($9) Then
		 ClaimSucces()
	  EndIf
   WEnd
EndFunc

Func RunAround()
   info("Running to find...")
   Sleep(250)

   ;TODO (HoPollo) : Implement random map switching
;~    Local $direction = Random(0, UBound($mapMax) - 1, 1)
;~    MouseClick("", $maxMap[$direction])

   Start()
EndFunc

Func AttackTarget()
   info("Fight incoming...")
   Sleep($sleep)

   $times = 0

   Do
	  MouseClick("", $3[0], $3[1])
	  Sleep($sleep)
	  $times = $times + 1
   Until $times = 2

   Start()
EndFunc

Func Positionning()
   info("Combat detected")
   If $specLock = False Then CombatSettings()

   $healing = False
   Sleep($sleep)

   Local $readyBtn = _ImageSearch("readyBtn.png")
   Local $endTurnBtn = _ImageSearch("passBtn.png")

   If IsArray($readyBtn) Then
	  debug("Rdy Btn founded")
	  Sleep($sleep)
	  MouseClick("", $readyBtn[0], $readyBtn[1])
   ElseIf IsArray($endTurnBtn) Then
	  SearchingCoord()
   EndIf

   SearchingCoord()
EndFunc

Func CombatSettings()
   ;ISSUE : Not finding 10/10 Spec Icon
   Sleep($sleep)

   MouseClick("", 1168, 94) ; Develop top menu slider

   $lock = _ImageSearch("specBtn.png")
   Sleep(250)
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
   $spellState = _ImageSearch($spell) ;check if main spell available state

   If $bar = $barTurnState And IsArray($spellState) Then
	  debug("Turn started + Spell available")
	  Sleep($sleep)

	  $xMeStartPoint = $meCreature[0] - 25 ; To start from the middle of the player case
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

   $endTurnBtn = _ImageSearch("passBtn.png")

   If IsArray($endTurnBtn) Then MouseClick("",$endTurnBtn[0], $endTurnBtn[1])

   SearchingCoord()
EndFunc

Func ClosePopup()
   debug("Popup detected")

   $cross = _ImageSearch($popupCross)
   If IsArray($cross) Then MouseClick("", $cross[0], $cross[1])

   Start()
EndFunc

Func ClaimSucces()
   debug("Succes detected")
   $claimed = False
   Sleep($sleep)

   MouseClick("", $9[0], $9[1])

   Do
	  Local $claimBtn = _ImageSearch($succes[1])
	  If IsArray($claimBtn) Then
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
   $healing = False
   Local $regen1 = _ImageSearch("regen1.png")
   If IsArray($regen1) Then MouseClick("",$regen1[0], $regen1[1])

   Sleep($sleep)
   Do
	  $emote1 = PixelGetColor(1125, 735) ; Poeple icon
	  If $emote1 = 0xBADF2F Then
		 MouseClick("", 1125, 735)
		 Sleep($sleep)

		 $emote2 = PixelGetColor(578, 685) ; Chair icon
		 if $emote2 = 0x50321F Then MouseClick("", 578, 685)

		 $healing = True
	  EndIf
   Until $healing

   Start()
EndFunc

Func ExitScript()
   info($reason)
   Sleep($sleep + 1000)

   Exit
EndFunc