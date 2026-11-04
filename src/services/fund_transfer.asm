;=====================================================================
; fund_transfer.asm  -  Fund transfer between two accounts
;---------------------------------------------------------------------
; Owner    : Batool Zehra 
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

.code
;---------------------------------------------------------------------
Transfer PROC USES eax ebx ecx edx, accIndex:DWORD
;---------------------------------------------------------------------
    ; TODO 1: DrawHeader titleXfer, read receiver number (ReadDec)
    ; TODO 2: INVOKE FindAccount -> -1 ? ShowError msgNoAcc
    ;         same as accIndex ? ShowError msgSelf
    ;         TEST accStatus[receiver], STATUS_LOCKED ? ShowError msgLocked
    ; TODO 3: INVOKE ReadAmount -> 0 ? msgInvalid
    ;         balance check like Withdraw -> msgNoFunds
    ; TODO 4: sender:   SUB lo, amount / SBB hi, 0
    ;         receiver: ADD lo, amount / ADC hi, 0
    ; TODO 5: INVOKE RecordTxn, accIndex, TXN_XFER_OUT, amount
    ;         INVOKE RecordTxn, receiver, TXN_XFER_IN,  amount
    ;         ShowProcessing, ShowSuccess msgOk, show new balance (PrintMoney)
    ;         PressAnyKey
    ret
Transfer ENDP

END
