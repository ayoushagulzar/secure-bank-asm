;=====================================================================
; Concepts : RECURSION with EBP stack frames, 64-bit division using
;            two 32-bit DIVs, ReadDec + carry flag validation
;=====================================================================
INCLUDE Irvine32.inc
INCLUDE bank_shared.inc

.data
labelRs  BYTE "Rs. ", 0
useCommas  BYTE 0           ; 1 = print commas (only PrintMoney turns it on)
depth      DWORD 0          ; recursion level = digit position from the right

.code

;========================== PRINT QWORD PROC ==========================
; Prints an unsigned 64-bit number RECURSIVELY:
;     if value >= 10: PrintQword(value / 10)
;     print digit (value mod 10) + '0'
; if useCommas = 1: comma after a digit when digits left = 3, 6, 9...

PrintQword PROC, valLow:DWORD, valHi:DWORD
    LOCAL quotientLow:DWORD, quotientHi:DWORD, digit:DWORD

    push eax   ;explicit PUSH/POP (not USES) so the stack frame is visible in the debugger
    push ebx
    push edx
    inc depth

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

;prints the digits with commas
printDigit:
    mov eax , digit
    add al , '0'                ; digit -> ASCII ('0' = 48, so any digit 0-9 becomes digit + 48)
    call WriteChar

    cmp useCommas, 1                ; commas switched on?
    jne noComma

    mov eax, depth
    dec eax                         ; EAX = digits still to come after this one
    jz  noComma                     ; 0 -> last digit, no comma

    xor edx, edx
    mov ebx, 3
    div ebx                         ; digits left / 3
    cmp edx, 0
    jne noComma                     ; not a multiple of 3
    mov al, ','
    call WriteChar
noComma:
    dec depth                       ; leaving this level

    pop edx
    pop ebx
    pop eax
    ret
PrintQword ENDP

;========================== PRINT MONEY PROC ==========================
PrintMoney PROC USES edx, valLo:DWORD, valHi:DWORD
    INVOKE SetColor, CLR_MONEY
    mov edx, OFFSET labelRs
    call WriteString
    
    mov useCommas, 1 
    INVOKE PrintQword, valLo , valHi
    mov useCommas, 0
    INVOKE ResetColor

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
