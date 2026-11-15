;=====================================================================
; Concepts : 64-bit SUB/SBB (sender) and ADD/ADC (receiver),
;            indirect + scaled addressing, CMP/JE validation
;=====================================================================
INCLUDE Irvine32.inc
INCLUDE bank_shared.inc

.data
titleXfer   BYTE "FUND TRANSFER", 0
promptTo    BYTE "Receiver account number : ", 0
promptAmt   BYTE "Amount (Rs.)            : ", 0
msgNoAcc    BYTE "Receiver account not found.", 0
msgSelf     BYTE "You cannot transfer to your own account.", 0
msgLocked   BYTE "Receiver account is locked.", 0
msgInvalid  BYTE "Invalid amount.", 0
msgNoFunds  BYTE "Insufficient balance.", 0
msgOk       BYTE "Transfer successful.", 0
lblNewBal   BYTE "New balance : ", 0

.code
;====================== TRANSFER PROC ======================
; moves money from the logged-in account to another account

Transfer PROC USES eax ebx ecx edx esi edi, accIndex:DWORD
    LOCAL recvIdx:DWORD, amount:DWORD
    INVOKE DrawHeader, ADDR titleXfer
    mov  edx, OFFSET promptTo
    call WriteString
    call ReadDec

    INVOKE FindAccount, eax
    cmp  eax, -1
    je   errNoAcc
    mov  recvIdx, eax

    cmp  eax, accIndex
    je   errSelf

    mov  esi, recvIdx
    test accStatus[esi], STATUS_LOCKED
    jnz  errLocked

    mov  edx, OFFSET promptAmt
    call WriteString
    INVOKE ReadAmount
    cmp  eax, 0
    je   errInvalid
    mov  amount, eax

    mov  esi, accIndex
    cmp  DWORD PTR accBalance[esi*8+4], 0
    jne  BalanceOK
    cmp  DWORD PTR accBalance[esi*8], eax
    jb   errNoFunds

BalanceOK:
    mov  eax, amount
    mov  esi, accIndex
    sub  DWORD PTR accBalance[esi*8],   eax
    sbb  DWORD PTR accBalance[esi*8+4], 0

    mov  edi, recvIdx
    add  DWORD PTR accBalance[edi*8],   eax
    adc  DWORD PTR accBalance[edi*8+4], 0

    INVOKE RecordTxn, accIndex, TXN_XFER_OUT, amount
    INVOKE RecordTxn, recvIdx,  TXN_XFER_IN,  amount
    INVOKE ShowProcessing
    INVOKE ShowSuccess, ADDR msgOk

    mov  edx, OFFSET lblNewBal
    call WriteString
    mov  esi, accIndex
    INVOKE PrintMoney, DWORD PTR accBalance[esi*8], DWORD PTR accBalance[esi*8+4]
    INVOKE PressAnyKey
    jmp  XferDone

errNoAcc:
    INVOKE ShowError, ADDR msgNoAcc
    jmp  ErrWait
errSelf:
    INVOKE ShowError, ADDR msgSelf
    jmp  ErrWait
errLocked:
    INVOKE ShowError, ADDR msgLocked
    jmp  ErrWait
errInvalid:
    INVOKE ShowError, ADDR msgInvalid
    jmp  ErrWait
errNoFunds:
    INVOKE ShowError, ADDR msgNoFunds

ErrWait:
    INVOKE PressAnyKey

XferDone:
    ret
Transfer ENDP

END