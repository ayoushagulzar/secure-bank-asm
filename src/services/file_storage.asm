;=====================================================================
; Concepts : Irvine32 file I/O (CreateOutputFile, OpenInputFile,
;            WriteToFile, ReadFromFile, CloseFile), OFFSET arithmetic
;            to get the block size, error checking with CMP / JE
;=====================================================================
INCLUDE Irvine32.inc
INCLUDE bank_shared.inc

.data
fileName    BYTE "data\bank.dat", 0
fileHandle  DWORD ?

.code
;====================== SAVE DATA PROC ======================
; writes the whole bank data block to data\bank.dat

SaveData PROC USES eax ecx edx
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

;====================== LOAD DATA PROC ======================
; reads data\bank.dat back (missing file = first run, keep default accounts)

LoadData PROC USES eax ecx edx
    
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