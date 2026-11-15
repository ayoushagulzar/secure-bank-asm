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
blankPin    BYTE "    ", 0      ; erases old stars before a retry
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

;====================== USER LOGIN PROC =============================
; Full login screen. Returns EAX = account index, or -1 on failure.

UserLogin PROC USES ebx ecx edx

    ;draws the login screen (banners/box)
    INVOKE DrawHeader, ADDR titleLogin
    INVOKE DrawBox, LOGIN_COL-4, BODY_ROW+1, 40, 6
    INVOKE PrintAt, LOGIN_COL, BODY_ROW+2, ADDR promptAcc      ;ask for account number

    call ReadDec                ;reads account number
    jc  NoAccount               ; CF = 1 -> invalid input
    INVOKE FindAccount, eax
    cmp eax, -1
    je  NoAccount
    mov ebx, eax                ; EBX = account index

    test accStatus[ebx], STATUS_LOCKED
    jnz IsLocked

PinLoop:
    ; ---- show the PIN prompt and erase old stars ----
    INVOKE PrintAt, LOGIN_COL, BODY_ROW+4, ADDR promptPin
    mov edx, OFFSET blankPin   
    call WriteString
    INVOKE PrintAt, LOGIN_COL, BODY_ROW+4, ADDR promptPin

    ; ---- read the PIN and check it ----
    INVOKE ReadMasked, ADDR pinBuf, PIN_LEN
    INVOKE VerifyPin, ebx, ADDR pinBuf, eax
    cmp eax, 1
    je  PinOk

    ---- wrong PIN: count it ----
    inc accFailCount[ebx]       ; wrong PIN
    movzx eax, accFailCount[ebx]
    cmp eax, MAX_PIN_TRIES
    jae LockAccount

    ---- show "attempts left" and try again ----
    INVOKE ShowError, ADDR msgWrongPin
    mov ecx, MAX_PIN_TRIES
    sub ecx, eax                ; attempts left
    mov eax, ecx
    INVOKE SetColor, CLR_ERROR
    call WriteDec
    INVOKE ResetColor
    jmp PinLoop

PinOk:
    mov accFailCount[ebx], 0    ; reset the counter
    INVOKE ShowSuccess, ADDR msgWelcome
    INVOKE PressAnyKey
    mov eax, ebx                ; return the index
    ret

LockAccount:
    or  accStatus[ebx], STATUS_LOCKED   ; set the lowest bit
    INVOKE ShowError, ADDR msgNowLock
    INVOKE SaveData             ; lock must survive a restart (closing and reopening the program should not reset it)
    jmp LoginFailed

NoAccount:
    INVOKE ShowError, ADDR msgNoAcc
    jmp LoginFailed
IsLocked:
    INVOKE ShowError, ADDR msgLocked
LoginFailed:
    INVOKE PressAnyKey
    mov eax, -1
    ret
UserLogin ENDP

END
