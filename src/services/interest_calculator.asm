;=====================================================================
; Concepts : MUL and DIV (interest = balance * rate / 100),
;            LOOP for compound projection over N years
;=====================================================================
INCLUDE Irvine32.inc
INCLUDE bank_shared.inc

TEXT_COL = 22

.data
titleInt    BYTE "INTEREST CALCULATOR", 0
lblRate     BYTE "Annual rate        : 5 %", 0
lblYearly   BYTE "Interest (1 year)  : ", 0
promptYears BYTE "Project for how many years (1-10)? ", 0
lblYear     BYTE "  Year ", 0
lblArrow    BYTE "  ->  ", 0
msgBadYears BYTE "Please enter 1 to 10 years.", 0

.code
;====================== CALC INTEREST PROC ======================
; interest for 1 year + year-by-year compound projection (display only)

CalcInterest PROC USES eax ebx ecx edx esi, accIndex:DWORD
    LOCAL amt:DWORD, yearNo:DWORD
    INVOKE DrawHeader, ADDR titleInt
    INVOKE PrintAt, TEXT_COL, BODY_ROW+1, ADDR lblRate
    INVOKE PrintAt, TEXT_COL, BODY_ROW+2, ADDR lblYearly

    mov  esi, accIndex
    mov  eax, DWORD PTR accBalance[esi*8]
    mov  ebx, INTEREST_RATE
    mul  ebx
    mov  ebx, 100
    div  ebx
    INVOKE PrintMoney, eax, 0

    INVOKE PrintAt, TEXT_COL, BODY_ROW+4, ADDR promptYears
    call ReadDec
    jc   errYears
    cmp  eax, 1
    jb   errYears
    cmp  eax, 10
    ja   errYears

    mov  ecx, eax
    mov  eax, DWORD PTR accBalance[esi*8]
    mov  amt, eax
    mov  yearNo, 0

yearLoop:
    push ecx

    mov  eax, amt
    mov  ebx, INTEREST_RATE
    mul  ebx
    mov  ebx, 100
    div  ebx
    add  amt, eax
    inc  yearNo

    mov  eax, yearNo
    add  eax, BODY_ROW+5                         ; year 1 -> BODY_ROW+6, year 2 -> BODY_ROW+7, ...
    INVOKE PrintAt, TEXT_COL, eax, ADDR lblYear
    mov  eax, yearNo
    call WriteDec

    mov  edx, OFFSET lblArrow
    call WriteString
    INVOKE PrintMoney, amt, 0

    pop  ecx
    dec  ecx
    jnz  yearLoop

    INVOKE PressAnyKey
    jmp  IntDone

errYears:
    INVOKE ShowError, ADDR msgBadYears
    INVOKE PressAnyKey

IntDone:
    ret
CalcInterest ENDP

END