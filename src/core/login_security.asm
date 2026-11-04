;=====================================================================
; login_security.asm  -  PIN hashing, masked input, account search, login
;---------------------------------------------------------------------
; Owner    : Ayousha
; Concepts : ROL / SHL / XOR (hashing), ReadChar loop (masked input),
;            LOOP + indirect addressing [ESI] (search),
;            AND / OR / TEST on status byte (lock bit),
;            CMP + conditional jumps (3-attempt rule)
;=====================================================================
INCLUDE Irvine32.inc
INCLUDE bank_shared.inc

HASH_SEED = 5A17C0DEh

.data
titleLogin  BYTE "USER LOGIN", 0
promptAcc   BYTE "Account number : ", 0
promptPin   BYTE "PIN            : ", 0
msgNoAcc    BYTE "Account not found.", 0
msgLocked   BYTE "Account is LOCKED. Please contact the bank admin.", 0
msgWrongPin BYTE "Wrong PIN. Attempts left: ", 0
msgNowLock  BYTE "3 wrong attempts - account has been LOCKED.", 0
msgWelcome  BYTE "Login successful.", 0
pinBuf      BYTE (PIN_LEN + 1) DUP(0)

.code
;---------------------------------------------------------------------
HashString PROC USES ecx edx esi, pStr:PTR BYTE, count:DWORD
; Returns EAX = 32-bit hash of 'count' bytes at pStr.
; Algorithm (must match exactly - see test values in bank_records.asm):
;     h = HASH_SEED
;     for each byte c:
;         h = ROL(h, 5)
;         h = h XOR c              (c zero-extended to 32 bits)
;         h = h + (h SHL 3)        (i.e. h * 9)
;---------------------------------------------------------------------
    mov eax, HASH_SEED
    ; TODO: mov esi, pStr / mov ecx, count / loop over the bytes
    ;       MOVZX edx, BYTE PTR [esi] ; ROL eax,5 ; XOR eax,edx
    ;       mov edx,eax ; SHL edx,3 ; ADD eax,edx ; INC esi ; LOOP
    ;       Test: "1234" must give 83A5ABCFh
    ret
HashString ENDP

;---------------------------------------------------------------------
ReadMasked PROC USES ebx ecx edi, pBuf:PTR BYTE, maxLen:DWORD
; Reads keys with ReadChar, prints CH_MASK ('*') for each one.
; Used for PINs AND the admin password, so it accepts any printable
; character (20h..7Eh); the caller checks the length (PIN = 4).
; Handles Backspace (08h): remove last char, print 8,' ',8.
; Enter (0Dh) ends input. Stops accepting keys at maxLen.
; Returns EAX = number of characters stored (buffer is 0-terminated).
;---------------------------------------------------------------------
    xor eax, eax
    ; TODO: ReadChar loop as described above (CMP al,20h / JB skip ...)
    ret
ReadMasked ENDP

;---------------------------------------------------------------------
FindAccount PROC USES ecx esi, accNumber:DWORD
; Linear search through accNo[] using ESI and LOOP.
; Returns EAX = index (0-based) or -1 if not found.
;---------------------------------------------------------------------
    mov eax, -1
    ; TODO: mov esi, OFFSET accNo / mov ecx, accCount
    ;       compare [esi] with accNumber, add esi, TYPE accNo, LOOP
    ret
FindAccount ENDP

;---------------------------------------------------------------------
VerifyPin PROC USES ebx, accIndex:DWORD, pBuf:PTR BYTE, count:DWORD
; EAX = 1 if HashString(pBuf,count) == accPinHash[accIndex], else 0.
; (Batool uses this in ChangePin.)
;---------------------------------------------------------------------
    xor eax, eax
    ; TODO: INVOKE HashString, pBuf, count
    ;       mov ebx, accIndex / CMP eax, accPinHash[ebx*4] / set EAX 1 or 0
    ret
VerifyPin ENDP

;---------------------------------------------------------------------
UserLogin PROC USES ebx ecx
; Full login screen. Returns EAX = account index, or -1 on failure.
;---------------------------------------------------------------------
    mov eax, -1
    ; TODO 1: DrawHeader titleLogin, read account number (ReadDec)
    ; TODO 2: FindAccount -> -1 ? ShowError msgNoAcc, return -1
    ; TODO 3: TEST accStatus[idx], STATUS_LOCKED -> JNZ ShowError msgLocked
    ; TODO 4: loop up to MAX_PIN_TRIES:
    ;           ReadMasked -> VerifyPin
    ;           correct : accFailCount[idx] = 0, ShowSuccess, return idx
    ;           wrong   : INC accFailCount[idx], show attempts left
    ; TODO 5: after 3rd wrong: OR accStatus[idx], STATUS_LOCKED
    ;         ShowError msgNowLock, INVOKE SaveData, return -1
    ret
UserLogin ENDP

END
