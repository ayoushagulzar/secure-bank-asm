;=====================================================================
; Concepts : hashed password check, LOOP over parallel arrays,
;            TEST / AND on status bits (show + unlock),
;            formatted table output with colors
;=====================================================================
INCLUDE Irvine32.inc
INCLUDE bank_shared.inc

ADMIN_COL = (SCREEN_W - 30) / 2     ; = 25, centers a 30-wide box (same as main menu)
TEXT_COL  = 22                      ; prompt column 
TBL_ROW   = BODY_ROW + 1            ; table heading row in ListAccounts

.data
titleAdmin  BYTE "ADMIN PANEL", 0
titleLogin  BYTE "ADMIN LOGIN", 0
titleList   BYTE "ALL ACCOUNTS", 0
titleUnl    BYTE "UNLOCK ACCOUNT", 0
promptOpt   BYTE "Select option: ", 0
promptPass  BYTE "Admin password : ", 0
msgBadPass  BYTE "Access denied.", 0
optList     BYTE "[1]  List all accounts", 0
optUnlock   BYTE "[2]  Unlock an account", 0
optBack     BYTE "[0]  Back", 0
hdrTable    BYTE " ACC NO   NAME                  BALANCE (Rs.)     STATUS", 0
strActive   BYTE "ACTIVE", 0
strLocked   BYTE "LOCKED", 0
promptUnl   BYTE "Account number to unlock : ", 0
msgNoAcc    BYTE "Account not found.", 0
msgNotLock  BYTE "That account is not locked.", 0
msgUnlocked BYTE "Account unlocked.", 0
passBuf     BYTE (PASS_MAX + 1) DUP(0)
nameCol     BYTE (NAME_LEN + 1) DUP(0)
accNo_msg   BYTE "ACC NO", 0
name_msg    BYTE "NAME", 0
balance_msg BYTE "BALANCE", 0
status_msg  BYTE "STATUS", 0

no_account_msg BYTE "No accounts", 0

.code
;====================== ADMIN MODE PROC ======================
; admin password check, then the admin menu

AdminMode PROC USES eax edx
    INVOKE DrawHeader, ADDR titleLogin
    INVOKE PrintAt, TEXT_COL, BODY_ROW+2, ADDR promptPass
    INVOKE ReadMasked, ADDR passBuf, PASS_MAX
    INVOKE HashString, ADDR passBuf, eax
    cmp eax, adminHash
    jne BadPass

MenuLoop:
    INVOKE DrawHeader, ADDR titleAdmin
    INVOKE DrawBox, ADMIN_COL, BODY_ROW+1, 30, 5               ;width = 30 , height = 5
    INVOKE PrintAt, ADMIN_COL+3, BODY_ROW+2, ADDR optList
    INVOKE PrintAt, ADMIN_COL+3, BODY_ROW+3, ADDR optUnlock
    INVOKE PrintAt, ADMIN_COL+3, BODY_ROW+4, ADDR optBack
    INVOKE PrintAt, ADMIN_COL+3, BODY_ROW+7, ADDR promptOpt
    call ReadChar

    cmp al,'1'
    je DoList
    cmp al,'2'
    je DoUnlock
    cmp al,'0'
    je Finish
    jmp MenuLoop

DoList:
    call ListAccounts
    INVOKE PressAnyKey
    jmp MenuLoop

DoUnlock:
    call UnlockAccount
    INVOKE PressAnyKey
    jmp MenuLoop

BadPass:
    INVOKE ShowError, ADDR msgBadPass
    INVOKE PressAnyKey

Finish:
    ret
AdminMode ENDP

;====================== LIST ACCOUNTS PROC ======================
; table of all accounts with colored ACTIVE / LOCKED status

ListAccounts PROC USES eax ebx ecx edx esi edi
    INVOKE DrawHeader, ADDR titleList

    ; table headings (strings -> PrintAt)
    INVOKE SetColor, CLR_HIGHLIGHT
    INVOKE PrintAt, 2,  TBL_ROW, ADDR accNo_msg
    INVOKE PrintAt, 12, TBL_ROW, ADDR name_msg
    INVOKE PrintAt, 35, TBL_ROW, ADDR balance_msg
    INVOKE PrintAt, 50, TBL_ROW, ADDR status_msg
    INVOKE ResetColor

    mov ebx,0
    cmp accCount,0
    je NoAccounts

RowLoop:
    cmp ebx,accCount
    je done

    ; account number (a number -> Gotoxy)
    mov dh,TBL_ROW+1
    add dh,bl
    mov dl,2
    call Gotoxy
    mov eax,accNo[ebx*4]
    call WriteDec

    ; copy the name into nameCol
    mov esi,ebx
    imul esi,NAME_LEN
    add esi,OFFSET accName
    mov edi,OFFSET nameCol
    mov ecx,NAME_LEN
    cld
    rep movsb

    ; name (a string -> PrintAt), EAX = this account's row
    mov eax,ebx
    add eax,TBL_ROW+1
    INVOKE PrintAt, 12, eax, ADDR nameCol

    ; balance (a number -> Gotoxy)
    mov dh,TBL_ROW+1
    add dh,bl
    mov dl,35
    call Gotoxy
    INVOKE PrintMoney, DWORD PTR accBalance[ebx*8], DWORD PTR accBalance[ebx*8+4]

    ; status (a string -> PrintAt), EAX = this account's row
    mov eax,ebx
    add eax,TBL_ROW+1
    test accStatus[ebx], STATUS_LOCKED
    jnz IsLocked
    INVOKE SetColor, CLR_SUCCESS        ; green
    INVOKE PrintAt, 50, eax, ADDR strActive
    jmp StatusDone

IsLocked:
    INVOKE SetColor, CLR_ERROR          ; red
    INVOKE PrintAt, 50, eax, ADDR strLocked

StatusDone:
    INVOKE ResetColor

    add ebx,1
    jmp RowLoop

NoAccounts:
    INVOKE PrintAt, 2, TBL_ROW+1, ADDR no_account_msg

done:
    ret
ListAccounts ENDP

;====================== UNLOCK ACCOUNT PROC ======================
; clears the lock bit of an account and resets its wrong-PIN count

UnlockAccount PROC USES eax ebx edx
    ; Step 1: ask for the account number
    INVOKE DrawHeader, ADDR titleUnl
    INVOKE PrintAt, TEXT_COL, BODY_ROW+2, ADDR promptUnl
    call ReadDec              ; number typed -> EAX

    ; Step 2: find the account
    INVOKE FindAccount, eax
    cmp eax, -1
    je NotFound
    mov ebx, eax

    ; Step 3: is it locked?
    test accStatus[ebx], STATUS_LOCKED
    jz NotLocked

    ; Step 4: unlock it
    and accStatus[ebx], 0FEh  ; turn off only the lock bit
    mov accFailCount[ebx], 0  ; reset wrong-PIN count
    INVOKE SaveData           ; save to file
    INVOKE ShowSuccess, ADDR msgUnlocked
    jmp Finish

NotFound:
    INVOKE ShowError, ADDR msgNoAcc
    jmp Finish

NotLocked:
    INVOKE ShowError, ADDR msgNotLock

Finish:
    ret
UnlockAccount ENDP

END