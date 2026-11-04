;=====================================================================
; change_pin.asm  -  Change PIN
;---------------------------------------------------------------------
; Owner    : Batool Zehra 
; Concepts : string instructions (CMPSB to confirm new PIN twice,
;            STOSB to wipe PIN buffers), hashing, procedure calls
;=====================================================================
INCLUDE Irvine32.inc
INCLUDE bank_shared.inc

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
;---------------------------------------------------------------------
ChangePin PROC USES eax ebx ecx esi edi, accIndex:DWORD
;---------------------------------------------------------------------
    ; TODO 1: DrawHeader titlePin
    ; TODO 2: ReadMasked oldBuf -> VerifyPin accIndex -> 0 ? msgWrong
    ; TODO 3: ReadMasked newBuf -> length must be PIN_LEN else msgLen
    ;         VerifyPin with newBuf -> 1 ? msgSame
    ; TODO 4: ReadMasked confBuf, compare newBuf vs confBuf with
    ;         mov ecx, PIN_LEN / cld / repe cmpsb -> JNE msgMismatch
    ; TODO 5: INVOKE HashString, ADDR newBuf, PIN_LEN
    ;         store EAX in accPinHash[accIndex*4], INVOKE SaveData
    ; TODO 6: wipe all three buffers with REP STOSB (AL = 0)
    ;         mov edi, OFFSET newBuf / mov ecx, SIZEOF newBuf / cld / rep stosb
    ;         ShowSuccess msgOk, PressAnyKey
    ret
ChangePin ENDP

END
