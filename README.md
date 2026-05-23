# WTF Flutter Assessment — Guru ↔ Trainer

Two Flutter apps (Member **DK** + Trainer **Aarav**) with real-time chat, call scheduling, **100ms** video, and session logs. Local-first; AI-native workflow documented in `AI_LEDGER.md`.

## Demo video

**[Watch Demo.mp4](./Demo.mp4)** — ~3 min end-to-end flow (onboard → chat → schedule → approve → 100ms call → session logs).

## Repository layout

```
wtf_flutter_test/
├── README.md
├── AI_LEDGER.md
├── ARCHITECTURE.md
├── DECISIONS.md
├── .env.example              # Flutter app env (copy per app)
├── token_server/             # 100ms auth token HTTP service
├── shared/                   # Shared models, services, widgets, utils
├── guru_app/                 # Member app (primary #1769E0)
└── trainer_app/              # Trainer app (primary #E50914)
```

## Prerequisites

- Flutter SDK ≥ 3.7 (`flutter doctor`)
- Node.js ≥ 18 (token server)
- Android emulator or device (two instances for cross-app chat demo)
- [100ms](https://www.100ms.live/) Video Conferencing template + API credentials
- Firebase project **or** [Firebase Emulator Suite](https://firebase.google.com/docs/emulator-suite) (default for local sync)

## Quick start

### 1. Token server

```bash
cd token_server
cp .env.example .env
# Fill HMS_ACCESS_KEY, HMS_APP_SECRET, HMS_TEMPLATE_ID from 100ms dashboard
npm install
npm start
# → http://localhost:3000/health
```

### 2. Firebase (cross-app chat + call requests)

**Option A — Emulator (recommended for local demo)**

```bash
# Install Firebase CLI, then:
firebase init emulators   # select Firestore only
firebase emulators:start --only firestore
# Firestore UI: http://localhost:4000 — listens on :8080
```

Apps default to `USE_FIRESTORE_EMULATOR=true` and `10.0.2.2:8080` on Android.

**Option B — Real project**

```bash
dart pub global activate flutterfire_cli
flutterfire configure   # run inside guru_app and trainer_app
# Replace REPLACE_ME in lib/firebase_options.dart
flutter run --dart-define=USE_FIRESTORE_EMULATOR=false
```

### 3. Flutter apps

```bash
# Guru (Member) — onboarding DK → home (3 cards)
cd guru_app && flutter pub get && flutter run

# Trainer (separate terminal / second emulator) — login as Aarav → home (4 tiles)
cd trainer_app && flutter pub get && flutter run
```

Copy `guru_app/.env.example` → `guru_app/.env` and `trainer_app/.env.example` → `trainer_app/.env` (or use `--dart-define`) with:

- `TOKEN_SERVER_URL` — see [Host URLs by platform](#host-urls-by-platform) below
- `HMS_TEMPLATE_ID` — same as token server
- `HMS_DEV_ROOM_ID` — 100ms room id (for video calls)

### Host URLs by platform

| Target                       | Firestore emulator          | Token server                |
| ---------------------------- | --------------------------- | --------------------------- |
| Android emulator             | `10.0.2.2:8080` (default)   | `http://10.0.2.2:3000`      |
| iOS Simulator                | `localhost:8080`            | `http://localhost:3000`     |
| Physical device (same Wi‑Fi) | `http://<your-mac-ip>:8080` | `http://<your-mac-ip>:3000` |

Apps pick Firestore host automatically in `bootstrap.dart` (Android vs iOS). Override token URL with:

```bash
# Android emulator
flutter run --dart-define=TOKEN_SERVER_URL=http://10.0.2.2:3000

# iOS Simulator
flutter run --dart-define=TOKEN_SERVER_URL=http://localhost:3000
```

### 4. Analyze (zero warnings target)

```bash
cd shared && flutter pub get && flutter analyze
cd ../guru_app && flutter pub get && flutter analyze
cd ../trainer_app && flutter pub get && flutter analyze
```

## Manual test — Session logs & DevPanel (Hour 5)

1. Complete a video call (Hour 4) and submit rating / notes on both apps.
2. Guru → **My Sessions** — verify log shows date, duration, rating, note.
3. Trainer → **Sessions** — verify same call with trainer notes.
4. Toggle filters **All** / **7 days** / **Month** (empty state when no matches).
5. Tap floating **⋮** (DevPanel) on home — see last 20 tagged logs (`[AUTH]`, `[CHAT]`, `[RTC]`, `[SCHEDULE]`, `[LOG]`).

## Manual test — 100ms video (Hour 4)

1. Set `HMS_DEV_ROOM_ID` in `token_server/.env` (room id from [100ms dashboard](https://dashboard.100ms.live/)).
2. `cd token_server && npm start`
3. Approve a call (Hour 3), then on both apps tap **Join Call** (schedule / chat camera icon).
4. Pre-join → **Join Call** → mute/video/flip → **End** → rate / notes → session log.

```bash
# Optional: pass room id to Flutter
flutter run --dart-define=HMS_DEV_ROOM_ID=YOUR_ROOM_ID --dart-define=TOKEN_SERVER_URL=http://10.0.2.2:3000
```

## Manual test — Scheduler (Hour 3)

1. Firestore emulator running; Guru + Trainer apps open.
2. Guru → **Schedule Call** → pick Today → **6:00 PM** → note `Macros review` → **Request Call**.
3. Toast: _Call requested. Waiting for trainer approval._ — request shows under **My Requests**.
4. Trainer → **Requests** → see DK pending → **Approve**.
5. Guru chat shows system message: _Call approved for Today 6:00 PM._
6. Guru **Upcoming Calls** section lists approved slot. Try double-booking same slot → error.

## Manual test — Chat (Hour 2)

1. Start Firestore emulator (`firebase emulators:start --only firestore`).
2. Run **Trainer** → Continue as Aarav → **Chats** → open DK thread.
3. Run **Guru** on second emulator → complete onboarding → **Chat with Trainer**.
4. DK sends `Hi Coach 👋` → Trainer sees unread badge → open chat → reply.
5. Verify: blue (DK) / red (Aarav) bubbles, typing dots, ✓ / ✓✓ ticks, quick-reply chips.

## End-to-end demo script (9 steps)

Prerequisites: Firestore emulator, token server with valid 100ms `.env`, two emulators (Guru + Trainer).

| Step | App     | Action                                                        | Expected                                                 |
| ---- | ------- | ------------------------------------------------------------- | -------------------------------------------------------- |
| 1    | Guru    | Complete onboarding → assign Aarav                            | Home with 3 cards                                        |
| 2    | Guru    | **Chat with Trainer** → send `Hi Coach 👋`                    | Message appears; typing delay                            |
| 3    | Trainer | **Chats** → open DK → reply                                   | DK sees reply; read receipts update                      |
| 4    | Guru    | **Schedule Call** → Today → slot → note → **Request Call**    | Pending under My Requests                                |
| 5    | Trainer | **Requests** → **Approve**                                    | Guru chat system message; upcoming call listed           |
| 6    | Both    | **Join Call** (schedule or chat camera) → pre-join → **Join** | Two video tiles                                          |
| 7    | Both    | Mute / camera / flip → **End**                                | Post-call screen                                         |
| 8    | Guru    | Rate 1–5 + optional note → **Submit**                         | Session saved toast                                      |
| 9    | Both    | **My Sessions** / **Sessions**                                | Log with duration; filters; Trainer **Members** shows DK |

Debug: tap **⋮** DevPanel on home (debug builds) for tagged logs.

## Commits

Use [Conventional Commits](https://www.conventionalcommits.org/): `feat:`, `fix:`, `docs:`, `chore:`, `test:`, `refactor:`.

## Submission

See **[SUBMISSION.md](SUBMISSION.md)** for the full checklist.

- GitHub repo link
- Demo video: [Demo.mp4](./Demo.mp4) (or hosted link in your submission form)
- `AI_LEDGER.md` with ≥10 meaningful AI entries
