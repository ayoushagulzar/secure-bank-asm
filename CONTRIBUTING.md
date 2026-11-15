# How we worked

Secure Bank was built by a team of two. This file describes how we split the work and kept the code base building at every step.

## 1. Team and ownership

Every file has exactly one owner.

| Member | Owns | Also responsible for |
|---|---|---|
| **Ayousha** (Group Leader) | `include/`, `src/core/`, `src/ui/`, project files, `docs/` | Reviewing and merging every pull request, integration, README and CONTRIBUTING |
| **Batool Zehra** | `src/services/` | — |
| **Both** | — | Running all test cases, writing the project report |


## 2. Every task is a GitHub Issue

There is one Issue per source file, e.g. *"Implement fund_transfer.asm"*, assigned to its owner. The description lists the procedures to write and the test cases that cover them.

Pull requests close their Issue automatically with `Closes #<number>` in the description.

## 3. Nobody commits straight to `main`

All work happens on a branch and reaches `main` through a **pull request**.

| | Ayousha (command line) | Batool (GitHub website) |
|---|---|---|
| Start work | `git switch main` → `git pull` → `git switch -c feature/<topic>` | Download a fresh ZIP of `main` and extract it |
| Save work | One commit per finished procedure | Switch to the agreed branch in the branch dropdown → `src/services/` → **Add file → Upload files** → commit directly to that branch |
| Pull request | **Compare & pull request** on GitHub | Opened by the leader for the uploaded branch |
| Merge | **Merge pull request** (merge commit, so every commit stays in the history) → **Delete branch** | — |
| Afterwards | `git switch main` → `git pull` | Download a fresh ZIP before the next session |

## 4. The shared header is a contract

`include/bank_shared.inc` holds every constant, color, `PROTO` and shared data declaration.

## 5. Code conventions

| Thing | Style | Example |
|---|---|---|
| Files | snake_case, says what it does | `fund_transfer.asm` |
| Procedures | PascalCase verb + noun | `RecordTxn`, `ShowHistory` |
| Data labels | camelCase | `accBalance`, `msgNoFunds` |
| Constants | UPPER_CASE | `MAX_TXN`, `CLR_ERROR` |

- Every file starts with a header listing the COAL concepts used.
- Every procedure saves the registers it changes (`USES` or `PUSH`/`POP`), except `EAX` when it carries the result.
- Screens use only the helpers in `console_ui.asm` and the `CLR_*` colors from the shared header.

## 6. Testing

Both members run every row of [docs/test-cases.md](docs/test-cases.md) on their own machine. Failures are reported to the leader, fixed on a branch, and re-tested by both.

## 7. Project report

Both members write the report together, each covering their own modules, with shared sections for COAL concepts, testing, screenshots and contributions. The final version is exported as PDF and added to `docs/`.