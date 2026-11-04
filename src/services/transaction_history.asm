;=====================================================================
; transaction_history.asm  -  Transaction history (2D circular buffer)
;---------------------------------------------------------------------
; Owner    : Batool Zehra 
; Concepts : TWO-DIMENSIONAL ARRAY (row = account, column = slot),
;            row-major addressing: index = accIndex * MAX_TXN + slot,
;            MUL / scaled indexing, circular buffer with wrap-around,
;            LOOP for display
;=====================================================================
INCLUDE Irvine32.inc
INCLUDE bank_shared.inc

.data
titleHist   BYTE "TRANSACTION HISTORY", 0
hdrHist     BYTE " #   TYPE            AMOUNT (Rs.)", 0
msgEmpty    BYTE "No transactions yet.", 0
strDep      BYTE "Deposit       ", 0
strWdr      BYTE "Withdraw      ", 0
strXOut     BYTE "Transfer Out  ", 0
strXIn      BYTE "Transfer In   ", 0
strInt      BYTE "Interest      ", 0

.code
;---------------------------------------------------------------------
RecordTxn PROC USES eax ebx ecx edx, accIndex:DWORD, tType:DWORD, amount:DWORD
; Called by Deposit / Withdraw / Transfer / CalcInterest.
;   slot  = txnNext[accIndex]
;   pos   = accIndex * MAX_TXN + slot
;   txnType[pos]       = tType   (BYTE)
;   txnAmount[pos*4]   = amount  (DWORD)
;   txnNext[accIndex]  = (slot + 1) mod MAX_TXN     <- wrap-around
;   if txnCount[accIndex] < MAX_TXN : INC txnCount[accIndex]
;---------------------------------------------------------------------
    ; TODO
    ret
RecordTxn ENDP

;---------------------------------------------------------------------
ShowHistory PROC USES eax ebx ecx edx esi, accIndex:DWORD
; DrawHeader titleHist, print hdrHist, then the filled slots
; from OLDEST to NEWEST:
;   start = (txnNext - txnCount + MAX_TXN) mod MAX_TXN
; Color tip: deposits/credits in CLR_SUCCESS, debits in CLR_ERROR.
; Empty history -> ShowInfo msgEmpty. Finish with PressAnyKey.
;---------------------------------------------------------------------
    ; TODO
    ret
ShowHistory ENDP

END
