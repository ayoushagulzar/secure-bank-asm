;=====================================================================
; file_storage.asm  -  Save / load all bank data to a file
;---------------------------------------------------------------------
; Owner    : Batool Zehra 
; Concepts : Irvine32 file I/O (CreateOutputFile, OpenInputFile,
;            WriteToFile, ReadFromFile, CloseFile), OFFSET arithmetic
;            to get the block size, error checking with CMP / JE
;
; The whole block between bankDataStart and bankDataEnd (bank_records.asm) is
; written in ONE call, so balances, PIN hashes, lock status and
; history all survive after the program closes.
;=====================================================================
INCLUDE Irvine32.inc
INCLUDE bank_shared.inc

.data
fileName    BYTE "data\bank.dat", 0
fileHandle  DWORD ?

.code
;---------------------------------------------------------------------
SaveData PROC USES eax ecx edx
;---------------------------------------------------------------------
    ; TODO: mov edx, OFFSET fileName / call CreateOutputFile
    ;       cmp eax, INVALID_HANDLE_VALUE / je done
    ;       mov fileHandle, eax
    ;       mov ecx, OFFSET bankDataEnd / sub ecx, OFFSET bankDataStart  ; size
    ;       mov edx, OFFSET bankDataStart / mov eax, fileHandle
    ;       call WriteToFile / mov eax, fileHandle / call CloseFile

    mov edx,offset  fileName
Call CreateOutputFile

cmp eax, INVALID_HANDLE_VALUE
je done
mov fileHandle,eax

mov ecx,OFFSET bankDataEnd
sub ecx,OFFSET bankDataStart

mov edx, OFFSET bankDataStart
mov eax,fileHandle
Call WriteToFile

mov eax,fileHandle
Call CloseFile

done:

    ret
SaveData ENDP

;---------------------------------------------------------------------
LoadData PROC USES eax ecx edx
; If the file does not exist (first run), keep the default accounts
; from bank_records.asm - this is NOT an error.
;---------------------------------------------------------------------
    ; TODO: OpenInputFile -> INVALID_HANDLE_VALUE ? ret
    ;       ReadFromFile into bankDataStart with the same size, CloseFile
    
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
