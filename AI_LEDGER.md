# AI Ledger

Structured log of AI-assisted work for the WTF Flutter assessment. Update on every meaningful prompt.

---

## Prompt #1 — Hour 0 setup & docs shell

| Field | Value |
|-------|-------|
| **Tool** | Cursor (Claude) |
| **Intent** | Scaffold monorepo: docs, `shared` package, `token_server`, Riverpod app shells, ADRs |
| **Output** | `README.md`, `ARCHITECTURE.md`, `DECISIONS.md` (ADRs 1–4), `shared/` package, Node token server, themed `main.dart` stubs |
| **Commit** | `chore: hour-0 setup — docs shell, shared package, token server` (pending) |

**Snippet (ADR choice):** Riverpod for state; Hive + Firestore sync boundary; 100ms token server separate from Flutter.

---

## Prompt #3 — Hour 2 chat UI

| Field | Value |
|-------|-------|
| **Tool** | Cursor (Claude) |
| **Intent** | Chat list, conversation bubbles, typing sim, read receipts, quick replies, Firestore sync |
| **Output** | `ConversationPage`, `ChatListPage`, chat providers, typing in Firestore, shared widgets |
| **Commit** | `feat: hour-2 chat UI with Firestore sync and read receipts` (pending) |

---

## Prompt #2 — Hour 0.5–1.5 shared foundation

| Field | Value |
|-------|-------|
| **Tool** | Cursor (Claude) |
| **Intent** | Seed data (DK/Aarav), Hive auth, Firestore chat/calls, Riverpod providers, onboarding + home shells |
| **Output** | `SeedData`, `HiveAuthService`, `FirestoreChatService`, `FirestoreCallService`, `GuruAppGate`, `TrainerAppGate`, scheduler utils tests |
| **Commit** | `feat: hour-1 shared foundation — seed, services, onboarding, home` (pending) |

**Snippet:** Cross-app sync via Firestore emulator; local session logs in Hive; `FakeAuthService` for widget tests.

---

## Debugging with AI

| # | Error | AI steps | Fix |
|---|-------|----------|-----|
| 1 | | | |

---

## Refactor with AI

| # | Before | After | Commit |
|---|--------|-------|--------|
| 1 | | | |

---

_Checklist: ≥10 meaningful entries · ≥6 commits referencing AI before submission._
