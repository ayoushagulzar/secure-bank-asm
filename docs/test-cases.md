# Test Cases

Each owner tests their own rows first. Before the demo, the **other** person runs all rows again: a fresh pair of eyes finds the bugs you can't see. Mark ✅ or ❌.

| # | Module | Owner | Test | Expected result | Result |
|---|---|---|---|---|---|
| 1 | Login | Ayousha | Account 1001, PIN 1234 | Login successful | |
| 2 | Login | Ayousha | Account 9999 | "Account not found" | |
| 3 | Login | Ayousha | Wrong PIN 3 times on 1002 | Account locked | |
| 4 | Login | Ayousha | Log in to locked 1004 | "Account is LOCKED" | |
| 5 | Login | Ayousha | PIN typing | Shows `****`, Backspace works | |
| 6 | Deposit | Ayousha | Deposit 0 / letters | "Invalid amount" | |
| 7 | Deposit | Ayousha | Deposit 5000 | Balance +5000, history entry | |
| 8 | Withdraw | Ayousha | More than balance | "Insufficient balance" | |
| 9 | Withdraw | Ayousha | 1300 (not a multiple of 500) | Error message | |
| 10 | Withdraw | Ayousha | 6500 | 1×5000, 1×1000, 1×500 dispensed | |
| 11 | Transfer | Batool | To own account | Error | |
| 12 | Transfer | Batool | To 1004 (locked) | Error | |
| 13 | Transfer | Batool | 1001 → 1002, 2000 | Both balances and both histories updated | |
| 14 | Interest | Batool | 3-year projection on 50,000 | 52,500 / 55,125 / 57,881 | |
| 15 | History | Batool | 11+ transactions | Only the last 10 shown, oldest first | |
| 16 | Change PIN | Batool | Wrong old PIN | Error | |
| 17 | Change PIN | Batool | Confirm doesn't match | Error | |
| 18 | Change PIN | Batool | Valid change, then log in with the new PIN | Works | |
| 19 | Admin | Batool | Wrong password | "Access denied" | |
| 20 | Admin | Batool | List accounts | Table with colored ACTIVE/LOCKED | |
| 21 | Admin | Batool | Unlock 1004, then log in | Works | |
| 22 | Storage | Batool | Deposit, exit, reopen | Balance kept | |
| 23 | Storage | Batool | Delete `data/bank.dat`, run | Default accounts load | |
| 24 | Menu | Ayousha | Option 9 / letters | "Invalid option" | |
