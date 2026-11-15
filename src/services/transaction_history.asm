;=====================================================================
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
strGap      BYTE "   ", 0

.code
;====================== RECORD TXN PROC ======================
; stores one transaction in the 2D circular buffer (row = account, column = slot)

RecordTxn PROC USES eax ebx ecx edx, accIndex:DWORD, tType:DWORD, amount:DWORD
    mov  ebx, accIndex
    mov  ecx, txnNext[ebx*4]

    mov  eax, ebx
    imul eax, MAX_TXN
    add  eax, ecx

    mov  edx, tType
    mov  txnType[eax], dl

    mov  edx, amount
    mov  txnAmount[eax*4], edx

    inc  ecx
    cmp  ecx, MAX_TXN
    jb   noWrap
    xor  ecx, ecx
noWrap:
    mov  txnNext[ebx*4], ecx

    cmp  txnCount[ebx*4], MAX_TXN
    jae  skip
    inc  txnCount[ebx*4]
skip:
    ret
RecordTxn ENDP

;====================== SHOW HISTORY PROC ======================
; shows the saved transactions of an account, oldest first

ShowHistory PROC USES eax ebx ecx edx esi, accIndex:DWORD
    LOCAL rowNo:DWORD, pos:DWORD
    INVOKE DrawHeader, ADDR titleHist
    mov  edx, OFFSET hdrHist
    call WriteString
    call Crlf

    mov  esi, accIndex
    mov  ecx, txnCount[esi*4]
    cmp  ecx, 0
    je   empty

    mov  ebx, txnNext[esi*4]
    sub  ebx, ecx
    add  ebx, MAX_TXN
    cmp  ebx, MAX_TXN
    jb   ok
    sub  ebx, MAX_TXN
ok:
    mov  rowNo, 0

histLoop:
    push ecx

    inc  rowNo
    mov  eax, rowNo
    call WriteDec
    mov  edx, OFFSET strGap
    call WriteString

    mov  eax, esi
    imul eax, MAX_TXN
    add  eax, ebx
    mov  pos, eax

    movzx eax, txnType[eax]

    cmp  eax, TXN_DEPOSIT
    je   tDep
    cmp  eax, TXN_WITHDRAW
    je   tWdr
    cmp  eax, TXN_XFER_OUT
    je   tXOut
    cmp  eax, TXN_XFER_IN
    je   tXIn
    jmp  tInt

tDep:
    mov  eax, CLR_SUCCESS
    call SetTextColor
    mov  edx, OFFSET strDep
    jmp  printType
tWdr:
    mov  eax, CLR_ERROR
    call SetTextColor
    mov  edx, OFFSET strWdr
    jmp  printType
tXOut:
    mov  eax, CLR_ERROR
    call SetTextColor
    mov  edx, OFFSET strXOut
    jmp  printType
tXIn:
    mov  eax, CLR_SUCCESS
    call SetTextColor
    mov  edx, OFFSET strXIn
    jmp  printType
tInt:
    mov  eax, CLR_SUCCESS
    call SetTextColor
    mov  edx, OFFSET strInt

printType:
    call WriteString

    mov  eax, pos
    mov  eax, txnAmount[eax*4]
    INVOKE PrintMoney, eax, 0

    INVOKE ResetColor
    call Crlf

    inc  ebx
    cmp  ebx, MAX_TXN
    jb   noWrap2
    xor  ebx, ebx
noWrap2:
    pop  ecx
    dec  ecx
    jnz  histLoop

    INVOKE PressAnyKey
    jmp  HistDone

empty:
    INVOKE ShowInfo, ADDR msgEmpty
    INVOKE PressAnyKey

HistDone:
    ret
ShowHistory ENDP

END