;=====================================================================
; Concepts : 64-bit arithmetic ADD/ADC and SUB/SBB on QWORD balances,
;            JC for overflow, CMP/JB for insufficient balance,
;            DIV for note breakdown, scaled indexing [ebx*8]
;=====================================================================
INCLUDE Irvine32.inc
INCLUDE bank_shared.inc

TEXT_COL = 22                    ; screen text starts here

.data
titleBalance  BYTE "BALANCE INQUIRY", 0
titleDep      BYTE "DEPOSIT", 0
titleWdr      BYTE "WITHDRAW", 0
labelBalance  BYTE "Available balance : ", 0
promptAmt     BYTE "Enter amount (Rs.) : ", 0
msgInvalid    BYTE "Invalid amount.", 0
msgNoFunds    BYTE "Insufficient balance.", 0
msgNot500     BYTE "Amount must be a multiple of 500.", 0
msgOverflow   BYTE "Deposit rejected - balance limit exceeded.", 0
msgDepositOk  BYTE "Deposit successful.", 0
msgWdrOk      BYTE "Withdrawal successful. Please collect your cash.", 0
labelDispense BYTE "Dispensing:", 0
labelX        BYTE " x Rs. ", 0

.code

;======================== SHOW BALANCE PROC ===============================
ShowBalance PROC USES ebx, accIndex:DWORD
    INVOKE DrawHeader, ADDR titleBalance
    INVOKE DrawBox, TEXT_COL-3, BODY_ROW+1, 44, 3               ;width = 44 , height = 3
    INVOKE PrintAt, TEXT_COL,   BODY_ROW+2, ADDR labelBalance

    mov ebx, accIndex
    NVOKE PrintMoney, DWORD PTR accBalance[ebx*8], DWORD PTR accBalance[ebx*8+4]
    INVOKE PressAnyKey
    ret
ShowBalance ENDP

;=========================== DEPOSIT PROC =================================
Deposit PROC USES ebx, accIndex:DWORD
    INVOKE DrawHeader, ADDR titleDep
    INVOKE PrintAt, TXT_COL, BODY_ROW+2, ADDR promptAmt
    INVOKE ReadAmount               ; EAX = amount, 0 = invalid
    cmp eax, 0
    je  DepInvalid

    mov ebx , accIndex
    ADD DWORD PTR accBalance[ebx*8] , eax    ;low half of balance  + low half of amount(eax)
    ADD DWORD PTR accBalance[ebx*8+4] , 0    ;high half of balance + high half of amount(eax)
    jc DepOverflow

    INVOKE RecordTxn, accIndex, TXN_DEPOSIT, eax
    INVOKE ShowProcessing
    INVOKE ShowSuccess, ADDR msgDepositOk
    INVOKE PrintAt, TXT_COL, BODY_ROW+4, ADDR labelBalance
    INVOKE PrintMoney, DWORD PTR accBalance[ebx*8], DWORD PTR accBalance[ebx*8+4]
    jmp DepDone

 DepInvalid:
    INVOKE ShowError, ADDR msgInvalid

DepOverflow:                                ; undo the add, balance stays the same
    sub DWORD PTR accBalance[ebx*8],   eax
    sbb DWORD PTR accBalance[ebx*8+4], 0
    INVOKE ShowError, ADDR msgOverflow
    jmp DepDone

DepDone:
    INVOKE PressAnyKey
    ret   
Deposit ENDP

;---------------------------------------------------------------------
Withdraw PROC USES ebx edx, accIndex:DWORD
;---------------------------------------------------------------------
    ; TODO 1: ReadAmount -> 0 ? invalid
    ; TODO 2: amount mod NOTE_SMALL must be 0  (DIV) else msgNot500
    ; TODO 3: if high dword of balance = 0 and low dword < amount -> msgNoFunds
    ; TODO 4: SUB DWORD PTR accBalance[ebx*8],   eax
    ;         SBB DWORD PTR accBalance[ebx*8+4], 0
    ; TODO 5: RecordTxn TXN_WITHDRAW, ShowProcessing,
    ;         INVOKE DispenseCash, amount, ShowSuccess msgWdrOk
    ret
Withdraw ENDP

;---------------------------------------------------------------------
DispenseCash PROC USES eax ebx edx, amount:DWORD
; Prints e.g.  Dispensing: 2 x Rs. 5000, 1 x Rs. 1000, 1 x Rs. 500
; amount / NOTE_BIG -> count (EAX), remainder (EDX) -> / NOTE_MID ...
; After each DIV:  XCHG eax, edx  -> remainder becomes the next
; dividend in EAX, the note count moves to EDX for printing.
; Remember: XOR edx, edx before every 32-bit DIV.
;---------------------------------------------------------------------
    ; TODO: three DIVs, skip notes whose count is 0
    ret
DispenseCash ENDP

END
