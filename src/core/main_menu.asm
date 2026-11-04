;=====================================================================
; main_menu.asm  -  Program entry point + menus
;---------------------------------------------------------------------
; Owner    : Ayousha
; Concepts : procedures, INVOKE/PROTO, CMP + conditional jumps (JE/JNE/
;            JA/JB), menu loops, input range validation
;=====================================================================
INCLUDE Irvine32.inc
INCLUDE bank_shared.inc

.data
titleMain   BYTE "MAIN MENU", 0
titleUser   BYTE "ACCOUNT SERVICES", 0
optLogin    BYTE "[1]  User Login", 0
optAdmin    BYTE "[2]  Admin Mode", 0
optExit     BYTE "[0]  Exit", 0
promptOpt   BYTE "Select option: ", 0
msgBadOpt   BYTE "Invalid option. Please choose from the menu.", 0
msgBye      BYTE "Thank you for banking with Secure Bank!", 0

.code
;---------------------------------------------------------------------
main PROC
;---------------------------------------------------------------------
    INVOKE LoadData             ; restore saved balances (Batool)
    INVOKE SplashScreen         ; startup screen (Ayousha - console_ui.asm)
    INVOKE MainMenu
    INVOKE SaveData             ; save everything before exit (Batool)
    INVOKE ResetColor
    exit
main ENDP

;---------------------------------------------------------------------
MainMenu PROC
; Loop: draw main menu -> read choice -> call module -> repeat until 0
;---------------------------------------------------------------------
    ; TODO 1: INVOKE DrawHeader, ADDR titleMain
    ; TODO 2: INVOKE DrawBox to frame the options, PrintAt each option
    ; TODO 3: PrintAt promptOpt, call ReadDec  (CF=1 -> invalid input)
    ; TODO 4: CMP eax,1 -> JE login     : INVOKE UserLogin
    ;                                     if EAX != -1 -> INVOKE UserMenu, eax
    ;         CMP eax,2 -> JE admin     : INVOKE AdminMode
    ;         CMP eax,0 -> JE quit
    ;         anything else             : INVOKE ShowError, ADDR msgBadOpt
    ; TODO 5: jump back to the top of the loop
    ; quit:   INVOKE ShowSuccess, ADDR msgBye
    ret
MainMenu ENDP

;---------------------------------------------------------------------
UserMenu PROC USES eax, accIndex:DWORD
; Services menu for the logged-in account (accIndex = 0-based index)
;   1 Balance  2 Deposit  3 Withdraw  4 Transfer  5 Interest
;   6 History  7 Change PIN  0 Logout
;---------------------------------------------------------------------
    ; TODO 1: DrawHeader titleUser, show "Welcome, <name>   Acc: <number>"
    ;         name address = OFFSET accName + accIndex * NAME_LEN
    ; TODO 2: draw the options inside a DrawBox
    ; TODO 3: read choice, validate range 0..7 (CMP + JA)
    ; TODO 4: dispatch:
    ;           1 -> INVOKE ShowBalance,  accIndex
    ;           2 -> INVOKE Deposit,      accIndex
    ;           3 -> INVOKE Withdraw,     accIndex
    ;           4 -> INVOKE Transfer,     accIndex     (Batool)
    ;           5 -> INVOKE CalcInterest, accIndex     (Batool)
    ;           6 -> INVOKE ShowHistory,  accIndex     (Batool)
    ;           7 -> INVOKE ChangePin,    accIndex     (Batool)
    ;           0 -> ret  (logout -> back to MainMenu)
    ; TODO 5: INVOKE SaveData after every money operation (so nothing is lost)
    ret
UserMenu ENDP

END main
