#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
#Warn  ; Enable warnings to assist with detecting common errors.
SendMode, Input
StringCaseSense, On
AutoTrim, Off
FileEncoding, UTF-8
#InputLevel, 1
#SingleInstance, force

;TODO LIST:
;● Tölvutek logo splash screen - https://autohotkey.com/docs/commands/Progress.htm
;● Switch bidtimar from .txt to .csv

scriptversion := "v0.4"

atrextopwin := "" ;Variable for checking current top Atrex window
miscswitch := False ;General purpose boolean variable to control interrupts, waiting periods ect.

:*::time::
;Inserts time stamp. If the user has an Invoice Creation/Editing window or Order Creation/Editing window open the function inserts an Atrex timestamp
;Otherwise the function inserts a timestamp in the format dd.MM.yy - %user% - HH:mm
IfWinActive, Invoice Creation/Editing
{
	SendInput {LAlt down}t{LAlt up}
	Return
}
IfWinActive, Order Creation/Editing
{
	SendInput {LAlt down}t{LAlt up}
	Return
}
Sleep 100
InputBox, user,, Enter user name
FormatTime, Date,, dd.MM.yy -{Space}
FormatTime, hour,, {Space}- HH:mm -
StringUpper, user, user
SendLevel, 0
SendInput %Date%%user%%hour%{Space}
SendLevel, 1
Return

;v Text input v
:::list::
;Calls the ListBuilder() function to insert a list
Sleep 100
WinGet, activewindow,, A
newlist := ListBuilder()
WinActivate ahk_id %activewindow%
SendInput %newlist%
Return

:::bidtimar::
;Calls the BidTimar() function and sends the returned value as input
bidtimartext := BidTimar()
SendInput Biðtímar á verkstæði:`r%bidtimartext%
Return

:*::data::​​- Lýsing og ástand búnaðar(hvað fylgir, raðnúmer):`r`r- Bilanalýsing (hvað, hvenær og hvernig):`r`r- Tengiliður (nafn og sími):`r`r- Notandaaðgangur og Lykilorð í stýrikerfi:`r`r- Annað (Gögn):
Return
:*::bware::B-Vörur geta verið sýningareintök, skilavörur, útlitisgallaðar eða notaðar vörur og vörur án umbúða. Útsölumarkaðsvörum fæst hvorki skipt né skilað.
;^ Text input ^

;v Hotkeys v
^!p::
;Prints an invoice to screen
PrintInvoiceScreen()
Return

^!s::
;Search invoices for serial number and displays results on screen
SearchInvoiceSN()
Return

^!k::
;Shows a customer's sales history
CustSalesHistory()
Return

^!l::
;Shows a customer's service history
CustServiceHistory()
Return

^!b::
;Calls the BidTimar() function and displays the returned value
bidtimartext := BidTimar()
MsgBox, Biðtímar:`r`r%bidtimartext%`r-----`rMuna að bera saman dagsetninguna sem biðtímar voru uppfærðir!
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

^!a::
AtrexBack()
Return

^!e::
;Run the error reporting tool
errorreportpath := "`\`\3t.lan`\DATA`\public`\Forrit`\ahkverzlunjbs`\error_reports`\ahkErrorReporting.exe"
MsgBox, 4,, Viltu tilkynna villu?
IfMsgBox Yes
{
	IfWinExist, ahk Error Report
	{
		WinClose, ahk Error Report
	}
	IfExist, %errorreportpath%
	{
		Run, %errorreportpath%
		If (WaitForWindow("ahk Error Report") == True)
		{
			WinActivate, ahk Error Report
			SendInput {LAlt down}v{LAlt up}%scriptversion%{LAlt down}n{LAlt up}
		}
	}
}
Return
;^ Hotkeys ^

;v Atrex key takeover v
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
;^ Atrex key takeover ^

;v Functions v
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
PrintInvoiceScreen(){
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
			InputBox, invoice,, Sláðu inn nótu-`, verkbeiðnis- eða pöntunarnúmer.`rSláðu inn 'P' fyrir framan númerið ef þú vilt skoða út pöntun
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
						MsgBox, Rangt nótu-`, verkbeiðnis- eða pöntunarnúmer!
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
						MsgBox, 0,, Rangt nótunúmer!
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
						MsgBox, 0,, Rangt verkbeiðnisnúmer!
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
						MsgBox, 0,, Rangt pöntunarnúmer!
					}
				}
			}
		}
	}
}
SearchInvoiceSN(){
	;Search invoices for serial number and displays results on screen
	If (AtrexSafeWin() == True)
	{
		;Script will not run if user is in SO Job Information Screen
		serialnum = 
		InputBox, serialnum,, Sláðu inn raðnúmer sem skal leita eftir í nótum.`rLeitin getur tekið dágóða stund og Atrex mun vera frosið á meðan`rAthugið að vara gæti hafa verið keypt á verkbeiðni og í bili er ekki hægt að leita í verkbeiðnum.
		If (ErrorLevel or StrLen(serialnum) < 4)
		{
			;Script will not run if user hits cancel or serial number is too short
			Return
		}
		else
		{
			WinActivate, Atrex
			SendInput {LAlt}rui
			If (WaitForWindow("User Defined Report Selection") == True)
			{
				SendInput {Enter}
				Sleep 100
				SendInput s{Enter}
				Sleep 100
				SendInput {Tab}{End}%serialnum%`%{Enter}
			}
			else
			{
				Msgbox, Operation timed out. Is Atrex frozen?
				Return
			}
		}
	}
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
		;If window exists after loop finishes function Returns true
		Return True
	}
	else
	{
		;If window doesn't exist after loop finishes that means the loop timed out. Function Returns false
		Return False
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
	}
	IfWinExist, Invoice - Laser/Inkjet
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
	;If querykt == True then the function has to query the user for a kennitala and then find that user in the system
	{
		InputBox, custkt,, Sláið inn kennitölu viðskiptavinar
		If ErrorLevel
		{
			;If the user hits cancel or the esc key the function sets custkt to "" and returns false so the sales/service history check functions won't run
			custkt := ""
			Return False
		}
		Else
		{
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
				MsgBox, Ógild kennitala!
				Return False
			}
		}
	}
	If (checkkt == True)
	{
		If (WaitForWindow("Customer Information", 30) == True)
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
AtrexTopCrawl(){
	;Checks for a series of atrex windows to see if they're open
	;The check order is ordered so windows that could logically only be on top of another are checked first

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
		IfWinExist, Invoice - Laser/Inkjet
		{
			Return "Invoice - Laser/Inkjet"
		}
		IfWinExist, SO Job Information
		{
			Return "SO Job Information"
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
AtrexSafeWin(excludewindow := "", includewindow := ""){
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
	Return False ;If none of the above matched then it most likely isn't safe for the functions to run so the function returns False
}
AtrexFreeUser(){
	;Close any windows that aren't "mission-critical" like Customer Sales/Service History, print preview, Customer info etc.
	;Windows like this stop certain hotkeys from working. So this function "frees" the user to use those hotkeys
	;Function uses recursion to continuously run until undesired windows are all closed
	IfWinExist, SO Number entry
	{
		AtrexBack()
		Sleep 100
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
}
ListBuilder(){
	;Function that queries the user for items to be put on a list
	windowheightdefault := 275 ;Default window height
	windowheight := 275 ;Calculated window height
	newline := "`r" ;Variable holding a newline character for easier access and readability
	listitemprefix := "- " ;The prefix that is set before each list item
	listinstructions := "Sláðu inn línu fyrir listann.`rSkildu eftir autt til að klára.`rSláðu inn -- til að eyða út seinustu færslu eða --[tala] til að eyða ákveðinni færslu (t.d. --2 eða --6).`rSláðu inn . (punkt) til að breyta hvort færslur á lista byrji á ●, - eða tölu.`rAthugið að Atrex vistar ● sem spurningarmerki." ;Instruction text for the input box
	windowheightmultiplier := 1 ;Multiplier used for calculating the desired height of the inputbox window
	listarray := Object() ;Array to hold each individual list item
	collatedlist := "" ;Variable for the complete, collated list
	buildinglist := True ;Boolean variable to control the main loop of the function
	While (buildinglist == True)
	{
		If (listitemprefix != "● " and listitemprefix != "- ")
		{
			;Setting the listitemprefix to %: if it isn't set to a bullet or hyphen
			listitemprefix := "`%: "
		}
		listinstructions := "Sláðu inn línu fyrir listann.`rSkildu eftir autt til að klára.`r" . listitemprefix . "Sláðu inn -- til að eyða út seinustu færslu --[tala] til að eyða ákveðinni færslu (t.d. --2 eða --6).`r" . listitemprefix . "Sláðu inn . (punkt) til að breyta hvort færslur á lista byrji á ●, - eða tölu.`rAthugið að Atrex vistar ● sem spurningarmerki."
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
					listitemprefix := "`%: "
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
		listlength := listarray.MaxIndex()
		collatedlist =
		Loop %listlength%
		{
			;The loop runs through the list array and collates it into a string
			If (listitemprefix != "● " and listitemprefix != "- ")
			{
				;Setting the listitemprefix to the current index in the loop
				listitemprefix := A_Index . ": "
			}
			listitem =
			listitem := listarray[A_Index]
			;Msgbox, %listitem%
			collatedlist = %collatedlist%%listitemprefix%%listitem%
			if (A_Index < listlength)
			{
				;If the list item isn't the last in the array the function adds a newline character
				collatedlist = %collatedlist%%newline%
			}
		}
		windowheight := windowheightdefault
		windowheight += windowheightmultiplier * 17 ;The window height is set based on the calculated multiplier
	}
	Return collatedlist ;The function returns the completed list
}

BidTimar(){
	;Fetches the text from the bidtimar.txt file and returns it
	bidtimarpath := "`\`\3t.lan`\DATA`\public`\Forrit`\ahkverzlunjbs`\bidtimar.txt" ;The path to the bidtimar.txt file
	Global bidtimartext =
	IfExist, %bidtimarpath%
	{
		;If the bidtimar.txt file exists the function reads the contents into the bidtimartext variable
		FileRead, bidtimartext, %bidtimarpath%
	}
	Else
	{
		;If the fiel doesn't exist the bidtimartext variable is set to "Engin gögn um biðtíma!"
		bidtimartext := "Engin gögn um biðtíma!"
	}
	Return bidtimartext
}
;^ Functions ^

^!h::
;Displays legend/info on hotkeys and shortcuts
helplist1 =
(
JBS autohotkey-verzlun %scriptversion%`r`r
-----`r`r
● AltGr+S : Leita eftir raðnúmeri í kaupnótum`r
● AltGr+P : Sýna kaupnótu/verkbeiðni/pöntun á skjá`r
● AltGr+K : Sýna sölusögu hjá þeim viðskiptavini sem notandi er að skoða upplýsingar hjá.`r
● AltGr+L : Sýna verksögu hjá þeim viðskiptavini sem notandi er að skoða upplýsingar hjá.`r
● AltGr+A : "Back" takki. Bakkar úr þeim glugga sem notandi er í. Vistar breytingar þar sem á við.`r
● AltGr+B : Sýna biðtíma á verkstæði.`r
● AltGr+R : Reloada scriptu.`r
● AltGr+H : Sýnir þessi skilaboð með upplýsingum um notkun.`r
● AltGr+G : Sýnir glugga með auka upplýsingum um ákveðna virkni í forritinu.`r
-`r
● AltGr+E : Tilkynna villu í autohotkey scriptu.`r
-`r
● :time : Biður um notendanafn og setur inn timestamp með því notendanafni.`r
● :list : Búa til lista.`r
● :data : Setja inn data textann fyrir verkbeiðnir.`r
● :bidtimar : Skrifa inn biðtíma á verkstæði sem texta.`r
-----`r
Athugið að þetta er útgáfa %scriptversion% og það geta vel verið villur. Ef þið finnið einhverjar skulið þið endilega senda mér lýsingu á villunni (AltGr+E) en plís ekki reyna að brjóta neitt viljandi.
)
MsgBox, %helplist1%
;TODO: Add test shortcuts
Return
^!g::
helplist2 =
(
Auka fítusar:`r`r
● Shift+F2 : Ef notandi er skráður í Atrex velur forritið sjálfkrafa Atrex gluggann og opnar stock kóða leit. Ef notandi er í Invoice, Order eða SO Job Information glugga (inni í verkbeiðni, hjá notes og job parts) þá opnast í staðinn insert í line items eða job parts.`r---`r
● :time : Ef notandi er í Invoice eða Order þá er sett inn Atrex time stamp í staðinn fyrir venjulegan.`r---`r
● AltGr+P : Ef notandi stimplar inn 6 stafa tölu sækir forritið kaupnótu með því númeri. Ef notandi stimplar hins vegar inn 5 stafa tölu sækir forritið nótu af verkbeiðni.`rEf notandi er í verkbeiðnis- eða pöntunarlista eða í kaup- eða verksögu viðskiptavinar mun forritið sýna nótuna sem er valin úr listanum.`rHægt er að skilgreina hvort sýna skal kaupnótu, verkbeiðni eða pöntun með þvi að slá inn fyrir framan númerið 'R' fyrir kaupnótu, 'S' fyrir verkbeiðni eða 'P' fyrir pöntun. Ef ekkert slíkt er slegið inn mun forritið giska miðað við lengt númersins.`r---`r
● AltGr+K, AltGr+L : Ef notandi er í invoice, order eða verkbeiðni þá opnast sölusaga/verksaga hjá þeim viðskiptavini sem er verið að vinna með. Ef engin Customer Information, invoice, order eða verkbeiðnis gluggi er opinn mun notandi vera beðinn um kennitölu.
)
MsgBox, %helplist2%
Return

;-------------------------

:*::data::​​- Lýsing og ástand búnaðar(hvað fylgir, raðnúmer):`r- Bilanalýsing (hvað, hvenær og hvernig):`r- Tengiliður (nafn og sími):`r`r- Notandaaðgangur og Lykilorð í stýrikerfi:`r- Annað (Gögn):
Return