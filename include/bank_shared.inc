;=====================================================================
; Concepts : symbolic constants (=), EXTERNDEF for shared data,
;            PROTO declarations for INVOKE, color attributes,
;            code page 437 box-drawing characters
;=====================================================================

;=========================== LIMITS ===================================
MAX_ACCOUNTS    = 10            ; max accounts the bank can hold
MAX_TXN         = 10            ; history keeps the last 10 txns per account
NAME_LEN        = 20            ; bytes for each account holder name
PIN_LEN         = 4             ; PIN is exactly 4 digits
MAX_PIN_TRIES   = 3             ; 3 wrong PINs -> account locked
PASS_MAX        = 16            ; max admin password length
INTEREST_RATE   = 5             ; annual interest rate in percent

;======================== ACCOUNT STATUS ==============================
STATUS_LOCKED   = 00000001b     ; bit 0 of accStatus (OR = lock, AND = unlock, TEST = check)

;====================== TRANSACTION TYPES =============================
TXN_NONE        = 0
TXN_DEPOSIT     = 1
TXN_WITHDRAW    = 2
TXN_XFER_OUT    = 3
TXN_XFER_IN     = 4
TXN_INTEREST    = 5

;======================== SCREEN LAYOUT ===============================
SCREEN_W        = 80            ; 80 x 25 console
HEADER_ROW      = 1             ; top banner
BODY_ROW        = 5             ; screen content starts here
STATUS_ROW      = 21            ; success / error message line
PROMPT_ROW      = 23            ; "Press any key..." line

;=========================== COLORS ===================================
; color = foreground + (background * 16)
CLR_DEFAULT     = lightGray  + (black * 16)
CLR_HEADER      = white      + (blue  * 16)
CLR_BORDER      = lightCyan  + (black * 16)
CLR_TEXT        = white      + (black * 16)
CLR_HIGHLIGHT   = yellow     + (black * 16)
CLR_SUCCESS     = lightGreen + (black * 16)
CLR_ERROR       = lightRed   + (black * 16)
CLR_INFO        = lightCyan  + (black * 16)
CLR_MONEY       = lightGreen + (black * 16)

;===================== BOX CHARACTERS (CP 437) ========================
BOX_TL          = 0C9h          ; top-left (double line)
BOX_TR          = 0BBh          ; top-right
BOX_BL          = 0C8h          ; bottom-left
BOX_BR          = 0BCh          ; bottom-right
BOX_H           = 0CDh          ; horizontal
BOX_V           = 0BAh          ; vertical
BOX_FILL        = 0DBh          ; solid block (loading bar)
CH_MASK         = '*'           ; shown instead of PIN digits

;========================== SHARED DATA ===============================
; defined in bank_records.asm, everything between bankDataStart and
; bankDataEnd is saved to data\bank.dat in one WriteToFile call
EXTERNDEF bankDataStart:BYTE
EXTERNDEF bankDataEnd:BYTE

EXTERNDEF accCount:DWORD        ; number of accounts in use
EXTERNDEF accNo:DWORD           ; accNo[i]             account number (e.g. 1001)
EXTERNDEF accName:BYTE          ; accName[i*NAME_LEN]  holder name, 0-terminated
EXTERNDEF accPinHash:DWORD      ; accPinHash[i]        hash of the PIN (real PIN never stored)
EXTERNDEF accBalance:QWORD      ; accBalance[i]        64-bit balance
EXTERNDEF accStatus:BYTE        ; accStatus[i]         status bits (STATUS_LOCKED)
EXTERNDEF accFailCount:BYTE     ; accFailCount[i]      wrong PIN attempts so far

EXTERNDEF txnType:BYTE          ; 2D: txnType[i*MAX_TXN + slot]
EXTERNDEF txnAmount:DWORD       ; 2D: txnAmount[(i*MAX_TXN + slot)*4]
EXTERNDEF txnNext:DWORD         ; txnNext[i]   next slot to write (circular)
EXTERNDEF txnCount:DWORD        ; txnCount[i]  how many slots are filled

EXTERNDEF adminHash:DWORD       ; hash of the admin password

;========================== PROTOTYPES ================================
; results come back in EAX: index / -1 = not found, amount / 0 = invalid,
; 1 / 0 = yes / no. every PROC saves the registers it changes.

;----------------------- main_menu.asm --------------------------------
MainMenu        PROTO                                   ; Login / Admin / Exit loop
UserMenu        PROTO, accIndex:DWORD                   ; services loop after login

;----------------------- login_security.asm ---------------------------
HashString      PROTO, pStr:PTR BYTE, count:DWORD       ; EAX = 32-bit hash
ReadMasked      PROTO, pBuf:PTR BYTE, maxLen:DWORD      ; EAX = length typed (shows ****)
FindAccount     PROTO, accNumber:DWORD                  ; EAX = index or -1
VerifyPin       PROTO, accIndex:DWORD, pBuf:PTR BYTE, count:DWORD  ; EAX = 1 ok / 0 wrong
UserLogin       PROTO                                   ; EAX = index or -1

;----------------------- deposit_withdraw.asm -------------------------
ShowBalance     PROTO, accIndex:DWORD
Deposit         PROTO, accIndex:DWORD
Withdraw        PROTO, accIndex:DWORD

;----------------------- number_input_output.asm ----------------------
PrintQword      PROTO, valLo:DWORD, valHi:DWORD         ; recursive 64-bit print
PrintMoney      PROTO, valLo:DWORD, valHi:DWORD         ; "Rs. 50,000" in CLR_MONEY
ReadAmount      PROTO                                   ; EAX = amount, 0 if invalid

;----------------------- console_ui.asm -------------------------------
SetColor        PROTO, clr:DWORD
ResetColor      PROTO
PrintAt         PROTO, col:DWORD, row:DWORD, pStr:PTR BYTE
PrintCentered   PROTO, row:DWORD, pStr:PTR BYTE
DrawBox         PROTO, col:DWORD, row:DWORD, wid:DWORD, hgt:DWORD
DrawHeader      PROTO, pTitle:PTR BYTE                  ; clear screen + banner + title
ShowSuccess     PROTO, pMsg:PTR BYTE                    ; green message on STATUS_ROW
ShowError       PROTO, pMsg:PTR BYTE                    ; red message on STATUS_ROW + beep
ShowInfo        PROTO, pMsg:PTR BYTE                    ; cyan message on STATUS_ROW
ShowProcessing  PROTO                                   ; "Processing....." animation
PressAnyKey     PROTO                                   ; waits on PROMPT_ROW
SplashScreen    PROTO                                   ; startup screen + loading bar

;----------------------- transaction_history.asm ----------------------
RecordTxn       PROTO, accIndex:DWORD, tType:DWORD, amount:DWORD
ShowHistory     PROTO, accIndex:DWORD

;----------------------- fund_transfer.asm ----------------------------
Transfer        PROTO, accIndex:DWORD

;----------------------- interest_calculator.asm ----------------------
CalcInterest    PROTO, accIndex:DWORD

;----------------------- change_pin.asm -------------------------------
ChangePin       PROTO, accIndex:DWORD

;----------------------- admin_panel.asm ------------------------------
AdminMode       PROTO                                   ; password check + admin menu
ListAccounts    PROTO
UnlockAccount   PROTO

;----------------------- file_storage.asm -----------------------------
SaveData        PROTO                                   ; write data block to data\bank.dat
LoadData        PROTO                                   ; read it back (keep defaults if missing)
