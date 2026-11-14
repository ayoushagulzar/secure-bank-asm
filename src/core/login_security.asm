;=====================================================================
; Concepts : ROL / SHL / XOR (hashing), ReadChar loop (masked input),
;            LOOP + indirect addressing [ESI] (search),
;            AND / OR / TEST on status byte (lock bit),
;            CMP + conditional jumps (3-attempt rule)
;=====================================================================
INCLUDE Irvine32.inc
INCLUDE bank_shared.inc

HASH_SEED = 5A17C0DEh
LOGIN_COL = 24                  ; prompts start here (inside the box)

.data
titleLogin  BYTE "USER LOGIN", 0
promptAcc   BYTE "Account number : ", 0
promptPin   BYTE "PIN            : ", 0
msgNoAcc    BYTE "Account not found.", 0
msgLocked   BYTE "Account is LOCKED. Please contact the bank admin.", 0
msgWrongPin BYTE "Wrong PIN. Attempts left: ", 0
msgNowLock  BYTE "3 wrong attempts - account has been LOCKED.", 0
msgWelcome  BYTE "Login successful.", 0
pinBuf      BYTE (PIN_LEN + 1) DUP(0)     ;empty space that holds the PIN while the user is typing i

.code
;==================== PROC FOR HASHING ========================
; Algorithm:
;     h = HASH_SEED
;     for each byte c:
;         h = ROL(h, 5)
;         h = h XOR c              (c zero-extended to 32 bits)
;         h = h + (h SHL 3)        (i.e. h * 9)

HashString PROC USES ecx edx esi, pStr:PTR BYTE, count:DWORD
    mov eax, HASH_SEED
    mov esi , pStr
    mov ecx , count
    jecxz HashDone
NextByte:
    movzx edx , BYTE PTR[esi]        ; c (byte -> 32 bits)
    ROL eax , 5                      ; h = ROL(h, 5)
    XOR eax ,edx                     ; h = h XOR c
    mov edx , eax                    ; copy h (so we can compute h*8 without losing h)
    SHL edx , 3                      ; h SHL 3
    add eax , edx                    ; h = h + (h SHL 3) 

    inc esi
    Loop NextByte
HashDone:
    ret
HashString ENDP

;====================== READ MASKED PROC =============================
; reads keys with ReadChar and shows '*' for each one
; Enter = done, Backspace = delete last, max maxLen chars
; EAX = number of chars stored (buffer ends with 0)

ReadMasked PROC USES ebx ecx edi, pBuf:PTR BYTE, maxLen:DWORD
    mov edi , pBuf
    xor ebx , ebx     ;characters stored so far

NextKey:
    call ReadChar
    cmp al , 0Dh       ;Enter?
    je InputDone
    cmp al , 08h       ;backspace?
    je DeleteChar

    cmp al , 20h       ;below space -> control key
    jb NextKey         ;ignore it, wait for the next key

    cmp al , 7Eh       ; above '~' -> not printable
    ja  NextKey        ;   ignore it

    cmp ebx, maxLen    ; already full?
    jae NextKey        ;   ignore extra keys

    mov [edi+ebx] , al ;store the real character
    inc ebx
    mov al, CH_MASK         ; CH_MASK = '*'  (from bank_shared.inc)
    call WriteChar
    jmp NextKey

DeleteChar:
    cmp ebx , 0      ;nothing typed yet?
    je NextKey
    dec ebx
    mov al , 8       ;move cursor one step left (doesn't erase anything)
    call WriteChar
    mov al , ' '     ; overwrite '*'  with s space
    call WriteChar
    mov al , 8       ;move left again
    call WriteChar
    jmp NextKey
InputDone:
    mov BYTE PTR [edi+ebx], 0  ;put the 0 terminator after the last character
    mov eax , ebx               ;return the count in eax
    ret
ReadMasked ENDP

;====================== FIND ACCOUNT PROC =============================
; Returns EAX = index (0-based) or -1 if not found.

FindAccount PROC USES ecx esi, accNumber:DWORD
    mov eax, -1

    mov esi , OFFSET accNo       ;accNo is defined in banck_records.asm
    mov ecx , accCount           ;accCount is defined in banck_records.asm
    jecxz NotFound

NextAcc:
    mov eax , [esi]
    cmp eax , accNumber
    je accountFount
    add esi, TYPE accNo
    Loop NextAcc

NotFound:
    mov eax , -1
    ret

accountFount:
    mov eax, accCount           ; ECX counts down from accCount,
    sub eax, ecx                ; so index = accCount - ECX
    ret
FindAccount ENDP

;====================== VERIFY PIN PROC =============================
; EAX = 1 if HashString(pBuf,count) == accPinHash[accIndex], else 0.

VerifyPin PROC USES ebx, accIndex:DWORD, pBuf:PTR BYTE, count:DWORD
    xor eax, eax
    Invoke HashString,pBuf , count
    mov ebx , accIndex
    cmp eax , accPinHash[ebx*4]  ;accPinHash is defined in bank_records.asm 
    je verified
    mov eax , 0                 ;if not equal , eax = 0
    ret

verified:
    mov eax , 1
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
