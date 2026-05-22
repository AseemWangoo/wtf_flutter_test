# Architecture Decision Records (ADRs)

## ADR-001: State management — Riverpod

**Status:** Accepted  
**Context:** Two apps, shared services, async streams (chat, call state), testable providers.  
**Decision:** Use `flutter_riverpod` with `ProviderScope` at root; feature-scoped `Notifier` / `StreamProvider` for chat and schedules.  
**Alternatives considered:** Bloc (more boilerplate for 6h scope), Provider (less ergonomic for codegen/async).  
**Consequences:** Familiar patterns for `ref.watch` / `ref.read`; easy override in tests.

---

## ADR-002: Storage — Hive + sync adapter

**Status:** Accepted (sync TBD in Hour 1)  
**Context:** Assessment requires local persistence + “live” UX; optional Firebase for speed.  
**Decision:** **Hive** for structured local cache (users, messages, requests, logs). **Firestore** (or in-memory hub for dev-only) as cross-app sync when both emulators run.  
**Alternatives considered:** SQLite/drift (heavier setup), pure in-memory (fails two-device manual test).  
**Consequences:** Offline-friendly lists; need clear `ChatService` boundary so sync swap doesn’t touch UI.

---

## ADR-003: RTC strategy — 100ms SDK + local token server

**Status:** Accepted  
**Context:** 100ms is mandatory; tokens must not ship in the client.  
**Decision:** Minimal **Node/Express** `token_server` exposing `GET /token` using HMS access key + app secret (JWT v2). Room creation on approve via Management API or pre-created dev room. Client: `hmssdk_flutter` (added in Hour 4).  
**Alternatives considered:** Client-only dev tokens (rejected — secrets in app), serverless (time).  
**Consequences:** Emulator must use host IP / `10.0.2.2`; document role names from Video Conferencing template.

---

## ADR-004: Shared code packaging

**Status:** Accepted  
**Context:** Duplicate models across two apps violate DRY and assessment structure.  
**Decision:** `shared` as a **path dependency** Flutter package (`path: ../shared`).  
**Consequences:** Run `flutter pub get` in `shared` first; apps import `package:shared/...`.
