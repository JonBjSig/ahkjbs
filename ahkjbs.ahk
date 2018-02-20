#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
#Warn  ; Enable warnings to assist with detecting common errors.
SendMode, Input
StringCaseSense, On
AutoTrim, Off
FileEncoding, UTF-8
#InputLevel, 1

;---TODO---
;Function that populates array from txt file
;---TODO---


;Set NOUSER as starting username to avoid possible null errors
user = NOUSER
;Queries user for username on script startup. Defaults back to JBS if nothing is entered
SetUser(user)

;Set default mouse click positions
CoordMode, Mouse, Screen
MouseClickPosX = 1123
MouseClickPosY = 324

;Mouse position offset values for Status and Due date columns. Sort for sorting by column, detail for filtering
MouseOffsetStatusSort = 45
MouseOffsetStatusDetail = 90
MouseOffsetDuedateSort = -200
MouseOffsetDuedateDetail = -180

;v Misc global variables v
headphoneconnect := True ;Used to alternate between connecting and disconnecting headphones with AltGr+g
atrextopwin := "Atrex" ;Variable to hold the current top atrex window
miscswitch := False ;General purpose boolean variable used to control interrupts, wait periods ect. -WIP-
miscarray := Object() ;General purpose array that functions can use
;^ Misc global variables ^

^!t::
;Inserts time stamp. Format dd.MM.yy - %user% - HH:mm
TimeStamp()
; FormatTime, Date,, dd.MM.yy -{Space}
; FormatTime, hour,, {Space}- HH:mm -
; SendInput %Date%%user%%hour%{Space}
Return

^!j::
;Enter the first job in the job list in a service order and navigate to the internal notes
IfWinNotExist, Atrex Login
{
	IfWinNotExist, Idle Login
	{
		EnterJob("i")
	}
}
Return
^!n::
;Enter the first job in the job list in a service order and navigate to the external notes
IfWinNotExist, Atrex Login
{
	IfWinNotExist, Idle Login
	{
		EnterJob("e")
	}
}
Return

;Contextual command that will close specific Atrex windows if they're open
^!a::
AtrexBack()
Return

;Calibrate mouse click position for SO list automation
^!z::
CalibrateMouseClick(MouseClickPosX, MouseClickPosY)
Return

;Moves the cursor to current set mouse position
^!x::
MouseMove, MouseClickPosX, MouseClickPosY
Return

;Displays message telling the cursor's current position. Also copies current position to clipboard
^!c::
MouseGetPos, currentposx, currentposy
MsgBox, Current mouse position is X%currentposx%,Y%currentposy%
clipboard = %currentposx%, %currentposy%
Return

^!p::
;Prompts user for an invoice number and then prints that invoice to the screen
PrintInvoiceScreen()
Return

^!i::
;Receives SO number as input from user. Sets reference and technician to %user% variable. Sets due date to current date
;Script will stop and cancel if the service order already has a user registered
If (AtrexSafeWin() == True)
{
	ClaimSO()
}
Return

;v*SO list sorting*v
^!o::
ViewUserSO()
Return

^!h::
;Shows user's open service orders that are marked "Hringja", ordered by due date
If (AtrexSafeWin() == True)
{
	ViewHringja()
}
Return

^!e::
IfWinActive, Customer Service History
{
	;If the user has a Customer Service History window active then the hotkey will open the currently selected service order
	SendInput {AppsKey}e
	IfWInExist, Customer Information
	{
		WinClose, Customer Information
	}
}
Else
{
	;If the user doesn't have a Custoemr Service History window active the hotkey will show unclaimed service orders, ordered by due date
	If (AtrexSafeWin() == True)
	{
		ViewUnclaimed()
	}
}
Return
;^*SO list sorting*^

^!s::
;Searches Atrex for invoices with a specific S/N
If (AtrexSafeWin() == True)
{
	SearchInvoiceSN()
}
Return

^!k::
;Shows customer's sales history since current date in the year 2000
CustSalesHistory()
Return

^!l::
;Shows customer's service history since current date in the year 2000
CustServiceHistory()
Return

^!g::
;Tell Windows to connect wireless headphones
WinGet, activewindow,, A
IfWinExist, Sound
{
	WinActivate, Sound
}
Else
{
	Run control mmsys.cpl sounds
	If (WaitForWindow("Sound") == True)
	{
		WinActivate, Sound
	}
	else
	{
		Return
	}
}
If (headphoneconnect == True)
{
    SendInput {Home}{AppsKey}{Down 2}{Enter}
    SendInput {Down}{AppsKey}{Down 2}{Enter}
    headphoneconnect := False
}
Else
{
    SendInput {Home}{AppsKey}{Down 3}{Enter}
    SendInput {Down}{AppsKey}{Down 3}{Enter}
    headphoneconnect := True
}
Sleep 250
WinActivate ahk_id %activewindow%
Return

;Set current username
^!u::
SetUser(user)
Return

^!r::
;Reload script
MsgBox, 4,, Would you like to reload the script? (press Yes or No)
IfMsgBox Yes
{
    Reload
	Sleep 1000
	MsgBox, Script could not be reloaded
}
Else
{
	Return
}
Return

^!f::
;Takes selected text and makes all characters at the beginning of words uppercase
;If all words in the text are already uppercase the function will make the whole text uppercase
strtoupper =
CopyToVariable(strtoupper)
If (strtoupper != "")
{
    length := StrLen(strtoupper)
    strtoupper := MakeUpper(strtoupper)
    SendInput %strtoupper%{LShift down}{left %length%}{LShift up}
}
Return

^!v::
;Activates the Atrex window the user is most likely to want
SendLevel, 0
SendInput {RAlt down}{RAlt up}
SendLevel, 1
SendInput {RAlt down}{RAlt up}
Return

^!b::
;-TESTING HOTKEY-
;
;-TESTING HOTKEY-
Return

^!.:: ;Inserts a ● character
SendInput, ●
Return

^!,::
;Shows all the user's service orders that have the due date set to today
ShowDueToday()
Return

;v Colon functions v
:::jobdoneprep::
;Calls the JobComplete() function to prep the service order for completion
Sleep 100
JobComplete()
Return

:::hringjaprep::
;Calls the function HringjaPrep() to prep a service order for the Hringja status
Sleep 100
HringjaPrep() ;Regular Hringja status, no string is passed to function
Return
:::hringjaprepflyti::
;Calls the function HringjaPrep() to prep a service order for the Hringja status
Sleep 100
HringjaPrep(" - F") ;Express service, function is passed the string " - F"
Return
:::hringjaprepcomplete::
;Calls the function HringjaPrep() to prep a service order for the Hringja status
Sleep 100
HringjaPrep(" - T") ;Complete job, function is passed the string " - T"
Return

;v Hringja mail v
:::hringjaf::
HringjaMail(" - F", "F")
Return
:::hringjaft::
HringjaMail(" - T", "F")
Return
:::hringjaff::
HringjaMail(" - F", "FF")
Return
:::hringjafft::
HringjaMail(" - T", "FF")
Return
:::hringjav::
HringjaMail("", "V")
Return
:::hringjavt::
HringjaMail(" - T", "V")
Return
:::hringjafor::
HringjaMail("", "FOR")
Return
:::hringjafort::
HringjaMail(" - T", "FOR")
Return
;^ Hringja mail ^

:*::ddold::
;---WIP---
;Calls the DueDateOld() function to increment due dates of specific service orders to the next weekday
IfWinExist, Run
{
	WinClose, Run
}
If (AtrexSafeWin() == True)
{
	DueDateOld()
}
Return

:*::ddupdate::
;---WIP---
;Calls the DueDateUpdate() function to increment due dates of specific service orders to the next weekday
IfWinExist, Run
{
	WinClose, Run
}
If (AtrexSafeWin() == True)
{
	IfWinNotExist, Open Service Order Selection
	{
		;Function will not clear away windows if user already has an Open Service Order Selection window open. This is to allow the user to have a custom list of service orders to update
		AtrexFreeUser()
		ShowDueToday()
	}
	IfExist, soNumList.exe
	{
		Run soNumList.exe
		Sleep 1000
		Loop
		{
			IfWinExist, Service Orders
			{
				Sleep 250
			}
			Else
			{
				Break
			}
		}
		If (AtrexSafeWin() == True)
		{
			DueDateTextFile("soList.txt")
		}
	}
}
Else
{
	MsgBox, Please close all unnecessary atrex windows before continuing!
}
Return

:::calc::
IfWinActive, Run
{
	SendInput {Esc}
}
Sleep 100
IfWinExist, Calculator
{
	WinActivate, Calculator
}
Else
{
	Run, calc
}
Return
:::ivinnslu::
Sleep 100
StatusUpdate("Í Vinnslu")
Return
;^ Colon functions ^

;v Text inputs v
:::pmagic::
SendInput Tölvan var ræst upp í Linux stýrikerfi þar sem sérhæfður hugbúnaður var notaður til að meta ástand geymsludrifa tölvunnar.
Return
:::memtestok::
SendInput Vinnsluminni tölvunnar var villuprófað og komu þar fram engar villur.
Return
:::memtestfokk::
sleep 200
InputBox, memerror,, How many memtest errors?
SendInput Vinnsluminni tölvunnar var villuprófað og komu þar fram %memerror% villur áður en tæknimaður stöðvaði prófið.
Return
:::memtestthermalkill::
SendInput Tölvan var látin framkvæma villupróf á vinnsluminni en tölvan drap á sér vegna ofhitnunar áður en tókst að klára prófið.
Return
:::capsplode::
Sleep 200
InputBox, deadcaps,, How many dead capacitors?
SendInput Móðurborð tölvunnar var skoðað og fundust þar %deadcaps% bólgnir/sprungnir þéttar.
Return
:::mcafeedontknow::
SendInput Veit ekki hvað vv er með en hann hefur allavega ekki keypt McAfee hjá okkur
Return
:::win10setup::
SendInput Windows 10 Home er sett upp á tölvunni og virkt í gegnum sjálfvirkt kerfi hjá Microsoft. Allir viðeigandi reklar eru settur upp á tölvunni ásamt nýjustu uppfærslum fyrir stýrikerfið.
Return
:::rykthermal::
SendRaw Ryk+thermal framkvæmt.
Return
:::rykthermalplus::
SendInput Tölvan var opnuð og örgjörvakælingin fjarlægð. Hitaleiðandi efni var þrifið undan örgjörvakælingunni og tölvan svo rykhreinsuð með þrýstilofti. Örgjörvakælingin var síðan sett aftur í sinn stað með nýju hitaleiðandi efni.
Return
:::rykthermalaccept::
SendInput Viðskiptavinur samþykkir kaup á vinnu við að rykhreinsa tölvuna og endurnýja hitaleiðandi efni undir örgjörvakælingu.
Return
:::jobdone::
SendInput Klára skýrslu, set verkið í tilbúið hillu og merki Hringja - T.
Return
:::borðdone::
SendInput Klára skýrslu, set tölvuna í tilbúið hillu og merki Hringja - T.
Return
:::fartdone::
SendInput Klára skýrslu, set fartölvuna í tilbúið hillu og merki Hringja - T.
Return
:::spjalddone::
SendInput Klára skýrslu, set spjaldtölvuna í tilbúið hillu og merki Hringja - T.
Return
:::wonlexdone::
SendInput Klára skýrslu, set úrið í tilbúið hillu og merki Hringja - T.
Return
:::wonlexrma::
SendInput Klára skýrslu, set verkbeiðnina í tilbúið hillu og læt NLA fá úrið fyrir innborgun á verk. Þegar skil á úri eru kláruð má setja verk í Hringja - T.
Return
:::wonlexrma+sim::
SendInput Klára skýrslu, set verkbeiðnina í tilbúið hillu ásamt SIM korti og læt NLA fá úrið fyrir innborgun á verk. Þegar skil á úri eru kláruð má setja verk í Hringja - T.
Return
:::aida::
Sleep 200
InputBox, idletemp,, Enter idle temperature
InputBox, maxtemp,, Enter maximum temperature
SendInput Tölvan var látin keyra álagspróf til að meta stöðugleika og hitamyndun. Undir litlu álagi er hitastig örgjörva í kring um %idletemp%°C. Undir álagi fer hitastig örgjörva upp í %maxtemp%°C.
;Script will automatically append a generalized "opinion" on the computer's max temperature based on the input value
If (maxtemp > 85){
	SendInput {Space}Þessar hitamælingar eru vel yfir ráðlagt hámark frá framleiðanda. Hér er nauðsynlegt að grípa til aðgerða áður en skemmdir verða á dýrum vélbúnaði.
}
If (maxtemp < 85) and (maxtemp > 75){
	SendInput {Space}Örgjörvakæling tölvunnar er ekki að ná að halda hitastigi örgjörvans undir ásættanlegum mörkum. Svona hátt hitastig hefur neikvæð áhrif á afköst tölvunnar og getur mögulega valdið skaða í íhlutum tölvunnar.
}
If (maxtemp < 75) and (maxtemp > 60){
	SendInput {Space}Hitastig á þessum mörkum er ásættanlegt en samt ábótavant. Lækka má hitastig örgjörvans með því að rykhreinsa tölvuna, endurnýja hitaleiðandi efni milli örgjörva og kælingu eða uppfæra í afkastameiri örgjö0rvakælingu.
}
If (maxtemp < 60){
	SendInput {Space}Hitastig örgjörvans er á góðu bili.
}
Return
:::thermal::
Sleep 200
InputBox, temp,, Enter temperature
SendInput Þegar prófið var í vinnslu fór hitastig örgjörvans upp í %temp%°C.
If (temp > 85){
	SendInput {Space}Þessar hitamælingar eru vel yfir ráðlagt hámark frá framleiðanda. Hér er nauðsynlegt að grípa til aðgerða áður en skemmdir verða á dýrum vélbúnaði.
}
If (temp < 85) and (temp > 75){
	SendInput {Space}Örgjörvakæling tölvunnar er ekki að ná að halda hitastigi örgjörvans undir ásættanlegum mörkum. Svona hátt hitastig hefur neikvæð áhrif á afköst tölvunnar og getur mögulega valdið skaða í íhlutum tölvunnar.
}
If (temp < 75) and (temp > 50){
	SendInput {Space}Hitastig á þessum mörkum er ásættanlegt en samt ábótavant. Lækka má hitastig örgjörvans með því að rykhreinsa tölvuna, endurnýja hitaleiðandi efni milli örgjörva og kælingu eða uppfæra í afkastameiri örgjö0rvakælingu.
}
If (temp < 50){
	SendInput {Space}Hitastig örgjörvans er á góðu bili.
}
Return
:::uppfaersla::
SendInput ● Mobo: `r● CPU: `r● RAM: `r● GPU: `r● SSD: `r● PSU: `rSamtals:{Space}
Return
:::samband::
SendInput Haft var samband við viðskiptavin og tjáð ástand tölvunnar.{Space}
Return
; :::listold:: ;-WIP-
; ;Calls the ListBuilderOld() function to insert a list
; Sleep 100
; WinGet, activewindow,, A
; newlist := ListBuilderOld()
; WinActivate ahk_id %activewindow%
; SendInput %newlist%
; Return
:::list::
;Calls the ListBuilderOld() function to insert a list
Sleep 100
WinGet, activewindow,, A
newlist := ListBuilder()
WinActivate ahk_id %activewindow%
SendInput %newlist%
Return
;^ Text inputs ^

;v Key takeover v
;TODO: Win+L also close atrex

Esc::
;Making the Escape key close ahk windows
IfWinActive, ahkjbs.ahk
{
	AtrexBack()
	Return
}
IfWinActive, Hefja verk
{
	WinClose, Hefja verk
	Return
}
IfWinActive, Calculator
{
	WinCLose, Calculator
	Return
}
IfWinActive, Customer Sales History
{
	AtrexBack()
	Return
}
IfWinActive, Customer Service History
{
	AtrexBack()
	Return
}
Else
{
	SendLevel, 0
	SendInput {Esc}
	SendLevel, 1
}
Return

+F2::
;Takes over the Shift+F2 key combo so it works in more situations and also automatically activates atrex before running
IfWinExist, Atrex
{
	IfWinNotExist, Atrex Login
	{
		IfWinNotExist, Idle Login
		{
			IfWinExist, Stock Code
			{
				IfWinExist, Stock Code Entry
				{
					WinActivate, Stock Code Entry
					Sleep 100
				}
				IfWinExist, Stock Code Selection
				{
					WinActivate, Stock Code Selection
					SendInput {LAlt down}s{LAlt up}{LCtrl down}a{LCtrl up}
				}
				Return
			}
			IfWinExist, Container Customization
			{
				IfWinNotExist, Container Item Information
				{
					WinActivate, Container Customization
					SendInput, {LAlt down}i{LAlt up}
				}
			}
			Else
			{
				IfWinExist, SO Job Information
				{
					WinActivate, SO Job Information
					SendInput {LAlt down}a{LAlt up}
					Sleep 100
				}
				Else
				{
					IfWinExist, Order Creation/Editing
					{
						WinActivate, Order Creation/Editing
						SendInput {LAlt down}l{LAlt up}
						Sleep 100
					}
					Else
					{
						IfWinExist, Invoice Creation/Editing
						{
							WinActivate, Invoice Creation/Editing
							SendInput {LAlt down}l{LAlt up}
							Sleep 100
						}
						Else
						{
							AtrexFreeUser()
							atrextopwin := AtrexTopCrawl()
							WinActivate, %atrextopwin%
							SendLevel, 0
							SendInput {LShift down}{F2}{LShift up}
							SendLevel, 1
							Return
						}
					}
				}
				IfWinExist, Stock Code
				{
					IfWinExist, Stock Code Entry
					{
						WinActivate, Stock Code Entry
						Sleep 100
					}
					IfWinExist, Stock Code Selection
					{
						WinActivate, Stock Code Selection
						SendInput {LAlt down}s{LAlt up}{LCtrl down}a{LCtrl up}
					}
					Return
				}
				Else
				{
					SendInput {LAlt down}i{LAlt up}
				}
			}
		}
	}
}
else
{
	SendLevel, 0
	SendInput, {LShift down}{F2}{LShift up}
	SendLevel, 1
}
Return

+!F8::
;Takes over the Shift+Alt+F8 key combo and makes it work in more situations and also automatically activates atrex before running
If (AtrexSafeWin() == True)
{
	atrextopwin := AtrexTopCrawl()
	WinActivate, %atrextopwin%
	AtrexFreeUser()
	IfWinExist, Open Service Order Selection
	{
		WinClose, Open Service Order Selection
	}
	atrextopwin := AtrexTopCrawl()
	WinActivate, %atrextopwin%
}
SendLevel, 0
SendInput {LShift down}{LAlt down}{F8}{LAlt up}{LShift up}
SendLevel, 1
Return

!F8::
;Takes over the Alt+F8 key combo and makes it work in more situations and also automatically activates atrex before running
If (AtrexSafeWin() == True)
{
	atrextopwin := AtrexTopCrawl()
	WinActivate, %atrextopwin%
	AtrexFreeUser()
	IfWinExist, Open Service Order Selection
	{
		WinClose, Open Service Order Selection
	}
	atrextopwin := AtrexTopCrawl()
	WinActivate, %atrextopwin%
}
SendLevel, 0
SendInput {LAlt down}{F8}{LAlt up}
SendLevel, 1
Return

+^F5::
;Takes over the Ctrl+Shift+F8 key combo and makes it work in more situations and also automatically activates atrex before running
If (AtrexSafeWin() == True)
{
	IfWinNotExist, Invoice Creation/Editing
	{
		AtrexFreeUser()
		atrextopwin := AtrexTopCrawl()
		WinActivate, %atrextopwin%
	}
	Else
	{
		WinActivate, Invoice Creation/Editing
		Return
	}
}
SendLevel, 0
SendInput {LCtrl down}{LShift down}{F5}{LShift up}{LCtrl up}
SendLevel, 1
Return

!F6::
;Takes over the Alt+F6 key combo and makes it work in more situations and also automatically activates atrex before running
If (AtrexSafeWin() == True)
{
	IfWinNotExist, Order Number Entry
	{
		IfWinNotExist, Open Order Selection
		{
			AtrexFreeUser()
			atrextopwin := AtrexTopCrawl()
			WinActivate, %atrextopwin%
		}
		Else
		{
			WinActivate, Open Order Selection
			Return
		}
	}
	Else
	{
		WinActivate, Order Number Entry
		Return
	}
}
SendLevel, 0
SendInput {LAlt down}{F6}{LAlt up}
SendLevel, 1
Return

+F4::
;Takes over the Ctrl+F4 key combo and makes it automatically activate atrex before running
If (AtrexSafeWin() == True)
{
	atrextopwin := AtrexTopCrawl()
	WinActivate, %atrextopwin%
}
SendLevel, 0
SendInput {LCtrl down}{F4}{LCtrl up}
SendLevel, 1
Return
;^ Key takeover ^

;v Code editor shortcuts v
:*:{LAlt down}::
laltbrackets := "{LAlt down}{LAlt up}"
SendRaw %laltbrackets%
SendInput {Left 9}
Return
:*:{RAlt down}::
laltbrackets := "{RAlt down}{RAlt up}"
SendRaw %laltbrackets%
SendInput {Left 9}
Return
:*:{LShift down}::
laltbrackets := "{LShift down}{LShift up}"
SendRaw %laltbrackets%
SendInput {Left 11}
Return
:*:{RShift down}::
laltbrackets := "{RShift down}{RShift up}"
SendRaw %laltbrackets%
SendInput {Left 11}
Return
:*:{LCtrl down}::
lctrlbrackets := "{LCtrl down}{LCtrl up}"
SendRaw %lctrlbrackets%
SendInput {Left 10}
Return
:*:{RCtrl down}::
rctrlbrackets := "{RCtrl down}{RCtrl up}"
SendRaw %rctrlbrackets%
SendInput {Left 10}
Return
;^ Code editor shortcuts ^

;v LuaMacros numpad v

F13:: ;Num0
If (LuaKeyToggle() == "fkey")
{
	ViewUserSO()
}
Else If (LuaKeyToggle() == "numpad")
{
	SendInput {Numpad0}
}
Else
{
	ViewUserSO()
}
Return

F14:: ;Num1
If (LuaKeyToggle() == "fkey")
{
	;Function TBD
}
Else If (LuaKeyToggle() == "numpad")
{
	SendInput {Numpad1}
}
Else If (LuaKeyToggle() == "dpad")
{
	IfWinActive, Open Service Order Selection
	{
		SendInput {End}
	}
	Else
	{
		EnterJob("i")
	}
}
Else
{
	SendInput {End}
}
Return

F15:: ;Num2
If (LuaKeyToggle() == "fkey")
{
	;Function TBD
}
Else If (LuaKeyToggle() == "numpad")
{
	SendInput {Numpad2}
}
Else
{
	SendInput {Down}
}
Return

F16:: ;Num3
If (LuaKeyToggle() == "fkey")
{
	IfWinNotExist, Atrex Login
	{
		IfWinNotExist, Idle Login
		{
			EnterJob("i")
		}
	}
}
Else If (LuaKeyToggle() == "numpad")
{
	SendInput {Numpad3}
}
Else If (LuaKeyToggle() == "dpad")
{
	IfWinActive, ahkjbs.ahk
	{
		SendInput {LCtrl down}v{LCtrl up}
		Return
	}
	IfWinExist, Service Order Creation/Editing
	{
		EnterJob("i")
	}
	Else
	{
		SendInput {PgDn}
	}
}
Else
{
	;Function TBD
}
Return

F17:: ;Num4
If (GetKeyState("NumLock", "T") == True)
{
	If (LuaKeyToggle() == "fkey")
	{
		SendInput {Left}
	}
	Else If (LuaKeyToggle() == "numpad")
	{
		SendInput {Numpad4}
	}
	Else
	{
		SendInput {Left}
	}
}
Else
{
	SendInput {LCtrl down}{LWin down}{Left}{LWin up}{LCtrl up}
}
Return

F18:: ;Num5
If (LuaKeyToggle() == "fkey")
{
	;Function TBD
}
Else If (LuaKeyToggle() == "numpad")
{
	SendInput {Numpad5}
}
Else If (LuaKeyToggle() == "dpad")
{
	IfWinActive, SO Job Information
	{
		TimeStamp()
	}
	IfWinActive, Container Customization
	{
		SendInput {LAlt down}e{LAlt up}
	}
}
Else
{
	;Function TBD
}
Return

F19:: ;Num6
If (GetKeyState("NumLock", "T") == True)
{
	If (LuaKeyToggle() == "fkey")
	{
		SendInput {Right}
	}
	Else If (LuaKeyToggle() == "numpad")
	{
		SendInput {Numpad6}
	}
	Else
	{
		SendInput {Right}
	}
}
Else
{
	SendInput {LCtrl down}{LWin down}{Right}{LWin up}{LCtrl up}
}
Return

F20:: ;Num7
If (LuaKeyToggle() == "fkey")
{
	PrintInvoiceScreen()
}
Else If (LuaKeyToggle() == "numpad")
{
	SendInput {Numpad7}
}
Else If (LuaKeyToggle() == "dpad")
{
	SendInput {LCtrl down}{Home}{LCtrl up}
}
Else
{
	SendInput {Home}
}
Return

F21:: ;Num8
If (GetKeyState("NumLock", "T") == True)
{
	If (LuaKeyToggle() == "fkey")
	{
		If (AtrexSafeWin() == True)
		{
			SearchInvoiceSN()
		}
	}
	Else If (LuaKeyToggle() == "numpad")
	{
		SendInput {Numpad8}
	}
	Else
	{
		SendInput {Up}
	}
}
Else
{
	SendInput {LWin down}{Tab}{LWin up}
}
Return

F22:: ;Num9
If (LuaKeyToggle() == "fkey")
{
	;Add a line comment to a piece of code
	IfWinActive, Visual Studio Code
	{
		SendInput {LCtrl down}kc{LCtrl up}
		Return
	}
	IfWinActive, Service Order Creation/Editing
	{
		StatusUpdate("Í Vinnslu")
		Return
	}
}
Else If (LuaKeyToggle() == "numpad")
{
	SendInput {Numpad9}
}
Else If (LuaKeyToggle() == "dpad")
{
	SendInput {PgUp}
}
Else
{
	;Function TBD
}
Return

F23:: ;NumSub
If (LuaKeyToggle() == "fkey")
{
	;Add a line comment to a piece of code
	IfWinActive, Service Order Creation/Editing
	{
		If (GetKeyState("NumLock", "T") == True)
		{
			;If numlock is active the hotkey will change the SO status to "Í Vinnslu"
			SendInput {LAlt down}gu{LAlt up}Í Vinnslu{Enter}{Right}
		}
		Else
		{
			;If numlock is inactive the hotkey will change the SO due date to the next weekday
			DueDateOld(0, False, True)
		}
		Return
	}
	Else
	{
		atrextopwin := AtrexTopCrawl()
		WinActivate, %atrextopwin%
		If (GetKeyState("NumLock", "T") == True)
		{
			If (atrextopwin == "Atrex")
			{
				AtrexFreeUser()
				ClaimSO()
			}
		}
	}
}
Else If (LuaKeyToggle() == "numpad")
{
	SendInput {NumpadSub}
}
Else
{
	;Function TBD
}
Return

F24:: ;NumPlus
;TODO: Help and info for luamacros numpad
luamacroshelp =
(
	● Numpad 0 : View user's open service orders.`r
	● Numpad 1 : If user has an Atrex list window of some kind active: End key.`r
	● Numpad 2 : If user has an Atrex list window of some kind active: Down.`r
	● Numpad 3 : EnterJob() function.`r
	● Numpad 4 : If user has an Atrex list window of some kind active: Left. Is Numlock is off: Ctrl+Win+Left.`r
	● Numpad 5 : Function TBD`r
	● Numpad 6 : If user has an Atrex list window of some kind active: Right. Is Numlock is off: Ctrl+Win+Right.`r
	● Numpad 7 : If user has an Atrex list window of some kind active: Home key. Otherwise: PrintInvoiceScreen() function.`r
	● Numpad 8 : If user has an Atrex list window of some kind active: Up. Otherwise: SearchInvoiceSN() function.`r
	● Numpad 9 : If user has a Visual Studio Code window active: Enclose code with line comments`r
	● Numpad - : If user is in SO Job Information: Set SO status to 'Í Vinnslu'. If no job is open: ClaimSO() function.`r
	● Numpad + : Show this help message.`r
	● Numpad Del : AtrexBack() function.`r
)
If (LuaKeyToggle() == "fkey")
{
	MsgBox, %luamacroshelp%
}
Else If (LuaKeyToggle() == "numpad")
{
	If (GetKeyState("NumLock", "T") == True)
	{
		;Function TBD
	}
}
Else If (LuaKeyToggle() == "none")
{
	;Function TBD
}
Else
{
	MsgBox, %luamacroshelp%
}
Return

+F22::
SendInput {Media_Play_Pause}
Return

+F23::
IfWinNotActive, Calculator
{
	SendInput {Enter}
}
Return

+F24::
If (LuaKeyToggle() == "fkey")
{
	AtrexBack()
}
Else If (LuaKeyToggle() == "numpad")
{
	If (GetKeyState("NumLock", "T") == True)
	{
		IfWinNotActive, ahkjbs.ahk
		{
			SendInput {NumpadDot}
		}
		Else
		{
			AtrexBack()
		}
	}
}
Else
{
	AtrexBack()
}
Return

;^ LuaMacros numpad ^

;v Functions v
TimeStamp(){
	;Inserts time stamp. Format dd.MM.yy - %user% - HH:mm
	Global Date
	Global hour
	Global user
	FormatTime, Date,, dd.MM.yy -{Space}
	FormatTime, hour,, {Space}- HH:mm -
	SendInput %Date%%user%%hour%{Space}
	Return
}
EnterJob(jobdestination){
	;Enters the top job in service order. If a job is open script will go to internal notes (Indications/Problem)
	;Function takes the variable jobdestination. It should be either "i" for internal notes or "e" for external notes
	IfWinExist, Atrex
	{
		IfWinNotExist, SO Job Information
		{
			;If the SO Job Information window is already open the function will not try to open it again
			;When EnterJob() function is called it will wait for the Service Order Creation/Editing window to appear or until it times out
			If (WaitForWindow("Service Order Creation/Editing") == True)
			{
				AtrexFreeUser() ;Closes any interfering windows before continuing
				IfWinExist, Confirm
				{
					WinActivate, Confirm
					SendInput {Esc}
				}
				WinActivate, Service Order Creation/Editing
				SendInput {LAlt down}je%jobdestination%{LAlt up}
				IfWinExist, SO Quote Number Entry
				{
					AtrexBack()
				}
				Else
				{
					SendInput {LCtrl down}{End}{LCtrl up}
				}
				Sleep 100
			}
		}
		Else
		{
			AtrexFreeUser()
			IfWinNotActive, SO Job Information
			{
				;If the SO Job Information window is open but not active the function will activate it
				WinActivate, SO Job Information
			}
			;If the SO Job Information window is open and active the function will navigate the the bottom of the Indications/Problem text box
			SendInput {LAlt down}j%jobdestination%{LAlt up}
			SendInput {LCtrl down}{End}{LCtrl up}
		}
		Sleep 100
	}
}
AtrexBack(delay := 0){ ;AtrexBack function, comment is here for ctrl+f use
	;Contextual command that will close specific Atrex windows if they're open
	;-WIP-Add to function-WIP-:
	;
	;-WIP-Add to function-WIP-:
	Sleep delay ;Optional delay timer for the function
	IfWinExist, ahkjbs.ahk
	{
		WinActivate, ahkjbs.ahk
		WinClose, ahkjbs.ahk
		Sleep 100
		Return
	}
	IfWinExist, Hefja verk
	{
		WinCLose, Hefja verk
		Return
	}
	IfWinExist, Atrex
	{
        IfWinExist, Print Preview
        {
            ;If a print preview window is open and is still working the function will activate it and Return
            WinActivate, Print Preview
			SendInput {Esc}
			Sleep 100
            Return
        }
		IfWinExist, Invoice - Laser/Inkjet
		{
			;If a print preview window is open and has finished working the function will close it and Return
			WinActivate, Invoice - Laser/Inkjet
			SendInput {Esc}
			Sleep 100
			Return
		}IfWinExist, Service Order- Laser/Inkjet
		{
			;If a print preview window is open and has finished working the function will close it and Return
			WinActivate, Service Order- Laser/Inkjet
			SendInput {Esc}
			Sleep 100
			Return
		}
		IfWinExist, Stock Code Sales History
		{
			WinActivate, Stock Code Sales History
			SendInput {LAlt down}c{LAlt up}
			Sleep 100
			Return
		}
		IfWinExist, Notes for Stock Code
		{
			WinClose, Notes for Stock Code
			Sleep 100
			Return
		}
		IfWinExist, View Stock Code Information
		{
			WinActivate, View Stock Code Information
			SendInput {LAlt down}c{LAlt up}
			Sleep 100
			AtrexBack()
			Return
		}
		IfWinExist, SO Quote Number Entry
		{
			;The SO Quote Number Entry window typically appears if the ClaimSO function is used on a service order that doesn't already have a job in the jobs list
			;If this window exists the function will close it
			WinActivate, SO Quote Number Entry
			SendInput {Esc}
			Sleep 100
			Return
		}
		IfWinExist, SO Number Entry
		{
			WinActivate, SO Number Entry
			SendInput {Esc}
			Sleep 100
			Return
		}
		IfWinExist, Stock Code
		{
			;If a stock code entry or stock code selection window is open the function will close it
			WinActivate, Stock Code
			SendInput {Esc}
			IfWinExist, SO Job Information
			{
				;If an SO Job Information window is open after the stock code entry window closes the script will activate it
				Sleep 100
				WinActivate, SO Job Information
			}
			Sleep 100
			IfWinExist, Stock Code
			{
				AtrexBack(100)
			}
			Return
		}
		IfWinExist, Serial Number Entry
		{
			;If a Serial Number Entry Window is open the function will close it and return
			WinActivate, Serial Number Entry
			SendInput {Esc}
			AtrexBack(100)
			Return
		}
		IfWinExist, Multiple Serial Number Entry
		{
			;If a Multiple Serial Number Entry window is open the function will close it and then run again
			WinActivate, Multiple Serial Number Entry
			SendInput {Esc}
			AtrexBack(100)
			Return
		}
		IfWinExist, Serial Number Processing
		{
			;If a Serial Number Processing window is open the function will close it and then run again
			WinActivate, Serial Number Processing
			SendInput {Enter}
			AtrexBack(100)
			Return
		}
		IfWinExist, SO Item Information
		{
			;If an SO Item Information window is open the function will close it and return
			WinActivate, SO Item Information
			SendInput {LAlt down}q{LAlt up}{Enter}
			Sleep 100
			IfWinExist, Warning
			{
				WinActivate, Warning
				SendInput {Enter}
				Sleep 100
			}
			Return
		}
		IfWinExist, Container Item Information
		{
			;If a Container Item Information window is open the function will close it and return
			WinActivate, Container Item Information
			SendInput {LAlt down}a{LAlt up}{Enter}
			Sleep 100
			Return
		}
		IfWinExist, Container Customization
		{
			;If a Container Customization window is open the function will close it and return
			WinActivate, Container Customization
			WinClose, Container Customization
			Sleep 100
			IfWinExist, Confirm
			{
				WinActivate, Confirm
				SendInput {Enter}
				Sleep 100
			}
			Return
		}
		IfWinExist, Customer Service History
		{
			;If Customer Sales History window is open the command will close it to Return to the main page of the open service order. Function then Returns
			WinActivate, Customer Service History
			SendInput {LAlt down}c{LAlt up}
			IfWinExist, Customer Information
			{
				AtrexBack()
			}
			Sleep 100
			Return
		}
		IfWinExist, Customer Sales History
		{
			;If Customer Sales History window is open the command will close it to Return to the main page of the open service order. Function then Returns
			WinActivate, Customer Sales History
			SendInput {LAlt down}c{LAlt up}
			IfWinExist, Customer Information
			{
				AtrexBack()
			}
			Sleep 100
			Return
		}
		IfWinExist, Customer Information
		{
			;If Customer Information window is open the function will close it
			WinActivate, Customer Information
			SendInput {Esc}
			IfWinExist, Service Order Creation/Editing
			{
				;If the user opened the Customer Information window from the Service Order Creation/Editing window the function will Return the user to the service order main page
				WinActivate, Service Order Creation/Editing
				SendInput {LAlt down}agh{LAlt up}
			}
            Sleep 100
			Return
		}
		IfWinExist, View Customer Information
		{
			;If a View Customer Information window is open the function will close it
			WinActivate, View Customer Information
			SendInput {LAlt down}c{LAlt up}
            Sleep 100
			Return
		}
		IfWinExist, Open Order Selection
		{
			WinActivate, Open Order Selection
			SendInput {Esc}
			Sleep 100
			Return
		}
		IfWinExist, Open Service Order Selection
		{
			;If the Open Service Order Selection window is open the function will close it and return
			WinActivate, Open Service Order Selection
			SendInput {Esc}
			Sleep 100
			Return
		}
		IfWinExist, Invoice Creation/Editing
		{
			WinActivate, Invoice Creation/Editing
			SendInput {Esc}{Enter}
			Sleep 100
			Return
		}
		IfWinExist, Order Creation/Editing
		{
			WinActivate, Order Creation/Editing
			SendInput {Esc}{Enter}
			Sleep 100
			Return
		}
		IfWinExist, Service Order Creation/Editing
		{
			IfWinExist, SO Job Information
			{
				;If user has SO Job Information window open the function will save changes and close to service order main window
				WinActivate, SO Job Information
				SendInput {LAlt down}ja{LAlt up}
				SendInput {Enter}
				SendInput {LAlt down}gh{LAlt up}
				Sleep 100
				IfWinExist, SO Job Information
				{
					Sleep 250
					IfWinExist, Stock Code Entry
					{
						WinActivate, Stock Code Entry
						SendInput {Esc}
						Sleep 100
						WinActivate, SO Job Information
						SendInput {Enter}
						SendInput {LAlt down}gh{LAlt up}
						Sleep 100
					}
				}
				Return
			}
			Else
			{
				;If user has a service order open but not the SO Job Information window the function will save changes and close service order
				WinActivate, Service Order Creation/Editing
				SendInput {LAlt down}jg{LAlt up}
				SendInput {Enter 2}
				If (WaitForWindow("Confirm") == True)
				{
					SendInput {Escape}
				}
				Sleep 100
				Return
			}
		}
	}
}
ViewUserSO(){
	;Show user's service orders, ordered by status
	Global MouseClickPosX
	Global MouseClickPosY
	Global MouseOffsetStatusSort
	Global user
	Global atrextopwin
	AtrexFreeUser()
	If (AtrexSafeWin() == True)
	{
		;Script will not run if user is in SO Job Information Screen
		IfWinExist, Open Service Order Selection
		{
			WinClose, Open Service Order Selection
		}
		atrextopwin := AtrexTopCrawl()
		WinActivate, %atrextopwin%
		SendLevel, 0
		SendInput {LShift down}{LAlt down}{F8}{LShift up}{LAlt up}
		If (WaitForWindow("Open Service Order Selection") == True)
		{
			WinActivate, Open Service Order Selection
			MouseClick, left, MouseClickPosX, MouseClickPosY
			Sleep 100
			SendInput %user%{Space}
			Sleep 100
			MouseClick, left, MouseClickPosX + MouseOffsetStatusSort, MouseClickPosY
			Sleep 100
			SendInput {End}
		}
		SendLevel, 1
	}
	Else
	{
		;If AtrexSafeWin() returns False the function activates the top Atrex window
		atrextopwin := AtrexTopCrawl()
		WinActivate, %atrextopwin%
	}
}
ViewHringja(){
	;Shows user's open service orders that are marked "Hringja", ordered by due date
	Global MouseClickPosX
	Global MouseClickPosY
	Global MouseOffsetStatusDetail
	Global MouseOffsetDuedateSort
	Global user
	Global atrextopwin
	If (AtrexSafeWin() == True)
	{
		;Script will not run if user is in SO Job Information Screen
		IfWinExist, Open Service Order Selection
		{
			WinClose, Open Service Order Selection
		}
		atrextopwin := AtrexTopCrawl()
		WinActivate, %atrextopwin%
		SendLevel, 0
		SendInput {LShift down}{LAlt down}{F8}{LShift up}{LAlt up}
		If (WaitForWindow("Open Service Order Selection") == True)
		{
			WinActivate, Open Service Order Selection
			MouseClick, left, MouseClickPosX, MouseClickPosY
			Sleep 100
			SendInput %user%{Space}
			Sleep 100
			MouseClick, left, MouseClickPosX + MouseOffsetStatusDetail, MouseClickPosY
			Sleep 500
			SendInput Hringja{Space}
			Sleep 100
			MouseClick, left, MouseClickPosX + MouseOffsetDuedateSort, MouseClickPosY
			SendInput {Home}
		}
		SendLevel, 1
	}
}
ViewUnclaimed(){
	;Show unclaimed service orders, ordered by due date
	Global MouseClickPosX
	Global MouseClickPosY
	Global MouseOffsetStatusDetail
	Global MouseOffsetDuedateSort
	Global user
	Global atrextopwin
	If (AtrexSafeWin() == True)
	{
		;Script will not run if user is in SO Job Information Screen
		IfWinExist, Open Service Order Selection
		{
			WinClose, Open Service Order Selection
		}
		atrextopwin := AtrexTopCrawl()
		WinActivate, %atrextopwin%
		SendLevel, 0
		SendInput {LShift down}{LAlt down}{F8}{LShift up}{LAlt up}
		If (WaitForWindow("Open Service Order Selection") == True)
		{
			WinActivate, Open Service Order Selection
			MouseClick, left, MouseClickPosX, MouseClickPosY
			Sleep 100
			SendInput {down}{down}{Space}
			Sleep 100
			MouseClick, left, MouseClickPosX + MouseOffsetStatusDetail, MouseClickPosY
			Sleep 200
			SendInput {down}{down}{Space}
			Sleep 100
			MouseClick, left, MouseClickPosX + MouseOffsetDuedateSort, MouseClickPosY
			Sleep 100
			SendInput {Home}
		}
		SendLevel, 1
	}
}
ClaimSO(){
	;Receives SO number as input from user. Sets reference and technician to %user% variable. Sets due date to current date
	;Script will stop and cancel if the service order already has a user registered
	;TODO: Check somehow if the SO being opened is both unclaimed and open
	Global user
	Global date
	Global serviceorder
	Global atrextopwin
	If (AtrexSafeWin() == True)
	{
		IfWinExist, Open Service Order Selection
		{
			WinActivate
			SendInput {Esc}
			Sleep 100
		}
		timer = 0
		FormatTime, Date,, dd.MM.yy
		InputBox, serviceorder,, Enter SO number
		;Handling the cancel button
		if ErrorLevel
		{
			serviceorder := ""
		}
		Else
		{
			serviceorder := RegExReplace(serviceorder, "\D") ;Strip everything from the serviceorder variable except numbers
			;Operation will only accept SO numbers 5 letters long
			If (StrLen(serviceorder) == 5)
			{
				IfWinExist, Open Service Order Selection
				{
					WinClose, Open Service Order Selection
				}
				IfWinExist, SO Number Entry
				{
					WinClose, SO Number Entry
				}
				AtrexFreeUser()
				WinActivate, Atrex
				SendInput {LAlt down}{F8}{LAlt up}
				SendLevel, 0
				If (WaitForWindow("SO Number Entry") == True)
				{
					IfWinExist, SO Number Entry
					{
						WinActivate, SO Number Entry
						SendInput %serviceorder%{Enter}
						If (WaitForWindow("Service Order Creation/Editing", 20) == True)
						{
							WinActivate, Service Order Creation/Editing
							;Script will stop and cancel if the service order already has a user registered
							clipsave := ClipboardAll
							Clipboard := "test"
							SendInput {ALT down}f{ALT up}
							SendInput {LCtrl down}c{LCtrl up}
							Sleep 250
							If (Clipboard != "test")
							{
								MsgBox, This SO already has a registered user
								SendLevel, 1
								Return
							}
							Else
							{
								SendInput %user%
								SendInput {ALT down}d{ALT up}%Date%
								SendInput {ALT down}u{ALT up}í v{Enter}
								SendInput {ALT down}je{ALT up}
								If (WaitForWindow("SO Job Information") != True)
								{
									;If the SO Job Information window did not open that most likely means there isn't a job in the SO.
									;The function will then create a job before continuing.
									SendInput {Esc}
									WinActivate, Service Order Creation/Editing
									SendInput {LAlt down}gj{LAlt up}
									WinActivate, Service Order Creation/Editing
									SendInput {LAlt down}i{LAlt up}
									Sleep 250
									IfWinExist, Confirm
									{
										WinActivate, Confirm
										SendInput {Enter 2}
									}
								}
								If (WaitForWindow("SO Job Information") == True)
								{
									WinActivate, SO Job Information
									SendInput {ALT down}t{ALT up}%user%{Enter}
									SendInput {ALT down}i{Alt up}{LCtrl down}{End}{LCtrl up}
								}
							}
							Clipboard := clipsave
							clipsave =
						}
					}
					Else
					{
						Msgbox, Operation timed out. Is Atrex frozen?
					}
				}
				Else
				{
					Msgbox, Operation timed out. Is Atrex frozen?
				}
				SendLevel, 1
			}
			;Displays an error message if user input isn't 5 characters long
			If (StrLen(serviceorder) != 5)
			{
				MsgBox, 0,, Invalid SO number!
			}
		}
	}
}
PrintInvoiceScreen(){ ;PrintInvoiceScreen function, comment is here for ctrl+f use
	;Prompts user for an invoice, SO or order number and then opens a print preview of that document
	queryprintnum := True
	IfWinExist, Atrex
	{
		IfWinExist, Customer Sales History
		{
			queryprintnum := False
			;If a Customer Sales History window is open the function will print the currently selected item to the screen
			SendInput {AppsKey}p
			If (WaitForWindow("Output Destination") == True)
			{
				SendInput s{Enter}
			}
			Else
			{
				Return
			}
		}
		Else
		{
			IfWinExist, Customer Service History
			{
				queryprintnum := False
				;If a Customer Service History window is open the function will print the currently selected item to the screen
				SendInput {AppsKey}p
				If (WaitForWindow("Output Destination") == True)
				{
					SendInput s{Enter}
				}
				Else
				{
					Return
				}
			}
			Else
			{
				IfWinExist, Open Service Order Selection
				{
					queryprintnum := False
					;If an Open Service Order Selection window is open the function will print the currently selected item to the screen
					SendInput {LAlt down}p{LAlt up}
				}
				Else
				{
					IfWinExist, Open Order Selection
					{
						queryprintnum := False
						;If an Open Order Selection window is open the function will print the currently selected item to the screen
						SendInput {LAlt down}p{LAlt up}
					}
					Else
					{
						AtrexFreeUser() ;If a Customer Sales/Service History window doesn't exist the function clears away unnecessary windows so the AtrexSafeWin() check later will return true
					}
				}
			}
		}
		If (AtrexSafeWin("","Customer Information") == True and queryprintnum == True) ;Function will not run if certain windows are open
		{
			printtype := ""
			InputBox, invoice,, Enter invoice`, SO or order number.`rEnter 'P' in front of the number to print an order
			WinActivate, Atrex
			if ErrorLevel ;Handling the cancel button
			{
				invoice := ""
			}
			Else
			{
				;User can denote whether the number is for an invoice or a service order by adding into the number either R for invoice, S for service order or P for order
				printtype := RegExReplace(invoice, "[0-9]") ;printtype variable is set to invoice with numbers removed to simplify checking
				StringUpper, printtype, printtype
				invoice := RegExReplace(invoice, "\D") ;Strip everything from the invoice variable except numbers
				If (printtype != "R" and printtype != "S" and printtype != "P")
				{
					;If the user input contained non-numerical characters other than R or S then a further check is made to identify the number
					If (StrLen(invoice) == 6)
					{
						;If the number is 6 digits long the printtype variable is set to "R" since it's most likely an invoice
						printtype := "R"
					}
					Else If (StrLen(invoice) == 5)
					{
						;If the number is 5 digits long the printtype variable is set to "S" since it's most likely a service order
						printtype := "S"
					}
					Else
					{
						;If the number is shorter than 5 digits or longer than 6 then it is not a valid number
						MsgBox, Invalid invoice/SO/order number!
					}
				}
				If (printtype == "R")
				{
					;If the printtype variable is "R" the function will print an invoice
					SendInput {LAlt}rs{Enter}
					If (WaitForWindow("Invoice Number Entry") == True)
					{
						SendInput %invoice%{Enter} 
					}
					If (WaitForWindow("Output Destination") == True)
					{
						SendInput s{Enter}
					}
					IfWinExist, Invoice Number Entry
					{
						;If the Invoice Number Entry window reappears that means there is no invoice with the specified number
						WinActivate, Invoice Number entry
						SendInput {Esc}
						MsgBox, 0,, Invalid invoice number!
					}
				}
				Else If (printtype == "S")
				{
					;If the printtype variable is "S" the function will print a service order
					SendInput {LAlt}re{Enter}
					If (WaitForWindow("SO Number Entry") == True)
					{
						SendInput %invoice%{Enter}
					}
					If (WaitForWindow("Output Destination") == True)
					{
						SendInput s{Enter}
					}
					IfWinExist, SO Number Entry
					{
						;If the SO Number Entry window reappears that means there is no invoice with the specified number
						WinActivate, SO Number entry
						SendInput {Esc}
						MsgBox, 0,, Invalid SO number!
					}
				}
				Else If (printtype == "P")
				{
					;If the printtype variable is "P" the function will print an order
					SendInput {LAlt}ro{Enter}
					If (WaitForWindow("Order Number Entry") == True)
					{
						SendInput %invoice%{Enter}
					}
					If (WaitForWindow("Output Destination") == True)
					{
						SendInput s{Enter}
					}
					IfWinExist, Order Number Entry
					{
						;If the Order Number Entry window reappears that means there is no invoice with the specified number
						WinActivate, SO Number entry
						SendInput {Esc}
						MsgBox, 0,, Invalid Order number!
					}
				}
			}
		}
	}
}
SearchInvoiceSN(){
	;Search invoices for serial number and displays results on screen
	;TODO: Fix search in service orders
	searchlocation := "invoices"
	searching := True
	IfWinExist, Atrex
	{
		IfWinNotExist, SO Job Information
		{
			;Script will not run if user is in SO Job Information Screen
			While (searching == True)
			{
				serialnum = 
				InputBox, serialnum,, Enter serial number to search for in %searchlocation%`rEnter . to switch between searching in invoices and service orders
				If ErrorLevel
				{
					;Script will not run if user hits cancel or serial number is too short
					searching := False
					Return
				}
				Else If (serialnum == ".")
				{
					If (searchlocation == "invoices")
					{
						searchlocation := "service orders"
					}
					Else
					{
						searchlocation := "invoices"
					}
				}
				Else
				{
					searching := False
					WinActivate, Atrex
					SendInput {LAlt}ru
					If (WaitForWindow("User Defined Report Selection") == True)
					{
						If (searchlocation == "invoices")
						{
							SendInput i{Enter}
							If (WaitForWindow("Output Destination") == True)
							{
								SendInput s{Enter}
								If (WaitForWindow("Search") == True)
								{
									SendInput {Tab}{End}%serialnum%`%{Enter}
								}
							}
						}
						Else
						{
							SendInput s{Enter}
							If (WaitForWindow("Output Destination") == True)
							{
								SendInput s{Enter}
								If (WaitForWindow("Search") == True)
								{
									SendInput {Tab}{End}%serialnum%`%{Tab 2}{End}%serialnum%`%{Enter}
								}
							}
						}
					}
					else
					{
						Msgbox, Operation timed out. Is Atrex frozen?
						Return
					}
				}
			}
		}
	}
}
CustHistoryCheck(){ ;Navigates to the customer information window if possible
	Global atrextopwin
	querykt := True ;Boolean variable to check if the user needs to be prompted to input the customer's kennitala
	checkkt := True ;Boolean variable to check if the Customer Information needs to be checked to verify a valid customer
	custinfo := False ;Boolean variable to check if the function has to open a Customer Information window or not
	atrextopwin := AtrexTopCrawl()
	WinActivate, %atrextopwin%
	IfWinExist, Service Order - Laser/Inkjet
	{
		WinClose, Service Order - Laser/Inkjet
	}IfWinExist, Invoice - Laser/Inkjet
	{
		WinClose, Invoice - Laser/Inkjet
	}
	IfWinExist, Customer Sales History
	{
		WinActivate, Customer Sales History
		SendInput {LAlt down}c{LAlt up}
		Return CustHistoryCheck()
	}
	IfWinExist, Customer Service History
	{
		WinActivate, Customer Service History
		SendInput {LAlt down}c{LAlt up}
		Return CustHistoryCheck()
	}
	IfWinExist, Customer Information
	{
		WinActivate, Customer Information
		Return True
	}
	IfWinExist, View Customer Information
	{
		WinActivate, View Customer Information
		Return True
	}
	If (custinfo == False)
	;If custinfo == False then the function has the take action to open the proper Customer Information window
	{
		IfWinExist, Invoice Creation/Editing
		{
			WinActivate, Invoice Creation/Editing
			SendInput {LAlt down}gc{LAlt up}
			querykt := False
		}
		IfWinExist, Order Creation/Editing
		{
			WinActivate, Order Creation/Editing
			SendInput {LAlt down}gc{LAlt up}
			Return True
		}
		IfWinExist, Service Order Creation/Editing
		{
			WinActivate, Service Order Creation/Editing
			SendInput {LAlt down}gc{LAlt up}
			Return True
		}
	}
	If (querykt == True)
	{
		;If querykt == True then the function has to query the user for a kennitala and then find that user in the system
		InputBox, custkt,, Enter the customer's kennitala
		If ErrorLevel
		{
			;If the user hits cancel or the esc key the function sets custkt to "" and returns false so the sales/service history check functions won't run
			custkt := ""
			Return False
		}
		Else
		{
			AtrexFreeUser()
			custkt := RegExReplace(custkt, "\D") ;Everything is stripped from custkt except for numbers
			If (StrLen(custkt) == 10)
			{
				;If the custkt variable is 10 characters long then it should be a valid kt so the function continues
				atrextopwin := AtrexTopCrawl()
				WinActivate, %atrextopwin%
				SendInput {LAlt}ce
				If (WaitForWindow("Customer Selection Entry") == True)
				{
					SendInput `@%custkt%{Enter 2}
					Return True
				}
			}
			Else
			{
				MsgBox, Invalid kennitala!
				Return False
			}
		}
	}
	If (checkkt == True)
	{
		If (WaitForWindow("Customer Information") == True)
		{
			SendInput {LAlt down}gf{LAlt up}
			custcheck := ""
			CopyToVariable(custcheck)
			If (custcheck != "Staðgreitt") ;Confirm the customer info window isn't showing the Staðgreitt user
			{
				Return True ;If a valid customer is found the function returns true
			}
		}
	}
	Return False ;If nothing returns true before this then the customer is not valid and the function returns False
}
CustSalesHistory(){
	;Shows customer's sales history since current date in the year 2000
	If (AtrexSafeWin() == True)
	{
		If (CustHistoryCheck() == True) ;If CustHistoryCheck() function returns true then the customer is valid and the function will continue
		{
			SendInput {LAlt down}vv{LAlt up}
			If (WaitForWindow("Customer Sales History", 30) == True)
			{
				SendInput {LAlt down}f{LAlt up}{End}{Backspace 2}00{LAlt down}r{LAlt up}{Tab 3}
				;When Customer Sales History window opens the function sets the time frame to the current date in the year 2000
			}
		}
	}
}
CustServiceHistory(){
	;Shows customer's service history since current date in the year 2000
	If (AtrexSafeWin() == True)
	{
		If (CustHistoryCheck() == True) ;If CustHistoryCheck() function returns true then the customer is valid and the function will continue
		{
			SendInput {LAlt down}vi{LAlt up}
			If (WaitForWindow("Customer Service History", 30) == True)
			{
				SendInput {LAlt down}f{LAlt up}{End}{Backspace 2}00{LAlt down}r{LAlt up}{Tab 3}
				;When Customer Service History window opens the function sets the time frame to the current date in the year 2000
			}
		}
	}
}
CalibrateMouseClick(byref MouseClickPosX, byref MouseClickPosY){
	;Calibrates mouse position for SO list sorting to current mouse position
	MouseGetPos, xpos, ypos
	MouseClickPosX := xpos
	MouseClickPosY := ypos
	Msgbox, MouseClickPos calibrated to X%xpos%,Y%ypos%.
}
SetUser(byref user){
	InputBox, user,, Enter User
	;If no username is input, sets %user% variable to default jbs
	If ErrorLevel
	{
		user = jbs
	}
	If (user = "")
	{
		user = jbs
	}
	;Sets %user% variable to upper case
	StringUpper, user, user
}
CopyToVariable(byref var){
	;Saves current clipboard data temporarily, then copies whatever is selected, saves the new clipboard data to var and then restores previous clipboard data
	clipsaved := ClipboardAll
	Clipboard := ""
	Sleep 50
	SendInput {LCtrl down}c{LCtrl up}
	Sleep 50
	var := Clipboard
	Clipboard := clipsaved
	clipsaved = 
}
WaitForWindow(windowname, timeoutmax := 15){
	;Takes in a window name as parameter then waits until either the window opens or the timer runs out
	;Default timeout maximum is 15 sleep cycles or roughly 1.5s
	timeoutcounter = 0
	While (!WinExist(windowname) and timeoutcounter <= timeoutmax)
	{
		Sleep 100
		timeoutcounter++
	}
	IfWinExist, %windowname%
	{
		;If window exists after loop finishes then the function Returns true
		Return True
	}
	else
	{
		;If window doesn't exist after loop finishes that means the loop timed out. Function Returns false
		Return False
	}
}
MakeUpper(str){
    ;Takes selected text and makes all characters at the beginning of words uppercase
    ;If all words in the text are already uppercase the function will make the whole text uppercase
	len := StrLen(str)
    counter := 1
    tmpstr := ""
    allcaps := True ;True if all chars in text are uppercase. False if any one char is lower case
    makecaps := False ;True if all words in text begin on upper case char. False if some words start with lower case
    newword := True ;True if last char checked was a space. False if last char was alphanumerical
    while (counter <= len)
    {
        sub := SubStr(str, counter, 1) ;Extract char at %counter% position
        If (sub == " ")
        {
            newword := True
        }
        If (newword == True)
        {
            if sub is Upper
                makecaps := True
            if sub is Lower
                makecaps := False
            StringUpper, sub, sub
            newword := False
        }
        else if sub is Lower
            allcaps := False
        tmpstr = %tmpstr%%sub%
        counter++
    }
    If (allcaps == True)
    {
        ;If all chars in text are upper case the function will make the whole string lower case
        StringLower, tmpstr, str
    }
    else If (makecaps == True)
    {
        ;If all words in text begin with an upper case char the function will make the whole string upper case
        StringUpper, tmpstr, str
    }
    Return tmpstr
}
AtrexTopCrawl(){
	;Checks for a series of atrex windows to see if they're open
	;The checks are ordered so windows that could logically only be on top of another are checked first
	IfWinExist, Atrex
	{
		IfWinExist, Atrex Login
		{
			Return "Atrex Login"
		}
		IfWinExist, Idle Login
		{
			Return "Idle Login"
		}
		IfWinExist, Confirm
		{
			Return "Confirm"
		}
		IfWinExist, SO Number entry
		{
			Return "SO Number Entry"
		}
		IfWinExist, SO Quote Number Entry
		{
			Return "SO Quote Number Entry"
		}
		IfWinExist, Invoice - Laser/Inkjet
		{
			Return "Invoice - Laser/Inkjet"
		}
		IfWinExist, Serial Number Entry
		{
			Return "Serial Number Entry"
		}
		IfWinExist, Multiple Serial Number Entry
		{
			Return "Multiple Serial Number Entry"
		}
		IfWinExist, Serial Number Processing
		{
			Return "Serial Number Processing"
		}
		IfWinExist, Container Item Information
		{
			Return "Container Item Information"
		}
		IfWinExist, Container Customization
		{
			Return "Container Customization"
		}
		IfWinExist, SO Job Information
		{
			Return "SO Job Information"
		}
		IfWinExist, Stock Code Entry
		{
			Return "Stock Code Entry"
		}
		IfWinExist, Customer Sales History
		{
			Return "Customer Sales History"
		}
		IfWinExist, Customer Service History
		{
			Return "Customer Service History"
		}
		IfWinExist, Customer Information
		{
			Return "Customer Information"
		}
		IfWinExist, Open Service Order Selection
		{
			Return "Open Service Order Selection"
		}
		IfWInExist, Open Order Selection
		{
			Return "Open Order Selection"
		}
		IfWinExist, Service Order Creation/Editing
		{
			Return "Service Order Creation/Editing"
		}
		IfWInExist, Order Creation/Editing
		{
			Return "Order Creation/Editing"
		}
		IfWInExist, Invoice Creation/Editing
		{
			Return "Invoice Creation/Editing"
		}
		Return "Atrex" ;If none of the above match the function returns "Atrex"
	}
	Else
	{
		Return "" ;If Atrex isn't open the function returns an empty string
	}
}
AtrexSafeWin(excludewindow := "", includewindow := ""){ ;AtrexSafeWin function. This comment is here for ctrl+f
	;Checks if it's safe for certain functions to run from a specified Atrex Window
	wintitle := AtrexTopCrawl()
	If (wintitle == excludewindow)
	{
		;If the excludewindow string matches to top window name the function returns true. This allows the function to allow a specific window that would otherwise return false
		Return True
	}
	If (wintitle == includewindow)
	{
		;If the include string matches to top window name the function returns false. This allows the function to disallow a specific window that would otherwise return true
		Return False
	}
	If (wintitle == "Atrex")
	{
		Return True
	}
	If (wintitle == "Customer Sales History")
	{
		Return True
	}
	If (wintitle == "Customer Service History")
	{
		Return True
	}
	If (wintitle == "Customer Information")
	{
		Return True
	}
	If (wintitle == "Service Order Creation/Editing")
	{
		Return True
	}
	If (wintitle == "Invoice Creation/Editing")
	{
		Return True
	}
	If (wintitle == "Order Creation/Editing")
	{
		Return True
	}
	If (wintitle == "Open Order Selection")
	{
		Return True
	}
	If (wintitle == "Open Service Order Selection")
	{
		Return True
	}
	If (wintitle == "Confirm")
	{
		Return True
	}
	Return False ;If none of the above matched then it most likely isn't safe for the functions to run so the function returns False
}
AtrexFreeUser(){ ;AtrexFreeUser function, comment is here for ctrl+f use
	;Close any windows that aren't "mission-critical" like Customer Sales/Service History, print preview, Customer info etc.
	;Windows like this stop certain hotkeys from working. So this function "frees" the user to use those hotkeys
	;Function uses recursion to continuously run until undesired windows are all closed
	IfWinExist, Hefja verk
	{
		AtrexBack()
		Sleep 100
		AtrexFreeUser()
		Return
	}
	IfWinExist, ahkjbs.ahk
	{
		AtrexBack()
		Sleep 100
		AtrexFreeUser()
		Return
	}
	IfWinExist, Print Preview
	{
		AtrexBack()
		Sleep 100
		AtrexFreeUser()
		Return
	}
	IfWinExist, Invoice - Laser/Inkjet
	{
		AtrexBack()
		Sleep 100
		AtrexFreeUser()
		Return
	}
	IfWinExist, Service Order- Laser/Inkjet
	{
		AtrexBack()
		Sleep 100
		AtrexFreeUser()
		Return
	}
	IfWinExist, Stock Code Sales History
	{
		AtrexBack()
		Sleep 100
		AtrexFreeUser()
		Return
	}
	IfWinExist, SO Number entry
	{
		AtrexBack()
		Sleep 100
		AtrexFreeUser()
		Return
	}
	IfWinExist, Notes for Stock Code
	{
		WinClose, Notes for Stock Code
		Sleep 100
		AtrexFreeUser()
		Return
	}
	IfWinExist, View Stock Code Information
	{
		AtrexBack()
		Sleep 250
		AtrexFreeUser()
		Return
	}
	IfWinExist, SO Quote Number Entry
	{
		AtrexBack()
		Sleep 100
		AtrexFreeUser()
		Return
	}
	IfWinExist, Stock Code
	{
		AtrexBack()
		Sleep 100
		AtrexFreeUser()
		Return
	}
	IfWinExist, Serial Number Entry
	{
		AtrexBack()
		Sleep 100
		AtrexFreeUser()
		Return
	}
	IfWinExist, Multiple Serial Number Entry
	{
		AtrexBack()
		Sleep 100
		AtrexFreeUser()
		Return
	}
	IfWinExist, Serial Number Processing
	{
		AtrexBack()
		Sleep 100
		AtrexFreeUser()
		Return
	}
	IfWinExist, SO Item Information
	{
		AtrexBack()
		Sleep 100
		AtrexFreeUser()
		Return
	}
	IfWinExist, Container Item Information
	{
		AtrexBack()
		Sleep 100
		AtrexFreeUser()
		Return
	}
	IfWinExist, Container Customization
	{
		AtrexBack()
		Sleep 100
		AtrexFreeUser()
		Return
	}
	IfWinExist, Customer Sales History
	{
		AtrexBack()
		Sleep 100
		AtrexFreeUser()
		Return
	}
	IfWinExist, Customer Service History
	{
		AtrexBack()
		Sleep 100
		AtrexFreeUser()
		Return
	}
	IfWinExist, Customer Information
	{
		AtrexBack()
		Sleep 100
		AtrexFreeUser()
		Return
	}
	IfWinExist, Open Service Order Selection
	{
		AtrexBack()
		Sleep 100
		AtrexFreeUser()
		Return
	}
	IfWinExist, Open Order Selection
	{
		AtrexBack()
		Sleep 100
		AtrexFreeUser()
		Return
	}
}
FindReplace(byref replacetext, findstring, replacestring := ""){
	;Looks through selected text and replaces any instances of a specific text with a different text
	;Replacement text defaults to empty
	;There is definitely a better, more efficient way to do this but I can't be arsed
	;!WIP!
	findlength := StrLen(findstring)
	replaceindex := findlength + 1
	textlength := StrLen(replacetext)
	newtext := ""
	matchfound := False
	While (replaceindex <= textlength)
	{
		;Function runs through text to find the specified string
		;When the string is found the function breaks the loop, replaces that string with the new string and then runs through again
		If (SubStr(replacetext, replaceindex - findlength, findlength) == findstring)
		{
			MsgBox, Match found!
			;The function checks x characters back in the text to look for a match to the string
			;If the function finds a match it will-
			newtext += replacestring ;-append the replacement text to the new text and-
			newtext += SubStr(replacetext, replaceindex + 1, textlength) ;-append the rest of the unprocessed text
			replacetext := newtext
			replaceindex := findlength ;Restart the loop once a match is found
		}
		Else
		{
			;If no match is found the function appends the first char in the length being compared
			addchar := SubStr(replacetext, replaceindex - findlength, 1)
			MsgBox, Char added! %addchar%
			newtext += addchar
		}
		replaceindex++
	}
	replacetext := newtext ;Set replacetext to newtext once the function finishes
}
JobComplete(){
	;Fills in info to complete current Atrex service order
	IfWinActive, SO Job Information
	{
		SendInput {LAlt down}jm{LAlt up}
		AtrexBack()
		Sleep 100
		HringjaPrep(" - T")
		SendInput {LAlt down}yh{LAlt up}{Tab}
	}
}
HringjaPrep(sotype := ""){
	;Readies a service order for the Hringja status
	;Function takes sotype variable as argument. Either " - T" or " - F"
	Global atrextopwin
	Global todaydate
	atrextopwin := AtrexTopCrawl()
	If (atrextopwin == "Service Order Creation/Editing")
	{
		WinActivate, Service Order Creation/Editing
		SendInput {LAlt down}u{LAlt up}Hringja%sotype%{Enter} ;The sotype variable is used to set whether the service order is a regular or express service or if the service order is complete
		todaydate := A_Now
		FormatTime, todaydate,, dd.MM.yyyy
		SendInput, {LAlt down}d{LAlt up}
		SendInput, %todaydate%{Tab 2}
	}
	Else If (atrextopwin == "SO Job Information")
	{
		WinActivate, SO Job Information
		AtrexBack()
		HringjaPrep(sotype)
	}
}
ListBuilder(){
	;Function that queries the user for items to be put on a list
	Global windowheightdefault := 250 ;Default window height
	Global windowheight := 250 ;Calculated window height
	Global newline := "`r" ;Variable holding a newline character for easier access and readability
	listitemprefix := "- " ;The prefix that is set before each list item
	listinstructions := "Enter a line for the list.`rLeave blank if the list is complete.`r- Enter -- to remove last entry or --[number] (for example --2 or --6) to remove a certain numbered item.`r- Enter . (period) to switch between prefixing entries with a bullet, hyphen or a number." ;Instruction text for the input box
	windowheightmultiplier := 1 ;Multiplier used for calculating the desired height of the inputbox window
	listarray := Object() ;Array to hold each individual list item
	collatedlist := "" ;Variable for the complete, collated list
	buildinglist := True ;Boolean variable to control the main loop of the function
	While (buildinglist == True)
	{
		If (listitemprefix != "● " and listitemprefix != "- ")
		{
			;Setting the listitemprefix to %: if it isn't set to a bullet or hyphen
			listitemprefix := "`%"
		}
		listinstructions := "Enter a line for the list.`rLeave blank if the list is complete.`r" . listitemprefix . "Enter -- to remove last entry or --[number] (for example --2 or --6) to remove a certain numbered item.`r" . listitemprefix . "Enter . (period) to switch between prefixing entries with a bullet, hyphen or a number"
		InputBox, listitem,, %listinstructions%`rCurrent list:`r%collatedlist%,,,windowheight
		If ErrorLevel ;If user hits Esc the function returns an empty string
		{
			Return ""
		}
		If (listitem != "") ;Function continues if input isn't empty
		{
			If (SubStr(listitem, 1, 2) == "--")
			{
				numcheck := RegExReplace(listitem, "\D")
				If (StrLen(numcheck) >= 1 and numcheck <= listarray.MaxIndex())
				{
					listarray.Remove(numcheck)
				}
				Else
				{
					listarray.Remove(listarray.MaxIndex())
				}
			}
			Else If (listitem == ".")
			{
				;If the user inputs "." the function switches the list item prefix between a bullet, hyphen and number
				If (listitemprefix == "- ")
				{
					listitemprefix := "● "
				}
				Else If (listitemprefix == "● ")
				{
					listitemprefix := "`%"
				}
				Else
				{
					listitemprefix := "- "
				}
			}
			Else
			{
				;If the user input isn't empty and isn't either "--" or "." then the input is added to the list array
				listarray.Insert(listitem)
				windowheightmultiplier += Ceil(StrLen(listitem+3)/50) + 1 ;The window height multiplier is dynamically adjusted based on the number and length of list entries
			}
		}
		Else
		{
			;If the user input is empty the buildinglist variable is set to false and the loop won't run again
			buildinglist := False
		}
		collatedlist := ArrayCollator(listarray, listitemprefix)
		windowheight := windowheightdefault
		windowheight += windowheightmultiplier * 17 ;The window height is set based on the calculated multiplier
	}
	Return collatedlist ;The function returns the completed list
}
WaitTimer(waittime := 1000){
	;Function that sets the miscswitch variable to True for a specific amount of time
	Global miscswitch
	miscswitch := True
	Sleep %waittime%
	miscswitch := False
}
DueDateOld(futuredate := 0, addtimestamp := False, singleso := False, lastso := ""){
	;Function that sets the due date for multiple service orders to the next weekday
	;-WIP-
	;TODO: Split up function. Separate SO number input and due date updating
	Global serviceorder
	Global todaydate =
	Global user
	If (singleso == False)
	{
		IfWinExist, SO Job Information
		{
			MsgBox, Please close all Atrex windows except for the main window!
			Return
		}
		IfWinExist, Service Order Creation/Editing
		{
			MsgBox, Please close all Atrex windows except for the main window!
			Return
		}
	}
	IfWinExist, Open Service Order Selection
	{
		WinClose, Open Service Order Selection
	}
	IfWinExist, SO Number Entry
	{
		WinClose, SO Number Entry
	}
	If (addtimestamp == True)
	{
		addtimestampstr := "Yes"
	}
	Else
	{
		addtimestampstr := "No"
	}
	AtrexFreeUser() ;Closing unnecessary windows
	If (futuredate == 0)
	{
		todaydate := A_Now ;Getting today's date
		FormatTime, weekday, %todaydate%, ddd ;Get current day of the week
		If (weekday == "fri." or weekday == "fös.")
		{
			;If today is friday the function adds 3 days to the due date to move it to the next monday
			adddays := 3
		}
		Else If (weekday == "sat." or weekday == "lau.")
		{
			;If today is saturday the function adds 2 days to the due date to move it to the next monday
			adddays := 2
		}
		Else
		{
			;If today is not friday the function adds 1 day to the due date to move it to the next weekday
			adddays := 1
		}
		EnvAdd, todaydate, %adddays%, days ;Adding the set number of days to the todaydate variable
		FormatTime, futuredate, %todaydate%, dd.MM.yyyy ;Setting a new variable with the future date
	}
	If (singleso == True)
	{
		;If singleso variable is True then the function is only meant to change the due date on a single service order
		IfWinExist, Service Order Creation/Editing
		{
			IfWinNotExist, SO Job Information
			{
				AtrexFreeUser()
				WinActivate, Service Order Creation/Editing
				SendInput {LAlt down}d{LAlt up}%futuredate%{Tab}{LShift down}{Tab}{LShift up}{Right}
			}
		}
	}
	Else
	{
		;If singleso variable is False then the function is meant to change the due date on multiple service orders
		InputBox, serviceorder,, Enter an SO number.`rEnter . to turn on/off timestamping an updated due date.`rEnter -- to set a custom due date.`r-----`rDue date will be set to: %futuredate%`rUpdated due date timestamp: %addtimestampstr%`rCurrent user: %user%`r-----`rMake sure to have only the main Atrex window open`rLast SO updated: %lastso%,,,285
		If ErrorLevel
		{
			;Handling the cancel and escape buttons
			serviceorder := ""
			Return
		}
		If (serviceorder == ".")
		{
			;Entering a period will switch on/off inserting a timestamp into the service order for each due date that is updated
			If (addtimestamp == False)
			{
				addtimestamp := True
			}
			Else
			{
				addtimestamp := False
			}
			DueDateOld(futuredate, addtimestamp, false, lastso)
			Return
		}
		Else If (serviceorder == "--")
		{
			;Entering -- will prompt the user to set their own custom due date
			;NO INPUT CHECKING IMPLEMENTED YET
			InputBox, futuredate,, Enter a date to set service orders to.`rEnter nothing to set to next weekday.
			If (futuredate == "")
			{
				;futuredate variable is set to 0 if input is empty. This causes the function to set the due date to the next weekday
				futuredate := 0
			}
			DueDateOld(futuredate, addtimestamp, false, lastso)
			Return
		}
		serviceorder := RegExReplace(serviceorder, "\D") ;Stripping away everything but numbers from the variable
		If (StrLen(serviceorder) == 5)
		{
			;If the serviceorder variable is 5 characters long then it is valid
			WinActivate, Atrex
			SendLevel, 0
			SendInput {LShift down}{LAlt down}{F8}{LAlt up}{LShift up} ;Open the SO list
			SendLevel, 1
			If (WaitForWindow("Open Service Order Selection", 30) == True)
			{
				SendInput %serviceorder%{Enter} ;Opening the appropriate service order
				If (WaitForWindow("Service Order Creation/Editing", 30) == True)
				{
					SendInput {LAlt down}d{LAlt up}%futuredate% ;Setting the due date to the futuredate value
					If (addtimestamp == True)
					{
						;If addtimestamp is true then the function will-
						EnterJob("i") ;-enter the service order,-
						If (WaitForWindow("SO Job Information") == True)
						{
							Sleep 100
							SendInput {Enter}
							TimeStamp() ;-insert a timestamp-
							SendInput Due date uppfært á %futuredate% ;- and text notifying of a updated due date
							Sleep 100
						}
						AtrexBack() ;Function then goes back to the main window of the service order
					}
					AtrexBack() ;Function closes the service order
					Sleep 250
					DueDateOld(futuredate, addtimestamp, false, serviceorder) ;The script then runs again
				}
				Else
				{
					SendInput {Enter}
					MsgBox, Opening service order took too long to complete.
					DueDateOld(futuredate, addtimestamp, false, lastso)
					Return
				}
			}
			Else
			{
				MsgBox, Opening service order list took too long to complete.
				Return
			}
		}
		Else If (serviceorder == "")
		{
			;If input is empty the function will return
			MsgBox, 4,, Viltu uppfæra biðtíma? (velja Yes eða No)
			IfMsgBox, Yes
			{
				Run, \\3t.lan\DATA\public\Forrit\ahkverzlunjbs\BidTimar.exe
			}
			Return
		}
		Else
		{
			;If the user's input isn't 5 characters long then it isn't valid
			MsgBox, Invalid SO number!
			DueDateOld(futuredate, addtimestamp, false, lastso) ;Script runs again
			Return
		}
	}
}
DueDateUpdate(sonum, newdate, ddtimestamp := false){ ;DueDateUpdate function. Comment is here for ctrl+f
	;Prototype for new due date update function
	;-----VERY WIP-----
	sonum := RegExReplace(sonum, "\D") ;Stripping away everything but numbers from the variable
	IfWinExist, Service Order Creation/Editing
	{
		Return False
	}
	Else
	{
		If (StrLen(sonum) == 5)
		{
			;If the serviceorder variable is 5 characters long then it is valid
			WinActivate, Atrex
			SendLevel, 0
			SendInput {LShift down}{LAlt down}{F8}{LAlt up}{LShift up} ;Open the SO list
			SendLevel, 1
			If (WaitForWindow("Open Service Order Selection", 30) == True)
			{
				SendInput %sonum%{Enter} ;Opening the appropriate service order
				If (WaitForWindow("Service Order Creation/Editing", 30) == True)
				{
					SendInput {LAlt down}d{LAlt up}%newdate% ;Setting the due date to the futuredate value
					If (ddtimestamp == True)
					{
						;If ddtimestamp is true then the function will-
						EnterJob("i") ;-enter the service order,-
						If (WaitForWindow("SO Job Information") == True)
						{
							Sleep 100
							SendInput {Enter}
							TimeStamp() ;-insert a timestamp-
							SendInput Due date uppfært á %newdate% ;- and text notifying of a updated due date
							Sleep 100
						}
						AtrexBack() ;Function then goes back to the main window of the service order
					}
					AtrexBack() ;Function closes the service order
					Sleep 250
					Return True
				}
				Else
				{
					SendInput {Enter}
					Return False
				}
			}
			Else
			{
				Return False
			}
		}
	}
}
DueDateTextFile(filepath) ;DueDateTextFile function. Comment is here for ctrl+f
{
	;Reads SO numbers from a text file and calls DueDateUpdate function for each line
	;---WIP---
	;TODO: check custom due dates to confirm proper formatting and that the input date is in the future
	Global miscarray := []
	Global sonum
	Global futuredate
	Global ddtimestamp := False
	Global user
	ddfailed := "Due date could not be updated for S"
	ddnoopen := " - SO failed to open"
	ddinvalid := " - Invalid SO number"
	ddunexpectedopen := " - Unexpected open service order"
	ddfatalerr := "Function encountered an unrecoverable error and couldn't continue. Please try again.`rLast successful update was S"
	lastsuccessful := ""
	failedso := False
	startupdating := False
	futuredate := GetFutureDate()
	IfExist, %filepath%
	{
		Loop
		{
			;Start by setting the ddtimestampstr variable for the options prompt
			ddtimestampstr = ""
			If (ddtimestamp == True)
			{
				ddtimestampstr := "Yes"
			}
			Else
			{
				ddtimestampstr := "No"
			}
			InputBox, ddoptions,,Enter nothing to start updating due dates.`rEnter . to turn on/off timestamping an updated due date.`rEnter -- to set a custom due date.`r-----`rDue date will be set to: %futuredate%`rUpdated due date timestamp: %ddtimestampstr%`rCurrent user: %user%`r-----`rMake sure to have only the main Atrex window open,,,265
			If ErrorLevel
			{
				;If the user selects cancel the function will return without updating any due dates
				Return
			}
			If (ddoptions == ".")
			{
				If (ddtimestamp == True)
				{
					ddtimestamp := False
				}
				Else
				{
					ddtimestamp := True
				}
			}
			Else If (ddoptions == "--")
			{
				InputBox, futuredate,,Enter a custom due date to set service orders to.`rCaution! The function currently doesn't check if the date entered is valid. Please enter date as dd.mm.yyyy
			}
			Else If (ddoptions == "")
			{
				startupdating := True
				Break
			}
		}
		If (startupdating == True)
		{
			AtrexFreeUser()
			Loop
			{
				FileReadLine, sonum, %filepath%, %A_Index%
				if ErrorLevel
				{
					Break
				}
				sonum := RegExReplace(sonum, "\D") ;Stripping away everything but numbers from the variable
				If (StrLen(sonum) != 5)
				{
					;This if statement will have to be changed in the future when SO numbers go above 6 digits in length
					sonum = %ddfailed%%sonum%%ddinvalid%
					miscarray.Insert(sonum)
					failedso := True
				}
				IfWinExist, Service Order Creation/Editing
				{
					;If a Service Order Creation/Editing window is already open before the function starts updating a due date that means something went wrong in Atrex and the function is forced to abort
					MsgBox, Something went wrong!`r-----`rA service order is unexpectedly open.`rThe function has to cancel. Please try again.
					sonum := %ddfatalerr%%lastsuccessful%%ddunexpectedopen%
					miscarray.Insert(sonum)
					failedso := True
					Break
				}
				Else
				{
					If (DueDateUpdate(sonum, futuredate, ddtimestamp) == False)
					{
						;DueDateUpdate function will run and if it returns false the SO number that failed is recorded
						sonum = %ddfailed%%sonum%%ddnoopen%
						miscarray.Insert(sonum)
						failedso := True
						Sleep 1000
						IfWinExist, Service Order Creation/Editing
						{
							;If a service order is open after failing to update a due date the function closes it to avoid further errors
							IfWinExist, SO Job Information
							{
								AtrexBack()
							}
							AtrexBack()
						}
					}
					Else
					{
						lastsuccessful = %sonum%
					}
				}
			}
			MsgBox, Due date updates finished
			If (failedso == True)
			{
				;Any service orders that couldn't be updated are displayed when the function finishes
				sonumfailed := ArrayCollator(miscarray, "●")
				MsgBox, The function ran into problems updating due dates`r%sonumfailed%
			}
			MsgBox, 4,, Viltu uppfæra biðtíma? (velja Yes eða No)
			IfMsgBox, Yes
			{
				Run, \\3t.lan\DATA\public\Forrit\ahkverzlunjbs\BidTimar.exe
			}
			Return
		}
	}
}
GetFutureDate(adddays := 0){
	;Gets the date of the next weekday or a certain number of days in the future
	;---WIP---
	Global todaydate
	Global futuredate
	todaydate := A_Now ;Getting today's date
	If (adddays == 0)
	{
		;If adddays == 0 the function will set adddays so that futuredate will be the next weekday
		FormatTime, weekday, %todaydate%, ddd ;Get current day of the week
		If (weekday == "fri." or weekday == "fös.")
		{
			;If today is friday the function adds 3 days to the due date to move it to the next monday
			adddays := 3
		}
		Else If (weekday == "sat." or weekday == "lau.")
		{
			;If today is saturday the function adds 2 days to the due date to move it to the next monday
			adddays := 2
		}
		Else
		{
			;If today is not friday the function adds 1 day to the due date to move it to the next weekday
			adddays := 1
		}
	}
	EnvAdd, todaydate, %adddays%, days ;Adding the set number of days to the todaydate variable
	FormatTime, futuredate, %todaydate%, dd.MM.yyyy ;Setting a new variable with the future date
	Return futuredate
}
ShowDueToday(){
	;Shows service orders the current user has that have a due date today and the status isn't set to Hringja
	Global MouseClickPosX
	Global MouseClickPosY
	Global MouseOffsetDuedateDetail
	Global MouseOffsetStatusDetail
	Global user
	Global Date
	IfWinExist, Atrex
	{
		AtrexFreeUser()
		WinActivate, Atrex
		SendInput {LShift down}{LAlt down}{F8}{LAlt up}{LShift up}
		If (WaitForWindow("Open Service Order Selection") == True)
		{
			FormatTime, Date,, d.M.yyyy
			Sleep 250
			MouseClick, left, MouseClickPosX + MouseOffsetDuedateDetail, MouseClickPosY
			Sleep 250
			SendInput %Date%{Space}
			Sleep 250
			SendInput {Esc}
			Sleep 250
			MouseClick, left, MouseClickPosX + MouseOffsetStatusDetail, MouseClickPosY
			Sleep 250
			SendInput {down}{Enter}
			If (WaitForWindow("Custom Filter") == True)
			{
				WinActivate, Custom Filter
				SendInput does not contain{Tab}Hringja{Enter}
			}
			Sleep 250
			MouseClick, left, MouseClickPosX, MouseClickPosY
			Sleep 250
			SendInput, %user%{Space}{Esc}
			; IfWinNotExist, Snipping Tool
			; {
			; 	Run snippingtool.exe
			; }
			; If (WaitForWindow("Snipping Tool") == True)
			; {
			; 	WinActivate, Snipping Tool
			; 	SendInput, {LAlt down}mw{LAlt up}
			; }
		}
	}
}
StatusUpdate(sostatus){
	;Function that sets the current status of a service order
	Global atrextopwin
	Global serviceorder
	IfWinExist, Service Order Creation/Editing
	{
		AtrexFreeUser()
		atrextopwin := AtrexTopCrawl()
		If (atrextopwin == "SO Job Information")
		;If the top atrex window is the SO Job Information window-
		{
			AtrexBack() ;- the function exits to the Service Order Creation/Editing window-
			StatusUpdate(sostatus) ;- and then runs again
			Return
		}
		Else If (atrextopwin == "Service Order Creation/Editing")
		;If the top Atrex window is the Service Order Creation/Editing window the function-
		{
			WinActivate, Service Order Creation/Editing
			SendInput {LAlt down}gu{LAlt up}%sostatus%{Enter} ;- selects the Status drop-down list and sets the status to %sostatus%
			EnterJob("i") ;The function then calls the EnterJob() function to navigate to the bottom of the Indications/Problem text box
		}
	}
	Else
	{
		;If a Service Order Creation/Editing window isn't present the function-
		If (AtrexSafeWin() == True)
		{
			InputBox, serviceorder,, Please input the SO number of the service order ;- queries the user for an SO number,-
			serviceorder := RegExReplace(serviceorder, "\D")
			If (StrLen(serviceorder) == 5)
			{
				;- checks if the string length is valid, before opening the service order
				SendInput {LAlt down}{F8}{LAlt up}
				If (WaitForWindow("SO Number Entry") == True)
				{
					SendInput %serviceorder%{Enter}
					If (WaitForWindow("SO Job Information") == True)
					{
						StatusUpdate(sostatus) ;- and finally runs again.
					}
				}
				Else
				{
					IfWinExist, SO Number Entry
					{
						WinClose, SO Number Entry
						MsgBox, Invalid SO number!
					}
				}
			}
			Else
			{
				MsgBox, Invalid SO number!
			}
		}
	}
}
HringjaMail(hringjatype, servicetype := ""){
	Global serviceorder
	IfWinExist, Run
	{
		WinClose, Run
	}
	IfWinExist, Inbox
	{
		InputBox, serviceorder,, Enter an SO number
		If ErrorLevel ;Handling the cancel button
		{
			serviceorder := ""
			Return
		}
		serviceorder := RegExReplace(serviceorder, "\D") ;Stripping away unnecessary characters
		If (StrLen(serviceorder) == 5)
		{
			If (servicetype == "F")
			{
				servicetype := "Flýti"
			}
			Else If (servicetype == "FF")
			{
				servicetype := "2x Flýti"
			}
			Else If (servicetype == "V")
			{
				servicetype := "Vefbókun"
			}
			Else If (servicetype == "FOR")
			{
				servicetype := "Forgangur"
			}
			mailtext = S%serviceorder%, Hringja%hringjatype%, %servicetype% ;Collating the text to be input into the email
			WinActivate, Inbox
			SendInput {LCtrl down}n{LCtrl up} ;Creating a new email
			If (WaitForWindow("Untitled - Message") == True)
			{
				WinActivate, Untitled - Message
				SendInput Verk{Enter} ;Setting the recipient to the "Hringja" group
				SendInput {LAlt down}u{LAlt up}%mailtext%{Tab}%mailtext% ;Inserting the text into both the subject field and body of the email
			}
		}
		Else
		{
			MsgBox, Invalid SO number!
		}
	}
}
ArrayCollator(colarray, itemprefix := "`%"){
	;Takes an array, collates it into a string variable and returns the string
	Global newline := "`r"
	arrlength := colarray.MaxIndex()
	collatedstring =
	Loop %arrlength%
	{
		;The loop runs through the list array and collates it into a string
		arritem =
		arritem := colarray[A_Index]
		If (itemprefix == "`%")
		{
			;If the itemprefix is set to % the function inserts the array item index as a prefix
			arritem := A_Index . ": " . arritem
		}
		Else
		{
			;If the itemprefix is not set to % the function inserts itemprefix as the prefix for the array item
			arritem := itemprefix . arritem
		}
		collatedstring = %collatedstring%%arritem%
		if (A_Index < arrlength)
		{
			;If the list item isn't the last in the array the function adds a newline character
			collatedstring = %collatedstring%%newline%
		}
	}
	Return collatedstring
}
LuaKeyToggle(){
	;Function checks the currently extant window and decides how to treat keys on the LuaMacros keyboard
	IfWinActive, Open Service Order Selection
	{
		Return "dpad"
	}
	IfWinActive, Open Order Selection
	{
		Return "dpad"
	}
	IfWinActive, SO Job Information
	{
		Return "dpad"
	}
	IfWinActive, Stock Code Selection
	{
		Return "dpad"
	}
	IfWinActive, Container Customization
	{
		Return "dpad"
	}
	IfWinActive, ahkjbs.ahk
	{
		Return "numpad"
	}
	IfWinActive, 3CXPhone
	{
		Return "fkey"
	}
	IfWinActive, Calculator
	{
		Return "none"
	}
	Return "fkey"
}
;^ Functions ^

^!d::
;Displays info on hotkeys and shortcuts
helplisthotkey =
(
● AltGr+t: Insert timestamp dd.MM.yy - %user% - HH:mm.`r
● AltGr+j: Enter first job in current service order.`r
● AltGr+a: Contextual command that will close specific Atrex windows if they're open.`r
● AltGr+o: View current user's claimed service orders. Ordered by status.`r
● AltGr+h: View current user's claimed service orders that have been marked "Hringja". Ordered by due date.`r
● AltGr+e: View all unclaimed service orders. Ordered by due date.`r
● AltGr+i: Claim and "prep" a service order.`r
● AltGr+p: Print an invoice to screen.`r
● AltGr+s: Search invoices for serial number and displays results on screen.`r
● AltGr+k: Shows the sales history from the customer in the currently open service order.`r
● AltGr+l: Shows the service history from the customer in the currently open service order.`r
● AltGr+b: Register a completed service into tolvutek.timon.is.`r
● AltGr+v: Activates the Atrex window the user is most likely to want.`r
● AltGr+,: Shows current user's open service orders with the due date set to today and status not set to Hringja, Hringja - F or Hringja - T.`r
● AltGr+.: Inserts a ● character.`r
● AltGr+f: Takes selected text and makes all characters at the beginning of words uppercase. If all words in the text are already uppercase the function will make the whole text uppercase.`r
● AltGr+u: Change current user.`r
● AltGr+z: Hover mouse cursor over the filter mark on the Reference column in the Open Service Order Selection window to calibrate mouse click position for SO list automation.`r
● AltGr+x: Moves the cursor to the current calibrated position on the screen`r
● AltGr+c: Displays a message with the cursor's X and Y positions. Also copies those positions to clipboard.`r
● AltGr+r: Reload script.`r
● AltGr+d: Displays this message with info on all hotkeys and shortcuts.
)
helplisttexts =
(
● `:pmagic : Tölvan var ræst upp í Linux stýrikerfi þar sem sérhæfður hugbúnaður var notaður til að meta ástand geymsludrifa tölvunnar.`r
● `:memtestok : Vinnsluminni tölvunnar var villuprófað og komu þar fram engar villur.`r
● `:memtestfokk : Vinnsluminni tölvunnar var villuprófað og komu þar fram `%memerror`% villur áður en tæknimaður stöðvaði prófið.`r
● `:memtestthermalkill : Tölvan var látin framkvæma villupróf á vinnsluminni en tölvan drap á sér vegna ofhitnunar áður en tókst að klára prófið.`r
● `:capsplode : Móðurborð tölvunnar var skoðað og fundust þar `%deadcaps`% bólgnir/sprungnir þéttar.`r
● `:mcafeedontknow : Veit ekki hvað vv er með en hann hefur allavega ekki keypt McAfee hjá okkur`r
● `:win10setup : Windows 10 Home er sett upp á tölvunni og virkt í gegnum sjálfvirkt kerfi hjá Microsoft. Allir viðeigandi reklar eru settur upp á tölvunni ásamt nýjustu uppfærslum fyrir stýrikerfið.`r
● `:jobdone : Klára skýrslu, set tölvuna í tilbuið hillu og merki verkið Hringja - T.`r
● `:jobdoneprep : Merkja job complete, ready for pickup og Hringja - T.`r
● `:aida : Tölvan var látin keyra álagspróf til að meta stöðugleika og hitamyndun. Undir litlu álagi er hitastig örgjörva í kring um `%idletemp`%°C. Undir álagi fer hitastig örgjörva upp í `%maxtemp`%°C. *Forrit bætir síðan við sjálfvirkt mat á hitastigi tölvu*`r
● `:thermal : Þegar prófið var í vinnslu fór hitastig örgjörvans upp í `%temp`%°C. *Forrit bætir síðan við sjálfvirkt mat á hitastigi tölvu*`r
● `:hringjaprep : Setur status á verki í Hringja og stillir due date á daginn í dag.`r
● `:hringjaprepflyti : Setur status á verki í Hringja - F og stillir due date á daginn í dag.`r
● `:hringjaprepComplete : Setur status á verki í Hringja - T og stillir due date á daginn í dag.`r
● `:list : Biður notanda um hluti til að setja inn í lista`r
● `:ddold : GAMALT! - Uppfæra due date á mörgum verkbeiðnum. Notanda er líka boðið að setja inn timestamp sem tilkynnir breytinguna í due date.`r
● `:ddupdate : Uppfæra due date á mörgum verkbeiðnum. Notanda er líka boðið að setja inn timestamp sem tilkynnir breytinguna í due date.`r
● `:uppfaersla: Setur inn lista til að stimpla inn móðurborð, örgjörva, vinnsluminni o.s.frv.`r-----`r
Þar sem sést `%texti`% mun forritið biðja notanda um breytu sem mun vera fyllt inn í stað `%texta`%.
)
MsgBox, %helplisthotkey%
MsgBox, %helplisttexts%
Return

; ^!d::
; HelpList("h")
; HelpList("t")
; Return

;*Other*
:::goodmorning::
Sleep 200
SendInput visir.is{Enter}
Sleep 500
SendInput {LCtrl down}t{LCtrl up}
Sleep 500
SendInput https://www.reddit.com/r/worldnews/{Enter}
Sleep 500
SendInput {LCtrl down}t{LCtrl up}
Sleep 500
SendInput https://www.reddit.com/r/hardware/{Enter}
Sleep 500
SendInput {LCtrl down}t{LCtrl up}
Sleep 500
SendInput https://www.reddit.com/r/h3vr/{Enter}
Sleep 500
SendInput {LCtrl down}t{LCtrl up}
Sleep 500
SendInput https://www.reddit.com/r/steamvr/{Enter}
Sleep 500
SendInput {LCtrl down}t{LCtrl up}
Sleep 500
SendInput https://www.reddit.com/r/vive/{Enter}
Return
;*Other*

;-------------------------

:*::data::​​- Lýsing og ástand búnaðar(hvað fylgir, raðnúmer): `r`r- Bilanalýsing (hvað, hvenær og hvernig): `r`r- Tengiliður (nafn og sími): `r`r- Notandaaðgangur og Lykilorð í stýrikerfi: `r`r- Annað (Gögn):{Space}
Return
:::elko::
SendInput Tölvutek verk:`rElko Verk:`rFartölva:`rS/N:`rDagsetning kaupnótu:`rÁbyrgðarmál:`rBilaður hlutur :`rBilanalýsing:`r`rÞ-GREINING: 4.990 kr`r`rSamtals:`r`r
:::ts::
SendInput Tjekklisti f/ síma. `rHleðsla:  Digitizer:  LCD:  Myndavélar:  Hátalarar:  Jacktengi:  Hnappar:  Lampi:  restart:  prox sens:  víbringur:  mic:  wifi:  
Return