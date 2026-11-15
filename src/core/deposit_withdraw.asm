;=====================================================================
; Concepts : 64-bit arithmetic ADD/ADC and SUB/SBB on QWORD balances,
;            JC for overflow, CMP/JB for insufficient balance,
;            DIV for note breakdown, scaled indexing [ebx*8]
;=====================================================================
INCLUDE Irvine32.inc
INCLUDE bank_shared.inc

TEXT_COL = 22                    ; screen text starts here
MIN_AMOUNT = 500                 ; min amount allowed per transaction
.data
titleBalance  BYTE "BALANCE INQUIRY", 0
titleDep      BYTE "DEPOSIT", 0
titleWdr      BYTE "WITHDRAW", 0
labelBalance  BYTE "Available balance : ", 0
promptAmount  BYTE "Enter amount (Rs.) : ", 0
msgInvalid    BYTE "Invalid amount.", 0
msgNoFunds    BYTE "Insufficient balance.", 0
msgMinAmount  BYTE "Minimum transaction is Rs. 500.", 0
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
    INVOKE PrintMoney, DWORD PTR accBalance[ebx*8], DWORD PTR accBalance[ebx*8+4]
    INVOKE PressAnyKey
    ret
ShowBalance ENDP

;=========================== DEPOSIT PROC =================================
Deposit PROC USES ebx, accIndex:DWORD
    INVOKE DrawHeader, ADDR titleDep
    INVOKE PrintAt, TEXT_COL, BODY_ROW+2, ADDR promptAmount
    INVOKE ReadAmount               ; EAX = amount, 0 = invalid
    cmp eax, 0
    je  DepInvalid

    mov ebx , accIndex
    ADD DWORD PTR accBalance[ebx*8] , eax    ;low half of balance  + low half of amount(eax)
    ADC DWORD PTR accBalance[ebx*8+4] , 0    ;high half of balance + high half of amount (0) + carry
    jc DepOverflow

    INVOKE RecordTxn, accIndex, TXN_DEPOSIT, eax
    INVOKE ShowProcessing
    INVOKE ShowSuccess, ADDR msgDepositOk
    INVOKE PrintAt, TEXT_COL, BODY_ROW+4, ADDR labelBalance
    INVOKE PrintMoney, DWORD PTR accBalance[ebx*8], DWORD PTR accBalance[ebx*8+4]
    jmp DepDone

 DepInvalid:
    INVOKE ShowError, ADDR msgInvalid
    jmp DepDone

DepOverflow:                                ; undo the add, balance stays the same
    sub DWORD PTR accBalance[ebx*8],   eax
    sbb DWORD PTR accBalance[ebx*8+4], 0
    INVOKE ShowError, ADDR msgOverflow
    jmp DepDone

DepDone:
    INVOKE PressAnyKey
    ret   
Deposit ENDP

;=========================== WITHDRAW PROC =================================
Withdraw PROC USES eax ebx ecx, accIndex:DWORD
    INVOKE DrawHeader, ADDR titleWdr
    INVOKE PrintAt, TEXT_COL, BODY_ROW+2, ADDR promptAmount
    INVOKE ReadAmount
    cmp eax, 0
    je  InvalidAmount

    mov ecx, eax                    ; ECX = amount
    cmp ecx, MIN_AMOUNT             ; at least 500 ?
    jb  BelowMin                 ; below -> error

    mov ebx , accIndex
    cmp  DWORD PTR accBalance[ebx*8+4] , 0     ; enough money ?
    ja EnoughAmount                            ;high half of balance > 0 ---> there is enough amount remaining
    cmp  DWORD PTR accBalance[ebx*8] , ecx   
    jb NoFunds                                 ;low half of balance < amount

EnoughAmount:
    ;withdraw money: balance - amount
    sub DWORD PTR accBalance[ebx*8],   ecx       ;lower half
    sbb DWORD PTR accBalance[ebx*8+4], 0         ;higher half - borrow

    INVOKE RecordTxn, accIndex, TXN_WITHDRAW, ecx
    INVOKE ShowProcessing
    INVOKE PrintAt, TEXT_COL, BODY_ROW+3, ADDR labelBalance
    INVOKE PrintMoney, DWORD PTR accBalance[ebx*8], DWORD PTR accBalance[ebx*8+4]
    INVOKE DispenseCash, ecx
    INVOKE ShowSuccess, ADDR msgWdrOk
    jmp Done

BelowMin:
    INVOKE ShowError, ADDR msgMinAmount
    jmp Done

NoFunds:
    INVOKE ShowError, ADDR msgNoFunds
    jmp Done

InvalidAmount:
    INVOKE ShowError, ADDR msgInvalid
    jmp Done

Done:
    INVOKE PressAnyKey
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
