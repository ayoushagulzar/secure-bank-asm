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

.code
;---------------------------------------------------------------------
AdminMode PROC USES eax
; Read password masked: INVOKE ReadMasked, ADDR passBuf, PASS_MAX
;   (EAX = length typed - pass it to HashString)
; HashString(passBuf, len) == adminHash ? show menu : msgBadPass
; Menu loop: 1 -> ListAccounts, 2 -> UnlockAccount, 0 -> ret
;---------------------------------------------------------------------
    ; TODO
    ret
AdminMode ENDP

;---------------------------------------------------------------------
ListAccounts PROC USES eax ebx ecx edx esi
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
    ret
ListAccounts ENDP

;---------------------------------------------------------------------
UnlockAccount PROC USES eax ebx
; Read account number -> FindAccount -> not locked ? msgNotLock
; AND accStatus[ebx], 0FEh     ; clear bit 0 = the lock bit
; mov accFailCount[i], 0 ; INVOKE SaveData ; ShowSuccess msgUnlocked
;---------------------------------------------------------------------
    ; TODO
    ret
UnlockAccount ENDP

END
