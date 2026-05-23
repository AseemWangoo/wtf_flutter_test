# AI Ledger

Structured log of AI-assisted work for the WTF Flutter assessment. Update on every meaningful prompt.

---

## Prompt #7 — Hour 6 polish, Members CRM, submission docs

| Field | Value |
|-------|-------|
| **Tool** | Cursor (Claude) |
| **Intent** | Trainer Members CRM, submission checklist, 9-step demo script, platform URL table, DevPanel debug-only |
| **Output** | `MembersPage`, `MemberSummary`, `SUBMISSION.md`, README end-to-end script |
| **Commit** | `feat: hour-6 members CRM, submission docs, and demo polish` (pending) |

---

## Prompt #6 — Hour 5 session logs UI & DevPanel

| Field | Value |
|-------|-------|
| **Tool** | Cursor (Claude) |
| **Intent** | Session logs list with filters, wire home navigation, DevPanel for last 20 structured logs |
| **Output** | `SessionLogsPage`, `SessionLogTile`, `DevLog`, `DevPanelShell`, `log_providers.dart` |
| **Commit** | `feat: hour-5 session logs UI with filters and DevPanel` (pending) |

---

## Prompt #5 — Hour 4 100ms video calls

| Field | Value |
|-------|-------|
| **Tool** | Cursor (Claude) |
| **Intent** | hmssdk_flutter CallFlowPage, pre-join, in-call controls, post-call logs, join buttons |
| **Output** | `call_flow_page.dart`, `join_call_helper.dart`, token client, Android/iOS permissions |
| **Commit** | `feat: hour-4 100ms video calls with pre-join and session logs` (pending) |

---

## Prompt #4 — Hour 3 scheduler

| Field | Value |
|-------|-------|
| **Tool** | Cursor (Claude) |
| **Intent** | Schedule UI, approve/decline, conflict checks, system chat messages, RoomMeta on approve |
| **Output** | `ScheduleCallPage`, `TrainerRequestsPage`, `ScheduleController`, day/time chips |
| **Commit** | `feat: hour-3 call scheduler with approve/decline workflow` (pending) |

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

## Prompt #1 — Hour 0 setup & docs shell

| Field | Value |
|-------|-------|
| **Tool** | Cursor (Claude) |
| **Intent** | Scaffold monorepo: docs, `shared` package, `token_server`, Riverpod app shells, ADRs |
| **Output** | `README.md`, `ARCHITECTURE.md`, `DECISIONS.md` (ADRs 1–4), `shared/` package, Node token server, themed `main.dart` stubs |
| **Commit** | `chore: hour-0 setup — docs shell, shared package, token server` (pending) |

**Snippet (ADR choice):** Riverpod for state; Hive + Firestore sync boundary; 100ms token server separate from Flutter.

---

## Prompt #8 — Post-call notes contrast fix

| Field | Value |
|-------|-------|
| **Tool** | Cursor (Claude) |
| **Intent** | Dark video screen made note TextFields unreadable while typing |
| **Output** | White filled `InputDecoration` + dark text in `_PostCallBody` |
| **Commit** | (include in hour-4/6 fix commit) |

---

## Prompt #9 — TOKEN_SERVER_URL platform guidance

| Field | Value |
|-------|-------|
| **Tool** | Cursor (Claude) |
| **Intent** | Clarify Android `10.0.2.2` vs iOS `localhost` for token server |
| **Output** | README platform table; matches existing `bootstrap.dart` Firestore hosts |
| **Commit** | (docs) |

---

## Debugging with AI

| # | Error | AI steps | Fix |
|---|-------|----------|-----|
| 1 | Post-call notes invisible on dark scaffold | Inspect `CallFlowPage` theme vs `TextField` defaults | White fill + explicit text/cursor colors |
| 2 | HMS `peer.tracks` compile error on 1.11.1 | Check hmssdk API for installed version | Use `peer.videoTrack` |
| 3 | Duplicate HMS listener methods | Merge single `HMSUpdateListener` impl | One method per callback |
| 4 | `DevLog` stream type mismatch | Analyzer on `StreamController.add` | Use `StreamController<void>.broadcast()` |
| 5 | Widget tests hung on SharedPreferences | Trace `HiveAuthService` in test bootstrap | `FakeAuthService` + short `pump` |

---

## Refactor with AI

| # | Before | After | Commit |
|---|--------|-------|--------|
| 1 | `debugPrint('[TAG]…')` scattered | Central `DevLog.log(tag, msg)` + DevPanel | Hour 5 |
| 2 | Trainer `SetupHomePage` in guru_app | Moved to `shared` for reuse | Hour 1 |
| 3 | "Coming soon" Sessions/Members stubs | Full `SessionLogsPage` + `MembersPage` | Hour 5–6 |

---

_Checklist: ≥10 meaningful entries · ≥6 commits referencing AI before submission._
