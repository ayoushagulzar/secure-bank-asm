;=====================================================================
; deposit_withdraw.asm  -  Balance, Deposit, Withdraw, Cash dispensing
;---------------------------------------------------------------------
; Owner    : Ayousha
; Concepts : 64-bit arithmetic ADD/ADC and SUB/SBB on QWORD balances,
;            JC for overflow, CMP/JB for insufficient balance,
;            DIV for note breakdown, scaled indexing [ebx*8]
;=====================================================================
INCLUDE Irvine32.inc
INCLUDE bank_shared.inc

.data
titleBal    BYTE "BALANCE INQUIRY", 0
titleDep    BYTE "DEPOSIT", 0
titleWdr    BYTE "WITHDRAW", 0
lblBalance  BYTE "Available balance : ", 0
promptAmt   BYTE "Enter amount (Rs.) : ", 0
msgInvalid  BYTE "Invalid amount.", 0
msgNoFunds  BYTE "Insufficient balance.", 0
msgNot500   BYTE "Amount must be a multiple of 500.", 0
msgOverflow BYTE "Deposit rejected - balance limit exceeded.", 0
msgDepOk    BYTE "Deposit successful.", 0
msgWdrOk    BYTE "Withdrawal successful. Please collect your cash.", 0
lblDispense BYTE "Dispensing:", 0
lblX        BYTE " x Rs. ", 0

.code
;---------------------------------------------------------------------
ShowBalance PROC USES ebx, accIndex:DWORD
;---------------------------------------------------------------------
    ; TODO: DrawHeader titleBal
    ;       mov ebx, accIndex
    ;       INVOKE PrintMoney, DWORD PTR accBalance[ebx*8], DWORD PTR accBalance[ebx*8+4]
    ;       PressAnyKey
    ret
ShowBalance ENDP

;---------------------------------------------------------------------
Deposit PROC USES ebx, accIndex:DWORD
;---------------------------------------------------------------------
    ; TODO 1: DrawHeader titleDep, PrintAt promptAmt, INVOKE ReadAmount
    ;         EAX = 0 -> ShowError msgInvalid
    ; TODO 2: mov ebx, accIndex
    ;         ADD DWORD PTR accBalance[ebx*8],   eax
    ;         ADC DWORD PTR accBalance[ebx*8+4], 0
    ;         JC overflow  -> undo and ShowError msgOverflow
    ; TODO 3: INVOKE RecordTxn, accIndex, TXN_DEPOSIT, eax   (Batool)
    ;         ShowProcessing, ShowSuccess msgDepOk, show new balance
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
