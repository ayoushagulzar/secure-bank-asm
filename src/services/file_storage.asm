;=====================================================================
; Concepts : Irvine32 file I/O (CreateOutputFile, OpenInputFile,
;            WriteToFile, ReadFromFile, CloseFile), OFFSET arithmetic
;            to get the block size, error checking with CMP / JE
;=====================================================================
INCLUDE Irvine32.inc
INCLUDE bank_shared.inc

GetModuleFileNameA PROTO, hModule:DWORD, lpFilename:PTR BYTE, nSize:DWORD

.data
fileName    BYTE 260 DUP(0)                     ; full path, filled by MakeFilePath
dataPart    BYTE "data\bank.dat", 0
msgSaveFail BYTE "Could not save data\bank.dat", 0
fileHandle  DWORD ?

.code
;==================== MAKE FILE PATH PROC ====================
; D:\secure-bank-asm\Debug\SecureBank.exe -> D:\secure-bank-asm\data\bank.dat

MakeFilePath PROC USES eax ecx esi edi
    INVOKE GetModuleFileNameA, 0, ADDR fileName, SIZEOF fileName  ; eax = length
    mov edi, OFFSET fileName
    add edi, eax                ; edi -> 0 at the end of the path
    mov ecx, 2                  ; go back past 2 slashes ("SecureBank.exe", "Debug")
FindSlash:
    dec edi
    cmp BYTE PTR [edi], '\'
    jne FindSlash
    loop FindSlash              ; found one slash, look for the next

    inc edi                     ; edi -> first char after "secure-bank-asm\"
    mov esi, OFFSET dataPart
    mov ecx, SIZEOF dataPart    ; includes the 0 terminator
    cld
    rep movsb                   ; add "data\bank.dat"
    ret
MakeFilePath ENDP

;====================== SAVE DATA PROC ======================
; writes the whole bank data block to data\bank.dat

SaveData PROC USES eax ecx edx
    INVOKE MakeFilePath                 ; fileName = full path
    mov edx,offset  fileName
    Call CreateOutputFile

    cmp eax, INVALID_HANDLE_VALUE
    je SaveFail                             
    mov fileHandle,eax

    mov ecx,OFFSET bankDataEnd
    sub ecx,OFFSET bankDataStart

    mov edx, OFFSET bankDataStart
    mov eax,fileHandle
    Call WriteToFile

    mov eax,fileHandle
    Call CloseFile
    jmp done                                

SaveFail:                              
    INVOKE ShowError, ADDR msgSaveFail
    INVOKE PressAnyKey
done:

    ret
SaveData ENDP

;====================== LOAD DATA PROC ======================
; reads data\bank.dat back (missing file = first run, keep default accounts)

LoadData PROC USES eax ecx edx
      INVOKE MakeFilePath 
    mov edx,OFFSET fileName
    call OpenInputFile
    cmp eax,INVALID_HANDLE_VALUE
    je done

    mov fileHandle , eax

    mov ecx,OFFSET bankDataEnd
    sub ecx,OFFSET bankDataStart

    mov edx, OFFSET bankDataStart
    mov eax, fileHandle
    Call ReadFromFile

    mov eax,fileHandle 
    call CloseFile

done:
ret

  
LoadData ENDP

END