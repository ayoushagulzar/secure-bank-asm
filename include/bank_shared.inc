;=====================================================================
; bank_shared.inc  -  SHARED CONTRACT for the whole project
;---------------------------------------------------------------------
; Owner   : Ayousha (Group Leader) - only Ayousha edits this file.
;           Batool: if you need a new constant or PROTO, ask Ayousha.
;
; Every .asm file in the project starts with:
;       INCLUDE Irvine32.inc
;       INCLUDE bank_shared.inc
;
; Calling convention used everywhere (stdcall via INVOKE):
;   - Results come back in EAX (index, length, hash, amount, 1/0).
;   - "Not found" / "invalid" is returned as -1 (indexes) or 0 (amounts).
;   - Every PROC saves the registers it changes with USES or PUSH/POP,
;     EXCEPT EAX when EAX is the return value.
;=====================================================================

;------------------------- Limits -----------------------------------
MAX_ACCOUNTS    = 10            ; max accounts the bank can hold
MAX_TXN         = 10            ; history keeps the LAST 10 txns per account
NAME_LEN        = 20            ; bytes reserved for each account holder name
PIN_LEN         = 4             ; PIN is exactly 4 digits
MAX_PIN_TRIES   = 3             ; 3 wrong PINs -> account locked
PASS_MAX        = 16            ; max admin password length
INTEREST_RATE   = 5             ; annual interest rate in percent

;------------------------- Account status bits -----------------------
STATUS_LOCKED   = 00000001b     ; bit 0 of accStatus  (set with OR, clear with AND, check with TEST)

;------------------------- Transaction type codes --------------------
TXN_NONE        = 0
TXN_DEPOSIT     = 1
TXN_WITHDRAW    = 2
TXN_XFER_OUT    = 3
TXN_XFER_IN     = 4
TXN_INTEREST    = 5

;------------------------- Cash notes the ATM dispenses --------------
NOTE_BIG        = 5000
NOTE_MID        = 1000
NOTE_SMALL      = 500           ; withdrawals must be a multiple of 500

;------------------------- Screen layout (80 x 25 console) -----------
SCREEN_W        = 80
HEADER_ROW      = 1             ; top banner
BODY_ROW        = 5             ; where screen content starts
STATUS_ROW      = 21            ; success / error message line
PROMPT_ROW      = 23            ; "Press any key..." line

;------------------------- Color scheme  (foreground + background*16) -
; Irvine32.inc already defines: black blue green cyan red magenta brown
; lightGray gray lightBlue lightGreen lightCyan lightRed lightMagenta yellow white
CLR_DEFAULT     = lightGray + (black * 16)
CLR_HEADER      = white     + (blue  * 16)
CLR_BORDER      = lightCyan + (black * 16)
CLR_TEXT        = white     + (black * 16)
CLR_HIGHLIGHT   = yellow    + (black * 16)
CLR_SUCCESS     = lightGreen+ (black * 16)
CLR_ERROR       = lightRed  + (black * 16)
CLR_INFO        = lightCyan + (black * 16)
CLR_MONEY       = lightGreen+ (black * 16)

;------------------------- Box-drawing characters (code page 437) ----
; If these look like garbage on a PC, DrawBox can switch to '+', '-', '|'
BOX_TL          = 0C9h          ; top-left      (double line)
BOX_TR          = 0BBh          ; top-right
BOX_BL          = 0C8h          ; bottom-left
BOX_BR          = 0BCh          ; bottom-right
BOX_H           = 0CDh          ; horizontal
BOX_V           = 0BAh          ; vertical
BOX_FILL        = 0DBh          ; solid block (progress bars / splash)
BOX_SHADE       = 0B0h          ; light shade
CH_MASK         = '*'           ; shown instead of PIN digits

;=====================================================================
; SHARED DATA  (defined in src/core/bank_records.asm)
; Everything between bankDataStart and bankDataEnd is saved to
; data\bank.dat by SaveData in ONE WriteToFile call.
;=====================================================================
EXTERNDEF bankDataStart:BYTE
EXTERNDEF bankDataEnd:BYTE

EXTERNDEF accCount:DWORD        ; number of accounts in use
EXTERNDEF accNo:DWORD           ; accNo[i]          account number (e.g. 1001)
EXTERNDEF accName:BYTE          ; accName[i*NAME_LEN]  holder name, 0-terminated
EXTERNDEF accPinHash:DWORD      ; accPinHash[i]     HashString(PIN)  - real PIN is never stored
EXTERNDEF accBalance:QWORD      ; accBalance[i]     64-bit balance
EXTERNDEF accStatus:BYTE        ; accStatus[i]      status bits (STATUS_LOCKED)
EXTERNDEF accFailCount:BYTE     ; accFailCount[i]   wrong PIN attempts so far

EXTERNDEF txnType:BYTE          ; 2D: txnType[i*MAX_TXN + slot]
EXTERNDEF txnAmount:DWORD       ; 2D: txnAmount[(i*MAX_TXN + slot)*4]
EXTERNDEF txnNext:DWORD         ; txnNext[i]  next slot to write (circular, 0..MAX_TXN-1)
EXTERNDEF txnCount:DWORD        ; txnCount[i] how many slots are filled (max MAX_TXN)

EXTERNDEF adminHash:DWORD       ; HashString(admin password)

;=====================================================================
; PROCEDURE PROTOTYPES
;=====================================================================

;---------------- src/core/main_menu.asm  (Ayousha) -----------------------
MainMenu        PROTO                                   ; Login / Admin / Exit loop
UserMenu        PROTO, accIndex:DWORD                   ; services loop after login

;---------------- src/core/login_security.asm  (Ayousha) -----------------------
HashString      PROTO, pStr:PTR BYTE, count:DWORD       ; EAX = 32-bit hash
ReadMasked   PROTO, pBuf:PTR BYTE, maxLen:DWORD      ; EAX = length typed (shows ****)
FindAccount     PROTO, accNumber:DWORD                  ; EAX = index, or -1
VerifyPin       PROTO, accIndex:DWORD, pBuf:PTR BYTE, count:DWORD  ; EAX = 1 ok / 0 wrong
UserLogin       PROTO                                   ; EAX = index of logged-in account, or -1

;---------------- src/core/deposit_withdraw.asm  (Ayousha) --------------------
ShowBalance     PROTO, accIndex:DWORD
Deposit         PROTO, accIndex:DWORD
Withdraw        PROTO, accIndex:DWORD
DispenseCash    PROTO, amount:DWORD                     ; prints note breakdown

;---------------- src/core/number_input_output.asm  (Ayousha) ----------------------
PrintQword      PROTO, valLo:DWORD, valHi:DWORD         ; RECURSIVE 64-bit print
PrintMoney      PROTO, valLo:DWORD, valHi:DWORD         ; "Rs. 50,000" style in CLR_MONEY
ReadAmount      PROTO                                   ; EAX = amount, 0 if invalid

;---------------- src/ui/console_ui.asm  (Ayousha) ---------------------------
SetColor        PROTO, clr:DWORD
ResetColor      PROTO
PrintAt         PROTO, col:DWORD, row:DWORD, pStr:PTR BYTE
PrintCentered   PROTO, row:DWORD, pStr:PTR BYTE
DrawBox         PROTO, col:DWORD, row:DWORD, wid:DWORD, hgt:DWORD
DrawHeader      PROTO, pTitle:PTR BYTE                  ; Clrscr + blue banner + title
ShowSuccess     PROTO, pMsg:PTR BYTE                    ; green msg on STATUS_ROW
ShowError       PROTO, pMsg:PTR BYTE                    ; red msg on STATUS_ROW (+ beep)
ShowInfo        PROTO, pMsg:PTR BYTE                    ; cyan msg on STATUS_ROW
ShowProcessing  PROTO                                   ; "Processing . . ." animation
PressAnyKey     PROTO                                   ; waits on PROMPT_ROW
SplashScreen    PROTO                                   ; startup screen + loading bar

;---------------- src/services/transaction_history.asm  (Batool) ----------------
RecordTxn       PROTO, accIndex:DWORD, tType:DWORD, amount:DWORD
ShowHistory     PROTO, accIndex:DWORD

;---------------- src/services/fund_transfer.asm  (Batool) ----------------
Transfer        PROTO, accIndex:DWORD

;---------------- src/services/interest_calculator.asm  (Batool) ----------------
CalcInterest    PROTO, accIndex:DWORD

;---------------- src/services/change_pin.asm  (Batool) ---------------
ChangePin       PROTO, accIndex:DWORD

;---------------- src/services/admin_panel.asm  (Batool) -------------------
AdminMode       PROTO                                   ; password check + admin menu
ListAccounts    PROTO
UnlockAccount   PROTO

;---------------- src/services/file_storage.asm  (Batool) -----------------
SaveData        PROTO                                   ; write data block to data\bank.dat
LoadData        PROTO                                   ; read it back (keep defaults if missing)
