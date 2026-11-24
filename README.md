# Secure Bank: Mini ATM in x86 Assembly

<p align="center">
  <strong>A menu-driven ATM and banking system written in 32-bit x86 Assembly</strong><br>
  Computer Organization & Assembly Language (COAL) Lab Project · FAST-NUCES Karachi · Fall 2026
</p>

<p align="center">
  <img src="https://img.shields.io/badge/LANGUAGE-x86%20ASSEMBLY-3BA9F5?style=for-the-badge&labelColor=2A3142">
  <img src="https://img.shields.io/badge/COURSE-COAL-7057E8?style=for-the-badge&labelColor=2A3142">
  <img src="https://img.shields.io/badge/PURPOSE-LAB%20PROJECT-D63384?style=for-the-badge&labelColor=2A3142">
</p>

---

## About

Secure Bank is a console ATM written in **32-bit x86 Assembly (MASM)** with the **Irvine32** library, plus one small C++ module that uses **inline assembly** (`__asm`). It has hashed PINs, account locking, 64-bit balances, a transaction history kept in a 2D circular buffer, and data that is **saved to disk** between runs, all in a styled, colored console interface.

---

## Features

| Feature | Details |
|---|---|
| **Secure login** | Masked `****` PIN entry with Backspace. PINs are stored only as a hash built with `ROL`, `XOR` and `SHL`, never in plain form. |
| **Account lock** | Three wrong PINs lock the account: a status bit set with `OR` and checked with `TEST`. The lock is saved, so restarting does not reset it. |
| **Deposit** | 64-bit balances updated with `ADD` / `ADC`, with an overflow check. |
| **Withdraw** | Any amount from Rs. 500 up to the available balance, using `SUB` / `SBB`. Shows the amount withdrawn and the new balance. |
| **Money formatting** | Balances printed as `Rs. 50,000` by a recursive procedure that splits a 64-bit number with two 32-bit `DIV`s. |
| **Fund transfer** | Between accounts, with checks for unknown, own and locked receiver accounts and insufficient balance. |
| **Interest calculator** | 5% interest for one year plus a year-by-year compound projection (1 to 10 years). The interest itself is calculated by `CalcYearInterest`, a C++ function whose body is an **inline assembly** (`__asm`) block using `MUL` / `DIV`, called from assembly with `PROTO C` + `INVOKE`. |
| **Transaction history** | Last 10 transactions per account in a two-dimensional circular buffer, oldest first, colored by type. |
| **Change PIN** | Old PIN check, new PIN confirmed with `CMPSB`, PIN buffers wiped with `STOSB`. |
| **Admin panel** | Hashed admin password, table of all accounts with colored status, unlock with `AND`. |
| **Persistent storage** | All bank data lives in one memory block, saved to `data/bank.dat` with a single `WriteToFile` call and reloaded at startup. |
| **Console UI** | Double-line box frames, a consistent color scheme, text centered with `SCASB`, splash screen with loading bar. |

---

## Project Structure

```text
secure-bank-asm/
├── .github/
│   └── pull_request_template.md
├── include/
│   └── bank_shared.inc
├── src/
│   ├── core/
│   │   ├── bank_records.asm
│   │   ├── deposit_withdraw.asm
│   │   ├── login_security.asm
│   │   ├── main_menu.asm
│   │   └── number_input_output.asm
│   ├── services/
│   │   ├── admin_panel.asm
│   │   ├── change_pin.asm
│   │   ├── file_storage.asm
│   │   ├── fund_transfer.asm
│   │   ├── interest_calculator.asm
│   │   ├── interest_inline.cpp
│   │   └── transaction_history.asm
│   └── ui/
│       └── console_ui.asm
├── data/
├── docs/
│   ├── screenshots/
│   ├── COAL_Project_Proposal.pdf
│   ├── COAL_Project_Final_Report.pdf
│   └── test-cases.md
├── CONTRIBUTING.md
├── LICENSE
├── README.md
├── SecureBank.sln
├── SecureBank.vcxproj
└── SecureBank.vcxproj.filters
```

---

## How to Build and Run

**Requirements:** Windows, Visual Studio 2022 or newer with the *Desktop development with C++* workload, and the [Irvine32 library](https://asmirvine.com/gettingStartedVS2022/index.htm) (usually installed in `C:\Irvine`).

1. Clone the repo, or download it with **Code → Download ZIP** and **extract** it.
2. Open `SecureBank.sln` in Visual Studio.
3. Set the configuration to **Debug | x86** and press **Ctrl + F5**. It must be x86: inline assembly only works in 32-bit programs.
4. The screens are laid out for an **80 × 25** console. In Windows Terminal, set **Settings → Startup → Launch size** to 80 columns and 25 rows, otherwise everything appears shifted to the left.

If your Irvine32 is not in `C:\Irvine`, add its path in **Project → Properties → Microsoft Macro Assembler → General → Include Paths** and **Linker → General → Additional Library Directories**. If Visual Studio offers to **retarget** the project, choose **Cancel**.

### Demo accounts

| Account | Name | PIN | Balance |
|:---:|---|:---:|---:|
| 1001 | Ali Khan | 1234 | Rs. 50,000 |
| 1002 | Sara Ahmed | 4321 | Rs. 30,000 |
| 1003 | Usman Tariq | 1111 | Rs. 75,000 |
| 1004 | Hina Raza | 2580 | Rs. 1,200 *(locked)* |

Admin password: `admin123`. To reset all data, delete `data/bank.dat`.

---

## Known Limitations

This is a learning project, not real banking software:
- The PIN hash is a simple custom function without a salt, so equal PINs give equal hashes. Real systems use salted, slow hashes such as bcrypt or Argon2.
- Amounts entered are limited to 32 bits (up to 4,294,967,295); balances are 64-bit.
- The interest calculator uses only the low 32 bits of the balance, so it is correct only for balances up to 4,294,967,295.
- `data/bank.dat` is not encrypted. Its path is built from the location of `SecureBank.exe` (two folders up), so keep the default build output folder.

---

## Project Report

- [Project Proposal](docs/Project_Proposal.pdf)
- [Final Project Report](docs/COAL_Project_Final_Report.pdf)

---

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md) for how the work was split, the Git workflow and the code conventions. All features are covered by the test cases in [docs/test-cases.md](docs/test-cases.md).

---

## Team

| Member | Role |
|---|---|
| **Ayousha Gulzar** | Group Leader |
| **Batool Zehra** | Team Member |

---

## Credits

- Kip R. Irvine, *Assembly Language for x86 Processors*, 8th ed., and the Irvine32 library
- Microsoft Macro Assembler (MASM) reference

---

## License

Released under the [MIT License](LICENSE).

---

<p align="center">
  <i>Built as the COAL Lab Project at FAST-NUCES Karachi, Fall 2026.</i>
</p>
