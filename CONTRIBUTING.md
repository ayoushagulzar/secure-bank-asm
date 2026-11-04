# How we work

Two people, one codebase, no broken builds. These rules keep it that way.

## 1. Every task is a GitHub Issue
One Issue per file (e.g. "Implement fund_transfer.asm"), assigned to its owner. Blockers and questions are written in the Issue, so nothing gets lost in chat.

## 2. Nobody commits straight to `main`
Work happens on a branch, goes in through a **Pull Request**, and the **other** person reviews it before it is merged.

| | Ayousha (command line) | Batool (GitHub website) |
|---|---|---|
| Start work | `git switch main` → `git pull` → `git switch -c feature/login` | Open the repo, go to `src/services/` |
| Save work | `git add <files>` → `git commit -m "feat(login): ..."` → `git push -u origin feature/login` | Add file → Upload files → choose **"Create a new branch… and start a pull request"** → name it `batool/fund-transfer` |
| Open PR | GitHub shows a **Compare & pull request** button | Opens automatically after upload |
| Update a PR | Commit + push to the same branch | Switch to your branch in the branch dropdown, then upload again |
| After merge | `git switch main` → `git pull` | Download a fresh ZIP before the next session |

## 3. Review each other's code
The reviewer reads every line, leaves comments, and approves. Reviewing is how **both** of you learn the whole project, and the instructor can ask either of you about any file in the viva.

## 4. Commit messages
`type(scope): what changed`, for example:
- `feat(transfer): block transfers to locked accounts`
- `fix(history): wrap index at MAX_TXN`
- `docs(readme): add demo GIF`

## 5. The shared header is a contract
`include/bank_shared.inc` is changed only by Ayousha, and only after both agree in an Issue. After it changes, both rebuild before continuing.

## 6. Naming conventions
| Thing | Style | Example |
|---|---|---|
| Files | snake_case, says what it does | `fund_transfer.asm` |
| Procedures | PascalCase verb + noun | `RecordTxn`, `ShowHistory` |
| Data labels | camelCase | `accBalance`, `msgNoFunds` |
| Constants | UPPER_CASE | `MAX_TXN`, `CLR_ERROR` |
| Branches | `feature/<topic>` or `<name>/<topic>` | `batool/admin-panel` |

## 7. Definition of Done
A task is done only when every box in the pull request template is ticked.
