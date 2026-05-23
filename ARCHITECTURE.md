# Architecture

## Overview

Monorepo with two Flutter apps and one shared Dart package. Cross-app “real-time” UX uses a **sync layer** (Firebase Firestore planned for Hour 1; local Hive cache + streams for UI). **100ms** handles RTC; a small **Node token server** mints join tokens.

```
┌─────────────┐     ┌─────────────┐
│  guru_app   │     │ trainer_app │
│  (Member)   │     │  (Trainer)  │
└──────┬──────┘     └──────┬──────┘
       │                   │
       └─────────┬─────────┘
                 ▼
          ┌─────────────┐
          │   shared    │  models · services · widgets · utils
          └──────┬──────┘
                 │
     ┌───────────┼───────────┐
     ▼           ▼           ▼
 Local cache   Sync bus    100ms SDK
 (Hive)     (Firestore)   (hmssdk_flutter)
                 │
                 ▼
          ┌─────────────┐
          │token_server │  GET /token?userId&role&roomId
          └─────────────┘
```

## Layering (per app)

| Layer | Location | Responsibility |
|-------|----------|----------------|
| UI | `lib/features/<feature>/` | Screens, widgets |
| State | `lib/features/<feature>/providers/` | Riverpod notifiers / providers |
| Domain | `shared/lib/services/` | Auth, Chat, Call, Log abstractions |
| Data | `shared/lib/services/*_impl.dart` | Hive + sync adapters |

## 100ms RTC flow

1. Trainer **approves** `CallRequest` → create room via Management API (or reuse `hmsRoomId`) → persist `RoomMeta`.
2. Within 10 minutes of `scheduledFor`, both apps show **Join Call**.
3. **Pre-join**: fetch `GET /token?userId=&role=&roomId=` from `token_server`.
4. Join with `hmssdk_flutter`; roles: `trainer` → template host role, `member` → guest/participant role (names from 100ms dashboard — see `token_server/README.md`).
5. **End call** → write `SessionLog`, show rating / notes sheets.

## Role mapping (Video Conferencing template)

| App role | Query param `role` | 100ms template role (configure in dashboard) |
|----------|-------------------|-----------------------------------------------|
| Trainer (Aarav) | `trainer` | `host` (or template default moderator) |
| Member (DK) | `member` | `guest` (or `participant`) |

Document exact role strings from your 100ms template in `token_server/.env` as `HMS_ROLE_TRAINER` / `HMS_ROLE_MEMBER`.

## Observability

Structured log tags: `[AUTH]`, `[CHAT]`, `[RTC]`, `[SCHEDULE]`, `[LOG]`. **DevPanel** (debug builds) surfaces last 20 entries via floating **⋮** on app home.

## Security

- No live keys in repo; `.env.example` only.
- Token server reads secrets from `token_server/.env`.
- Android emulator uses `10.0.2.2` to reach host `localhost`.
