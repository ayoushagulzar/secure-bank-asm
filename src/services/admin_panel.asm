;=====================================================================
; admin_panel.asm  -  Admin mode (password protected)
;---------------------------------------------------------------------
; Owner    : Batool Zehra 
; Concepts : hashed password check, LOOP over parallel arrays,
;            TEST / AND on status bits (show + unlock),
;            formatted table output with colors
;=====================================================================
INCLUDE Irvine32.inc
INCLUDE bank_shared.inc

.data
titleAdmin  BYTE "ADMIN PANEL", 0
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
accNo_msg byte " account No: ",0
name_msg byte "name: ",0
balance_msg byte " balance: ",0
status_msg byte " status: ",0

no_account_msg byte " No accounts ",0


.code
;---------------------------------------------------------------------
AdminMode PROC USES eax edx
; Read password masked: INVOKE ReadMasked, ADDR passBuf, PASS_MAX
;   (EAX = length typed - pass it to HashString)
; HashString(passBuf, len) == adminHash ? show menu : msgBadPass
; Menu loop: 1 -> ListAccounts, 2 -> UnlockAccount, 0 -> ret
;---------------------------------------------------------------------
    ; TODO

call Clrscr
mov edx, OFFSET promptPass
call WriteString
INVOKE ReadMasked, ADDR passBuf, PASS_MAX
INVOKE HashString, ADDR passBuf, eax
cmp eax, adminHash
jne BadPass

MenuLoop:
call Clrscr
mov edx,offset titleAdmin
call WriteString
call Crlf
mov edx,offset optList
call WriteString
call Crlf
mov edx,offset optUnlock
call WriteString
call Crlf
mov edx,offset optBack
call WriteString
call Crlf
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
call WaitMsg
jmp MenuLoop

DoUnlock:
call UnlockAccount
call WaitMsg
jmp MenuLoop

BadPass:
mov edx, offset msgBadPass
call WriteString
call Crlf
call WaitMsg

Finish:
    ret
AdminMode ENDP

;---------------------------------------------------------------------
ListAccounts PROC USES eax ebx ecx edx esi edi
; Table of all accCount accounts:
;   accNo (WriteDec), accName (OFFSET accName + i*NAME_LEN),
;   balance (PrintMoney), status: TEST accStatus[i], STATUS_LOCKED
;   -> "LOCKED" in CLR_ERROR, "ACTIVE" in CLR_SUCCESS
; Use Gotoxy to line the columns up.
; Name column: copy the name into a fixed-width buffer with
;   mov esi, <name address> / mov edi, OFFSET nameCol / mov ecx, NAME_LEN
;   cld / rep movsb       (MOVSB - promised in the proposal)
;---------------------------------------------------------------------
    ; TODO

    call Clrscr

    ;account number
mov dl,2
mov dh,2
call Gotoxy

mov edx,offset accNo_msg
call WriteString

;name
mov dl,12
mov dh,2
call Gotoxy

mov edx,offset name_msg
call WriteString


;balance
mov dl,35
mov dh,2
call Gotoxy

mov edx,offset balance_msg
call WriteString


;status
mov dl,50
mov dh,2
call Gotoxy

mov edx,offset status_msg
call WriteString

mov ebx,0
cmp accCount,0
je NoAccounts



RowLoop: 


cmp ebx,accCount
je done





mov dh,3
add dh,bl
mov dl,2
call Gotoxy
mov eax,accNo[ebx*4]
Call WriteDec

mov esi,ebx
imul esi,NAME_LEN
add esi,OFFSET accName
mov edi,OFFSET nameCol
mov ecx,NAME_LEN
cld
rep movsb

mov dh,3
add dh,bl
mov dl,12
call Gotoxy
mov edx,OFFSET nameCol
call WriteString


mov dh,3
add dh,bl
mov dl,35
call Gotoxy
INVOKE PrintMoney, DWORD PTR accBalance[ebx*8], DWORD PTR accBalance[ebx*8+4]

mov dh,3
add dh,bl
mov dl,50
call Gotoxy
test accStatus[ebx], STATUS_LOCKED
jnz IsLocked
mov eax,CLR_SUCCESS
call SetTextColor ;green
mov edx,OFFSET strActive
call WriteString
jmp StatusDone

IsLocked:
mov eax,CLR_ERROR
call SetTextColor ;red
mov edx,OFFSET strLocked
call WriteString

StatusDone:
mov eax, white + (black * 16)
call SetTextColor 

add ebx,1
jmp RowLoop


NoAccounts:
mov dh,3
mov dl,2
call Gotoxy
mov edx,offset no_account_msg
call WriteString

done:
mov eax, white + (black * 16)
call SetTextColor
mov dh,4
add dh,bl
mov dl,0
call Gotoxy

    ret
ListAccounts ENDP

;---------------------------------------------------------------------
UnlockAccount PROC USES eax ebx edx
; Read account number -> FindAccount -> not locked ? msgNotLock
; AND accStatus[ebx], 0FEh     ; clear bit 0 = the lock bit
; mov accFailCount[i], 0 ; INVOKE SaveData ; ShowSuccess msgUnlocked
;---------------------------------------------------------------------
    ; TODO

; Step 1: ask for the account number
mov edx, OFFSET promptUnl
call WriteString
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
mov edx, OFFSET msgNoAcc
call WriteString
call Crlf
jmp Finish

NotLocked:
mov edx, OFFSET msgNotLock
call WriteString
call Crlf

Finish:
    ret
UnlockAccount ENDP

END
