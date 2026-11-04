;=====================================================================
; console_ui.asm  -  Console look & feel (every screen is drawn with these)
;---------------------------------------------------------------------
; Owner    : Ayousha
; Concepts : Irvine32 console procs (Clrscr, Gotoxy, SetTextColor,
;            WriteChar, WriteString, ReadChar, Delay), nested loops,
;            string length with SCASB (for centering), LOOP
;
; STYLE RULES (keep every screen consistent):
;   1. Every screen: DrawHeader -> DrawBox + content -> ONE status line
;      (ShowSuccess / ShowError / ShowInfo) -> PressAnyKey
;   2. Colors only from bank_shared.inc (CLR_*). Always ResetColor afterwards.
;   3. Design for 80 columns. Box content starts at BODY_ROW.
;   4. Status messages always on STATUS_ROW, prompts on PROMPT_ROW.
;
; Target look (+ = | are drawn with the double-line BOX_* characters):
;   +==============================================================+
;   |                S E C U R E   B A N K   A T M                 |  <- CLR_HEADER
;   +==============================================================+
;                          MAIN MENU                                   <- CLR_HIGHLIGHT
;            +============================+
;            |  [1]  User Login           |                            <- CLR_BORDER box
;            |  [2]  Admin Mode           |                            <- CLR_TEXT text
;            |  [0]  Exit                 |
;            +============================+
;   v Login successful.                                                <- CLR_SUCCESS
;=====================================================================
INCLUDE Irvine32.inc
INCLUDE bank_shared.inc

.data
bankTitle   BYTE "S E C U R E   B A N K   A T M", 0
tagline     BYTE "Your money. Secured in Assembly.", 0
msgLoading  BYTE "Loading accounts ", 0
msgProcess  BYTE "Processing", 0
msgAnyKey   BYTE "Press any key to continue...", 0
blankLine   BYTE (SCREEN_W - 1) DUP(' '), 0

.code
;---------------------------------------------------------------------
SetColor PROC USES eax, clr:DWORD
;---------------------------------------------------------------------
    mov eax, clr
    call SetTextColor
    ret
SetColor ENDP

;---------------------------------------------------------------------
ResetColor PROC USES eax
;---------------------------------------------------------------------
    mov eax, CLR_DEFAULT
    call SetTextColor
    ret
ResetColor ENDP

;---------------------------------------------------------------------
PrintAt PROC USES edx, col:DWORD, row:DWORD, pStr:PTR BYTE
; Gotoxy uses DH = row, DL = column
;---------------------------------------------------------------------
    ; TODO: mov dh, BYTE PTR row / mov dl, BYTE PTR col / call Gotoxy
    ;       mov edx, pStr / call WriteString
    ret
PrintAt ENDP

;---------------------------------------------------------------------
PrintCentered PROC USES eax ecx edi, row:DWORD, pStr:PTR BYTE
; length via SCASB (scan for 0), col = (SCREEN_W - length) / 2  (SHR 1)
;---------------------------------------------------------------------
    ; TODO: mov edi,pStr / mov al,0 / mov ecx,-1 / cld / repne scasb
    ;       length = (NOT ecx) - 1 ; compute col ; INVOKE PrintAt, col, row, pStr
    ret
PrintCentered ENDP

;---------------------------------------------------------------------
DrawBox PROC USES eax ecx edx, col:DWORD, row:DWORD, wid:DWORD, hgt:DWORD
; Double-line box in CLR_BORDER using BOX_TL BOX_TR BOX_BL BOX_BR BOX_H BOX_V
;   top    : BOX_TL, (wid-2) x BOX_H, BOX_TR
;   middle : for (hgt-2) rows -> BOX_V at col and at col+wid-1
;   bottom : BOX_BL, (wid-2) x BOX_H, BOX_BR
;---------------------------------------------------------------------
    ; TODO: Gotoxy + WriteChar in LOOPs
    ret
DrawBox ENDP

;---------------------------------------------------------------------
DrawHeader PROC, pTitle:PTR BYTE
; Clrscr -> blue banner box at HEADER_ROW with bankTitle centered
;        -> pTitle centered below it in CLR_HIGHLIGHT -> ResetColor
;---------------------------------------------------------------------
    call Clrscr
    ; TODO
    ret
DrawHeader ENDP

;---------------------------------------------------------------------
ShowSuccess PROC, pMsg:PTR BYTE
; Clear STATUS_ROW (print blankLine - its width is LENGTHOF blankLine), then CLR_SUCCESS + 0FBh (tick) + msg
;---------------------------------------------------------------------
    ; TODO
    ret
ShowSuccess ENDP

;---------------------------------------------------------------------
ShowError PROC USES eax, pMsg:PTR BYTE
; Same as ShowSuccess but CLR_ERROR, prefix "X ", and a beep:
;   mov al, 7 / call WriteChar
;---------------------------------------------------------------------
    ; TODO
    ret
ShowError ENDP

;---------------------------------------------------------------------
ShowInfo PROC, pMsg:PTR BYTE
;---------------------------------------------------------------------
    ; TODO: CLR_INFO on STATUS_ROW
    ret
ShowInfo ENDP

;---------------------------------------------------------------------
ShowProcessing PROC USES eax ecx
; "Processing" followed by 5 dots, Delay 200 ms between dots
;---------------------------------------------------------------------
    ; TODO
    ret
ShowProcessing ENDP

;---------------------------------------------------------------------
PressAnyKey PROC USES eax
; msgAnyKey in gray on PROMPT_ROW, then call ReadChar
;---------------------------------------------------------------------
    ; TODO
    ret
PressAnyKey ENDP

;---------------------------------------------------------------------
SplashScreen PROC USES eax ecx
; Big centered title + tagline, then a loading bar:
;   "Loading accounts" + 30 x BOX_FILL, each with Delay 40
; Then PressAnyKey.
;---------------------------------------------------------------------
    call Clrscr
    ; TODO
    ret
SplashScreen ENDP

END
