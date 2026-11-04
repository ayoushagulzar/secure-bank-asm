;=====================================================================
; number_input_output.asm  -  Number input / output helpers (used by everyone)
;---------------------------------------------------------------------
; Owner    : Ayousha
; Concepts : RECURSION with EBP stack frames, 64-bit division using
;            two 32-bit DIVs, ReadDec + carry flag validation
;=====================================================================
INCLUDE Irvine32.inc
INCLUDE bank_shared.inc

.data
lblRs       BYTE "Rs. ", 0

.code
;---------------------------------------------------------------------
PrintQword PROC, valLo:DWORD, valHi:DWORD
    LOCAL qLo:DWORD, qHi:DWORD, digit:DWORD
; Prints an unsigned 64-bit number RECURSIVELY:
;     if value >= 10: PrintQword(value / 10)
;     print digit (value mod 10) + '0'
;
; 64-bit / 10 with 32-bit DIV:
;     xor edx,edx ; mov eax,valHi ; div 10  -> qHi = eax, remainder in edx
;     mov eax,valLo ; div 10                -> qLo = eax, digit = edx
;     (edx from the first DIV is the top half of the second dividend)
;---------------------------------------------------------------------
    ; Uses explicit PUSH/POP (not USES) so the stack frame is visible
    ; in the debugger during the viva:
    push eax
    push ebx
    push edx
    ; TODO: implement as described; base case = quotient is 0
    ;       store quotient in qLo/qHi, remainder in digit,
    ;       recurse with INVOKE PrintQword, qLo, qHi, then print digit
    pop edx
    pop ebx
    pop eax
    ret
PrintQword ENDP

;---------------------------------------------------------------------
PrintMoney PROC USES eax, valLo:DWORD, valHi:DWORD
; SetColor CLR_MONEY, write "Rs. ", PrintQword, ResetColor
; (Bonus: thousands separators "50,000")
;---------------------------------------------------------------------
    ; TODO
    ret
PrintMoney ENDP

;---------------------------------------------------------------------
ReadAmount PROC
; Reads a positive amount with ReadDec.
; Returns EAX = amount, or 0 if input was invalid / zero / overflowed
; (ReadDec sets CF=1 on invalid input -> JC invalid).
;---------------------------------------------------------------------
    ; TODO: call ReadDec / jc bad / return eax ; bad: xor eax,eax
    xor eax, eax
    ret
ReadAmount ENDP

END
