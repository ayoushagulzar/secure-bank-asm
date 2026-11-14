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
;   |                   S E C U R E   B A N K                      |  <- CLR_HEADER
;   +==============================================================+
;                          MAIN MENU                                   <- CLR_HIGHLIGHT
;            +============================+
;            |  [1]  User Login           |                            <- CLR_BORDER box
;            |  [2]  Admin Mode           |                            <- CLR_TEXT text
;            |  [0]  Exit                 |
;            +============================+
;   v Login successful.                                                <- CLR_SUCCESS
;=====================================================================
INCLUDE Irvine32.inc         ;gives us irvine procedures + color name
INCLUDE bank_shared.inc      ;constants, CLR_ colors, box characters, PROTOs are defined in this file


;------------------------- Layout used only in this file -------------
HDR_W       = 64                        ; width of the banner
HDR_COL     = (SCREEN_W - HDR_W) / 2    ; banner will be align in center
SPL_W       = 52                        ; splash frame width
SPL_COL     = (SCREEN_W - SPL_W) / 2    ; = 14
SPL_ROW     = 6                         ; splash frame top row
BAR_LEN     = 30                        ; blocks in the loading bar
BAR_ROW     = 15
MSG_COL     = 2                         ; status / prompt text starts here


.data
bankTitle   BYTE "S E C U R E   B A N K", 0
tagline     BYTE "Your money. Secured in Assembly.", 0
msgLoading  BYTE "Loading accounts ", 0
msgProcess  BYTE "Processing", 0
msgAnyKey   BYTE "Press any key to continue...", 0
blankLine   BYTE (SCREEN_W - 1) DUP(' '), 0            ; to erase a line before writing something new on that place

.code
;======================= SET COLOR PROC ===============================
SetColor PROC USES eax, clr:DWORD 
    mov eax, clr          ; SetTextColor wants the color in EAX
    call SetTextColor
    ret
SetColor ENDP

;======================= RESET COLOR PROC =============================
ResetColor PROC USES eax
    mov eax, CLR_DEFAULT
    call SetTextColor
    ret
ResetColor ENDP

;======================= PRINT AT PROC ================================
; Move the cursor to (col,row), then print the 0-terminated string.

PrintAt PROC USES edx, col:DWORD, row:DWORD, pStr:PTR BYTE
    mov dh, BYTE PTR row     ; Gotoxy uses DH = row
    mov dl, BYTE PTR col     ; DL = column
    call Gotoxy              ; move the cursor there (its actually GO TO X , Y)
    mov edx, pStr            ; EDX = address of the string
    call WriteString         ; print it
    ret
PrintAt ENDP

;======================= PRINT CENTERED PROC ===========================
; to calculate length the code counts characters until the 0 using SCASB
; (“scan string byte”). then, col = (SCREEN_W - length) / 2  (SHR 1)

PrintCentered PROC USES eax ecx edi, row:DWORD, pStr:PTR BYTE
    mov edi, pStr               ; EDI points at the first character
    mov al, 0                   ; we are searching for the 0 byte
    mov ecx, -1                 ; "unlimited" counter: 0FFFFFFFFh (cuz we dont know the length of the string)
    cld                         ; cld = clear direction flag cuz when its 0, EDI goes up (scan forward)
    repne scasb                 ; repeat while [EDI] != AL, ECX-- each byte
    not ecx                     ; ; = - ECX - 1 = length + 1 
    dec ecx                     ; ECX = length

    mov eax, 0                  ; default column if the text is too long
    cmp ecx, SCREEN_W
    jae DoPrint                 ; length >= 80: just start at column 0
    mov eax, SCREEN_W
    sub eax, ecx                ; free space = 80 - length
    shr eax, 1                  ; half of it (we need equal space on both sides)
DoPrint:
    INVOKE PrintAt, eax, row, pStr
    ret
PrintCentered ENDP


;========================= DRAW BOX ROW PROC ===============================
; Helper proc: draws ONE row of box(its priv so only this file can call it)
; leftCh, then (wid-2) x midCh, then rightCh.

DrawBoxRow PROC PRIVATE USES eax ecx edx, col:DWORD, row:DWORD, wid:DWORD,
leftChar:DWORD, midChar:DWORD, rightChar:DWORD

    mov dh, BYTE PTR row
    mov dl, BYTE PTR col
    call Gotoxy                 ; go to the row's start
    mov eax, leftChar            
    call WriteChar              ; WriteChar prints AL

    mov ecx, wid
    sub ecx, 2                  ; middle count = width − 2 corners
    jecxz RightEdge             ; ECX = 0 -> skip
    mov eax, midChar
MiddleChars:
    call WriteChar
    loop MiddleChars            ; ECX−−, repeat while ECX != 0
RightEdge:
    mov eax, rightChar
    call WriteChar
    ret
DrawBoxRow ENDP

;========================= DRAW BOX PROC ===============================
; Draws a box in CLR_BORDER. (col,row) = top-left corner.
;
;   ╔══════╗   top row
;   ║      ║   (height-2) side rows, inside filled with spaces
;   ╚══════╝   bottom row
;   <-wid-->
;
; wid and height must be at least 2.

DrawBox PROC USES eax ecx edx, col:DWORD, row:DWORD, wid:DWORD, height:DWORD

    INVOKE SetColor, CLR_BORDER
    INVOKE DrawBoxRow, col, row, wid, BOX_TL, BOX_H, BOX_TR     ; top

    mov edx, row                ; EDX = current row
    mov ecx, height
    sub ecx, 2                  ; side rows = height − top − bottom
    jecxz BottomRow
SideRows:
    inc edx                     ;next row (down)
    INVOKE DrawBoxRow, col, edx, wid, BOX_V, ' ', BOX_V       
    loop SideRows               ; DrawBoxRow saved ECX/EDX, so they are safe
BottomRow:
    inc edx                     ; = row + height - 1
    INVOKE DrawBoxRow, col, edx, wid, BOX_BL, BOX_H, BOX_BR    ; bottom

    INVOKE ResetColor
    ret
DrawBox ENDP

;========================= DRAW HEADER PROC ===============================
; Clrscr -> blue banner box at HEADER_ROW with bankTitle centered
;        -> pTitle centered below it in CLR_HIGHLIGHT -> ResetColor

DrawHeader PROC, pTitle:PTR BYTE
    call Clrscr                                  ; start every screen clean
    INVOKE SetColor, CLR_HEADER                 ; white on blue
    INVOKE DrawBoxRow, HDR_COL, HEADER_ROW,   HDR_W, BOX_TL, BOX_H, BOX_TR
    INVOKE DrawBoxRow, HDR_COL, HEADER_ROW+1, HDR_W, BOX_V,  ' ',   BOX_V
    INVOKE DrawBoxRow, HDR_COL, HEADER_ROW+2, HDR_W, BOX_BL, BOX_H, BOX_BR
    INVOKE PrintCentered, HEADER_ROW+1, ADDR bankTitle    ; still blue

    INVOKE SetColor, CLR_HIGHLIGHT              ; yellow screen title
    INVOKE PrintCentered, HEADER_ROW+3, pTitle
    INVOKE ResetColor
    ret
DrawHeader ENDP

;========================= STATUS LINE PROC ===============================
; Helper (used only in this file) shared by ShowSuccess / ShowError / ShowInfo:
; wipe STATUS_ROW, then print  <mark> <message>  in the given color.

StatusLine PROC PRIVATE USES eax edx, clr:DWORD, mark:DWORD, pMsg:PTR BYTE

    INVOKE PrintAt, 0, STATUS_ROW, ADDR blankLine   ; erase the old message
    mov dh, STATUS_ROW
    mov dl, MSG_COL
    call Gotoxy
    INVOKE SetColor, clr
    mov eax, mark               ; put the symbol into EAX (✓->success / X->erro/ i->info)
    call WriteChar              ;
    mov al, ' '
    call WriteChar
    mov edx, pMsg
    call WriteString
    INVOKE ResetColor
    ret
StatusLine ENDP

;========================= SHOW SUCCESS PROC ===========================
ShowSuccess PROC, pMsg:PTR BYTE
; Clear STATUS_ROW, then CLR_SUCCESS + 0FBh (tick) + msg
;---------------------------------------------------------------------
    INVOKE StatusLine, CLR_SUCCESS, 0FBh, pMsg
    ret
ShowSuccess ENDP

;========================= SHOW ERROR PROC =============================
ShowError PROC USES eax, pMsg:PTR BYTE
; Same as ShowSuccess but CLR_ERROR, prefix "X ", and a beep
;---------------------------------------------------------------------
    mov al, 7                   ; ASCII 7 = BEL: printing it makes a beep
    call WriteChar
    INVOKE StatusLine, CLR_ERROR, 'X', pMsg
    ret
ShowError ENDP

;========================= SHOW INFO PROC ===============================
ShowInfo PROC, pMsg:PTR BYTE
; CLR_INFO on STATUS_ROW
;---------------------------------------------------------------------
    INVOKE StatusLine, CLR_INFO, 'i', pMsg
    ret
ShowInfo ENDP

;========================= SHOW PROCESSING PROC =========================
ShowProcessing PROC USES eax ecx
; "Processing" followed by 5 dots, Delay 200 ms between dots
; (on STATUS_ROW, so the next ShowSuccess/ShowError replaces it)
;---------------------------------------------------------------------
    INVOKE PrintAt, 0, STATUS_ROW, ADDR blankLine
    INVOKE SetColor, CLR_INFO
    INVOKE PrintAt, MSG_COL, STATUS_ROW, ADDR msgProcess
    mov ecx, 5
NextDot:
    mov eax, 200                ; Delay waits EAX milliseconds
    call Delay
    mov al, '.'
    call WriteChar
    loop NextDot
    INVOKE ResetColor
    ret
ShowProcessing ENDP

;---------------------------------------------------------------------
PressAnyKey PROC USES eax
; msgAnyKey on PROMPT_ROW (CLR_DEFAULT = light gray), then call ReadChar
;---------------------------------------------------------------------
    INVOKE ResetColor
    INVOKE PrintAt, MSG_COL, PROMPT_ROW, ADDR msgAnyKey
    call ReadChar               ; waits for one key (returned in AL, ignored)
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
