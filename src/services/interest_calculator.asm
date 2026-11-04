;=====================================================================
; interest_calculator.asm  -  Interest calculator
;---------------------------------------------------------------------
; Owner    : Batool Zehra 
; Concepts : MUL and DIV (interest = balance * rate / 100),
;            LOOP for compound projection over N years
;=====================================================================
INCLUDE Irvine32.inc
INCLUDE bank_shared.inc

.data
titleInt    BYTE "INTEREST CALCULATOR", 0
lblRate     BYTE "Annual rate        : 5 %", 0
lblYearly   BYTE "Interest (1 year)  : ", 0
promptYears BYTE "Project for how many years (1-10)? ", 0
lblYear     BYTE "  Year ", 0
lblArrow    BYTE "  ->  ", 0
msgBadYears BYTE "Please enter 1 to 10 years.", 0

.code
;---------------------------------------------------------------------
CalcInterest PROC USES eax ebx ecx edx, accIndex:DWORD
; 1) Simple interest for 1 year:
;       mov eax, balanceLo ; mov ebx, INTEREST_RATE ; MUL ebx  (EDX:EAX)
;       mov ebx, 100 ; DIV ebx            -> EAX = interest
;    (Assume the high dword of the balance is 0 for this calculation.)
; 2) Compound projection: ask N (1..10), then LOOP N times:
;       amount = amount + amount * INTEREST_RATE / 100
;    and print one line per year:  "Year 1  ->  Rs. 52,500"
; 3) Display only - this does NOT change the real balance.
;---------------------------------------------------------------------
    ; TODO
    ret
CalcInterest ENDP

END
