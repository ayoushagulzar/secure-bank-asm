;=====================================================================
; Concepts : RECURSION with EBP stack frames, 64-bit division using
;            two 32-bit DIVs, ReadDec + carry flag validation
;=====================================================================
INCLUDE Irvine32.inc
INCLUDE bank_shared.inc

.data
labelRs  BYTE "Rs. ", 0

.code

;========================== PRINT QWORD PROC ==========================
; Prints an unsigned 64-bit number RECURSIVELY:
;     if value >= 10: PrintQword(value / 10)
;     print digit (value mod 10) + '0'

PrintQword PROC, valLow:DWORD, valHi:DWORD
    LOCAL quotientLow:DWORD, quotientHi:DWORD, digit:DWORD

    push eax   ;explicit PUSH/POP (not USES) so the stack frame is visible in the debugger
    push ebx
    push edx

    mov ebx , 10                    ;divisor        
    xor edx , edx
    mov eax , valHi
    div ebx                         ; EAX = valHi / 10 (quotient),  EDX = remainder
    mov quotientHi , eax

    mov eax , valLow                ; EDX:EAX = remainder:low  (EDX NOT cleared)
    div ebx                         ; EAX = quotient, EDX = digit
    mov quotientLow , eax           ; bottom half of the quotient
    mov digit , edx                 ; the digit we extracted (0..9)

    mov eax , quotientLow
    OR eax , quotientHi             ; quotient = 0 ? -> base case (0 when both halves are zero)
    jz printDigit

    INVOKE PrintQword, quotientLow, quotientHi     ; recursive call prints the other digits first

    printDigit:
        mov eax , digit
        add al , '0'                ; digit -> ASCII ('0' = 48, so any digit 0-9 becomes digit + 48)
        call WriteChar

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

;========================== READ AMOUNT PROC ==========================
ReadAmount PROC
    call ReadDec          ;sets CF=1 on invalid input -> JC invalid
    jc invalidAmount
    ret 
invalidAmount:
    xor eax, eax
    ret
ReadAmount ENDP

END
