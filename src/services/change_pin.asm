;=====================================================================
; Concepts : string instructions (CMPSB to confirm new PIN twice,
;            STOSB to wipe PIN buffers), hashing, procedure calls
;=====================================================================
INCLUDE Irvine32.inc
INCLUDE bank_shared.inc

TEXT_COL = 22

.data
titlePin    BYTE "CHANGE PIN", 0
promptOld   BYTE "Current PIN : ", 0
promptNew   BYTE "New PIN     : ", 0
promptConf  BYTE "Confirm PIN : ", 0
msgWrong    BYTE "Current PIN is incorrect.", 0
msgLen      BYTE "PIN must be exactly 4 digits.", 0
msgMismatch BYTE "New PINs do not match.", 0
msgSame     BYTE "New PIN must be different from the old one.", 0
msgOk       BYTE "PIN changed successfully.", 0
oldBuf      BYTE (PIN_LEN + 1) DUP(0)
newBuf      BYTE (PIN_LEN + 1) DUP(0)
confBuf     BYTE (PIN_LEN + 1) DUP(0)

.code
;====================== CHANGE PIN PROC ======================
; changes the PIN of the logged-in account (only the hash is stored)

ChangePin PROC USES eax ebx ecx esi edx edi, accIndex:DWORD
    INVOKE DrawHeader , ADDR titlePin
    INVOKE PrintAt, TEXT_COL, BODY_ROW+2, ADDR promptOld
    INVOKE ReadMasked, ADDR oldBuf, PIN_LEN

    INVOKE VerifyPin ,  accIndex, ADDR oldBuf , eax
    cmp eax,0
    je WrongPin

    INVOKE PrintAt, TEXT_COL, BODY_ROW+3, ADDR promptNew
    INVOKE ReadMasked , ADDR newBuf, PIN_LEN 

    cmp eax,PIN_LEN
    jne BadLen

    INVOKE VerifyPin ,  accIndex,ADDR newBuf, PIN_LEN
    cmp eax,1
    je SamePin

    INVOKE PrintAt, TEXT_COL, BODY_ROW+4, ADDR promptConf
    INVOKE ReadMasked , ADDR confBuf ,  PIN_LEN 

    mov esi, OFFSET newBuf
    mov edi, OFFSET confBuf
    mov ecx, PIN_LEN
    cld
    repe cmpsb
    jne Mismatch

    INVOKE HashString , ADDR newBuf ,  PIN_LEN
    mov ebx, accIndex
    mov accPinHash[ebx*4],eax
    INVOKE SaveData
    INVOKE ShowSuccess, ADDR msgOk
    jmp Wipe

WrongPin:
    INVOKE ShowError, ADDR msgWrong
    jmp Wipe

BadLen:
    INVOKE ShowError, ADDR msgLen
    jmp Wipe

SamePin:
    INVOKE ShowError, ADDR msgSame
    jmp Wipe

Mismatch:
    INVOKE ShowError, ADDR msgMismatch

Wipe:
    mov al, 0
    cld

    mov edi, OFFSET oldBuf
    mov ecx, SIZEOF oldBuf
    rep stosb

    mov edi, OFFSET newBuf
    mov ecx, SIZEOF newBuf
    rep stosb

    mov edi, OFFSET confBuf
    mov ecx, SIZEOF confBuf
    rep stosb

    INVOKE PressAnyKey

    ret
ChangePin ENDP

END