# Test Cases

Both members run **every** row on their own machine and write **Pass** or **Fail** in their column. For a Fail, add a short note of what happened. Failures are fixed on a branch and re-tested by both.

**How to run:**
- Delete `data/bank.dat` before row 1, and again before every row marked **(fresh data)**. The program then starts with the 4 demo accounts.
- Run the rows **in order**: some rows depend on earlier ones (row 3 locks 1002, row 21 unlocks 1004).
- Demo accounts: 1001 / 1234, 1002 / 4321, 1003 / 1111, 1004 / 2580 (locked). Admin password: `admin123`.

| # | Module | Owner | Test | Expected result | Ayousha | Batool |
|---|---|---|---|---|---|---|
| 1 | Login | Ayousha | Account 1001, PIN 1234 | "Login successful." | | |
| 2 | Login | Ayousha | Account 9999 | "Account not found." | | |
| 3 | Login | Ayousha | Wrong PIN 3 times on 1002 | "Attempts left: 2", then 1, then "3 wrong attempts - account has been LOCKED." | | |
| 4 | Login | Ayousha | Log in to locked 1004 | "Account is LOCKED. Please contact the bank admin." | | |
| 5 | Login | Ayousha | Type a PIN, use Backspace | Shows `****`, Backspace removes one `*` | | |
| 6 | Deposit | Ayousha | 1001: deposit 0, then letters | "Invalid amount." | | |
| 7 | Deposit | Ayousha | 1001: deposit 5000 | "Deposit successful.", balance Rs. 55,000 | | |
| 8 | Withdraw | Ayousha | 1001: withdraw 100,000 | "Insufficient balance." | | |
| 9 | Withdraw | Ayousha | 1001: withdraw 1300 | "Withdrawal successful.", amount withdrawn Rs. 1,300, balance Rs. 53,700 | | |
| 10 | Withdraw | Ayousha | 1001: withdraw 6500 | Amount withdrawn Rs. 6,500, balance Rs. 47,200 | | |
| 11 | Withdraw | Ayousha | 1001: withdraw 300 | "Minimum transaction is Rs. 500." | | |
| 12 | Transfer | Batool | 1001: transfer to 1001 | "You cannot transfer to your own account." | | |
| 13 | Transfer | Batool | 1001: transfer to 1004 | "Receiver account is locked." | | |
| 14 | Transfer | Batool | 1001: transfer 2000 to 1003 | "Transfer successful.", 1001 = Rs. 45,200, 1003 = Rs. 77,000 | | |
| 15 | History | Batool | 1001: open history | Deposit 5000, Withdraw 1300, Withdraw 6500, Transfer Out 2000 (oldest first) | | |
| 16 | History | Batool | 1001: 11+ deposits, then open history | Only the last 10 shown, oldest first | | |
| 17 | Change PIN | Batool | 1003: wrong current PIN | "Current PIN is incorrect." | | |
| 18 | Change PIN | Batool | 1003: new PINs do not match | "New PINs do not match." | | |
| 19 | Change PIN | Batool | 1003: change 1111 to 2222, log out, log in with 2222 | "PIN changed successfully.", login works | | |
| 20 | Admin | Batool | Wrong password | "Access denied." | | |
| 21 | Admin | Batool | List accounts, then unlock 1004 and log in (2580) | Table with colored ACTIVE / LOCKED, "Account unlocked.", login works | | |
| 22 | Storage | Batool | Deposit 1000, exit (0), run again, check balance | Balance kept | | |
| 23 | Interest | Batool | **(fresh data)** 1001: 3-year projection | 1 year: Rs. 2,500. Years: Rs. 52,500 / Rs. 55,125 / Rs. 57,881 | | |
| 24 | Interest | Batool | Projection for 0 or 11 years | "Please enter 1 to 10 years." | | |
| 25 | Storage | Batool | **(fresh data)** run | Default accounts load (1001 = Rs. 50,000) | | |
| 26 | Menu | Ayousha | Option 9, then letters | "Invalid option. Please choose from the menu." | | |