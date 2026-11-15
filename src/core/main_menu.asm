;=====================================================================
; Concepts: procedures, INVOKE/PROTO, CMP + conditional jumps (JE/JNE/
;            JA/JB), menu loops, input range validation
;=====================================================================
INCLUDE Irvine32.inc
INCLUDE bank_shared.inc

MENU_COL = (SCREEN_W - 30) / 2      ; = 25, centers a 30-wide box
USR_COL  = (SCREEN_W - 32) / 2      ; = 24, centers a 32-wide box

.data
titleMain   BYTE "MAIN MENU", 0
titleUser   BYTE "ACCOUNT SERVICES", 0
optLogin    BYTE "[1]  User Login", 0
optAdmin    BYTE "[2]  Admin Mode", 0
optExit     BYTE "[0]  Exit", 0
promptOpt   BYTE "Select option: ", 0
msgInv   BYTE "Invalid option. Please choose from the menu.", 0
msgBye      BYTE "Thank you for banking with Secure Bank!", 0

msgWelcome     BYTE "Welcome, ", 0
labelAccNo     BYTE "    Acc: ", 0
optBalance     BYTE "[1]  Balance Inquiry", 0
optDeposite    BYTE "[2]  Deposit", 0
optWithdraw    BYTE "[3]  Withdraw", 0
optFundTran    BYTE "[4]  Fund Transfer", 0
optInterset    BYTE "[5]  Interest Calculator", 0
optHistory     BYTE "[6]  Transaction History", 0
optPinChange   BYTE "[7]  Change PIN", 0
optLogout      BYTE "[0]  Logout", 0

.code
;============================== MAIN PROC ==============================
main PROC
    INVOKE LoadData             ; restore saved balances 
    INVOKE SplashScreen         ; startup screen 
    INVOKE MainMenu
    INVOKE SaveData             ; save everything before exit 
    INVOKE ResetColor
    exit
main ENDP

;=========================== MAIN MENU PROC =============================
MainMenu PROC

MenuLoop:
    INVOKE DrawHeader, ADDR titleMain
    INVOKE DrawBox, MENU_COL, BODY_ROW+1, 30, 5              ;width = 30 , height = 5
    INVOKE PrintAt, MENU_COL+3, BODY_ROW+2, ADDR optLogin
    INVOKE PrintAt, MENU_COL+3, BODY_ROW+3, ADDR optAdmin
    INVOKE PrintAt, MENU_COL+3, BODY_ROW+4, ADDR optExit
    INVOKE PrintAt, MENU_COL+3, BODY_ROW+7, ADDR promptOpt
    
    call ReadDec
    jc InvalidInput
    cmp eax , 1         ;1 = user login
    je U_Login
    cmp eax , 2         ;2 = admin mode
    je Admin
    cmp eax , 0         ;0 = exit
    je ExitMenu
 
 InvalidInput:
    INVOKE ShowError, ADDR msgBadOpt
    INVOKE PressAnyKey
    jmp MenuLoop

U_Login:
    Invoke UserLogin
    cmp eax , -1             ;eax = index or -1
    je  MenuLoop             ; login failed -> back to menu
    Invoke UserMenu , eax    
    jmp MenuLoop

Admin:
    Invoke AdminMode
    jmp MenuLoop
   
ExitMenu:
    INVOKE ShowSuccess, ADDR msgBye
    INVOKE PressAnyKey
    ret   
   ret
MainMenu ENDP

;---------------------------------------------------------------------
UserMenu PROC USES eax, accIndex:DWORD
; Services menu for the logged-in account (accIndex = 0-based index)
;   1 Balance  2 Deposit  3 Withdraw  4 Transfer  5 Interest
;   6 History  7 Change PIN  0 Logout
;---------------------------------------------------------------------
UserLoop:
    INVOKE DrawHeader, ADDR titleUser
    INVOKE SetColor, CLR_TEXT
    INVOKE PrintAt, USR_COL, BODY_ROW, ADDR msgWelcome
    
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
