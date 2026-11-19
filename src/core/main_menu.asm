;=====================================================================
; Concepts: procedures, INVOKE/PROTO, CMP + conditional jumps (JE/JNE/
;            JA/JB), menu loops, input range validation
;=====================================================================
INCLUDE Irvine32.inc
INCLUDE bank_shared.inc

MENU_COL = (SCREEN_W - 30) / 2      ; = 25, centers a 30-wide box
USER_COL  = (SCREEN_W - 32) / 2      ; = 24, centers a 32-wide box

.data
titleMain   BYTE "MAIN MENU", 0
titleUser   BYTE "ACCOUNT SERVICES", 0
optLogin    BYTE "[1]  User Login", 0
optAdmin    BYTE "[2]  Admin Mode", 0
optExit     BYTE "[0]  Exit", 0
promptOpt   BYTE "Select option: ", 0
msgInvalid  BYTE "Invalid option. Please choose from the menu.", 0
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
    INVOKE ShowError, ADDR msgInvalid
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
MainMenu ENDP

;=========================== USER MENU PROC =============================
UserMenu PROC USES eax ebx edx, accIndex:DWORD

UserLoop:
    INVOKE DrawHeader, ADDR titleUser
    INVOKE SetColor, CLR_TEXT
    INVOKE PrintAt, USER_COL, BODY_ROW, ADDR msgWelcome
    
    ;name address = OFFSET accName + accIndex * NAME_LEN
    mov eax , accIndex       
    mov ebx ,  NAME_LEN
    mul ebx
    add eax , OFFSET accName      ;eax -> this account's name
    mov edx , eax
    call WriteString
    mov edx , OFFSET labelAccNo
    call WriteString
    mov ebx , accIndex
    mov eax, accNo[ebx*4]       ; index * 4, cuz its dword array
    call WriteDec
    INVOKE ResetColor

    INVOKE DrawBox, USER_COL, BODY_ROW+1, 32, 10             ;width = 32 , height = 10
    INVOKE PrintAt, USER_COL+3, BODY_ROW+2, ADDR optBalance 
    INVOKE PrintAt, USER_COL+3, BODY_ROW+3, ADDR optDeposite
    INVOKE PrintAt, USER_COL+3, BODY_ROW+4, ADDR optWithdraw
    INVOKE PrintAt, USER_COL+3, BODY_ROW+5, ADDR optFundTran
    INVOKE PrintAt, USER_COL+3, BODY_ROW+6, ADDR optInterset
    INVOKE PrintAt, USER_COL+3, BODY_ROW+7, ADDR optHistory
    INVOKE PrintAt, USER_COL+3, BODY_ROW+8, ADDR optPinChange
    INVOKE PrintAt, USER_COL+3, BODY_ROW+9, ADDR optLogout
    INVOKE PrintAt, USER_COL+3, BODY_ROW+12, ADDR promptOpt

    call ReadDec
    jc InvalidInput
    cmp eax, 7
    ja  InvalidInput
    cmp eax , 0             ;0 = logout
    je Logout
    cmp eax , 1             ;1 = show balance
    je ShowBalanceLabel
    cmp eax , 2             ;2 = deposite
    je DepositeMoney
    cmp eax , 3             ;3 =withdraw
    je WithdrawMoney
    cmp eax , 4             ;4 = transfer
    je TransferMoney
    cmp eax , 5             ;5 = calcualte intereset
    je CalculateIntereset
    cmp eax , 6             ;6 = show histroy
    je ShowHistoryLabel
    cmp eax , 7             ;7 = change pin
    je ChangePinLabel


InvalidInput:
    INVOKE ShowError, ADDR msgInvalid
    INVOKE PressAnyKey
    jmp UserLoop

ShowBalanceLabel:
    INVOKE ShowBalance, accIndex
    jmp UserLoop

DepositeMoney:
    INVOKE Deposit, accIndex
    INVOKE SaveData             ; money changed -> save
    jmp UserLoop

WithdrawMoney:
    INVOKE Withdraw, accIndex
    INVOKE SaveData             ; money changed -> save
    jmp UserLoop

TransferMoney:
    INVOKE Transfer, accIndex
    INVOKE SaveData             ; money changed -> save
    jmp UserLoop

CalculateIntereset:
    INVOKE CalcInterest, accIndex
    jmp UserLoop

ShowHistoryLabel:
    INVOKE ShowHistory, accIndex
    jmp UserLoop

ChangePinLabel:
    INVOKE ChangePin, accIndex
    jmp UserLoop
Logout:
    ret
UserMenu ENDP

END main