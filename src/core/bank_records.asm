;=====================================================================
; bank_records.asm  -  All bank records (shared data)
;---------------------------------------------------------------------
; Owner    : Ayousha
; Concepts : BYTE/DWORD/QWORD definitions, multiple initialisation,
;            DUP, parallel arrays, 2D array (accounts x transactions),
;            LABEL to mark one contiguous block for file saving
;
; Layout rule: index i means the SAME account in every array.
;   accNo[i*4]  accName[i*NAME_LEN]  accPinHash[i*4]  accBalance[i*8]
;   accStatus[i]  accFailCount[i]
;
; Demo accounts  (PINs are stored only as hashes):
;   1001  Ali Khan      PIN 1234   Rs. 50,000
;   1002  Sara Ahmed    PIN 4321   Rs. 30,000
;   1003  Usman Tariq   PIN 1111   Rs. 75,000
;   1004  Hina Raza     PIN 2580   Rs.  1,200   (LOCKED - for admin unlock demo)
;   Admin password: admin123
;
; Hash test values (HashString must produce exactly these):
;   "1234" -> 83A5ABCFh   "4321" -> C0D647C2h   "1111" -> 83B3ABE2h
;   "2580" -> 7438050Bh   "admin123" -> E3CBBFC5h
;=====================================================================
INCLUDE Irvine32.inc
INCLUDE bank_shared.inc

.data
;===================== START OF SAVED BLOCK ==========================
bankDataStart LABEL BYTE

accCount    DWORD 4

accNo       DWORD 1001, 1002, 1003, 1004
            DWORD (MAX_ACCOUNTS - 4) DUP(0)

accName     BYTE  "Ali Khan",    (NAME_LEN - 8)  DUP(0)
            BYTE  "Sara Ahmed",  (NAME_LEN - 10) DUP(0)
            BYTE  "Usman Tariq", (NAME_LEN - 11) DUP(0)
            BYTE  "Hina Raza",   (NAME_LEN - 9)  DUP(0)
            BYTE  ((MAX_ACCOUNTS - 4) * NAME_LEN) DUP(0)

accPinHash  DWORD 083A5ABCFh, 0C0D647C2h, 083B3ABE2h, 07438050Bh
            DWORD (MAX_ACCOUNTS - 4) DUP(0)

accBalance  QWORD 50000, 30000, 75000, 1200
            QWORD (MAX_ACCOUNTS - 4) DUP(0)

accStatus   BYTE  0, 0, 0, STATUS_LOCKED
            BYTE  (MAX_ACCOUNTS - 4) DUP(0)

accFailCount BYTE MAX_ACCOUNTS DUP(0)

; ---- Transaction history: 2D array, rows = accounts, cols = MAX_TXN ----
txnType     BYTE  (MAX_ACCOUNTS * MAX_TXN) DUP(TXN_NONE)
txnAmount   DWORD (MAX_ACCOUNTS * MAX_TXN) DUP(0)
txnNext     DWORD MAX_ACCOUNTS DUP(0)
txnCount    DWORD MAX_ACCOUNTS DUP(0)

bankDataEnd LABEL BYTE
;===================== END OF SAVED BLOCK ============================

adminHash   DWORD 0E3CBBFC5h            ; HashString("admin123")

END
