//=====================================================================
// Concepts : INLINE ASSEMBLY - an __asm block inside a C++
//            function, C++ variables/parameters used by name,
//            extern "C" (no name mangling, C calling convention)
//=====================================================================
// Called from interest_calculator.asm with:
//     INVOKE CalcYearInterest, amount, INTEREST_RATE
// The result (one year's interest) comes back in EAX.

extern "C" unsigned int CalcYearInterest(unsigned int amount, unsigned int rate)
{
    unsigned int interest;

    __asm
    {
        mov  eax, amount; C++ parameter used by name
        mul  rate; EDX:EAX = amount * rate
        mov  ebx, 100
        div  ebx; EAX = (amount * rate) / 100
        mov  interest, eax; store the result in a C++ variable
    }

    return interest;            // returned to the assembly caller in EAX
}