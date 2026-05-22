# WTF Flutter Assessment — Guru ↔ Trainer

Two Flutter apps (Member **DK** + Trainer **Aarav**) with real-time chat, call scheduling, **100ms** video, and session logs. Local-first; AI-native workflow documented in `AI_LEDGER.md`.

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

### 2. Flutter apps

```bash
# Guru (Member)
cd guru_app && flutter pub get && flutter run

# Trainer (separate terminal / second emulator)
cd trainer_app && flutter pub get && flutter run
```

Copy `guru_app/.env.example` → `guru_app/.env` and `trainer_app/.env.example` → `trainer_app/.env` (or use `--dart-define`) with:

- `TOKEN_SERVER_URL` — e.g. `http://10.0.2.2:3000` on Android emulator (host machine)
- `HMS_TEMPLATE_ID` — same as token server

### 3. Analyze (zero warnings target)

```bash
cd shared && flutter pub get && flutter analyze
cd ../guru_app && flutter pub get && flutter analyze
cd ../trainer_app && flutter pub get && flutter analyze
```

## Manual test script

See assessment doc section 6 — 9-step flow: onboard DK → chat → schedule → approve → join 100ms → end → session logs.

## Commits

Use [Conventional Commits](https://www.conventionalcommits.org/): `feat:`, `fix:`, `docs:`, `chore:`, `test:`, `refactor:`.

## Submission

- GitHub repo link
- 3-min demo video (end-to-end manual test)
- `AI_LEDGER.md` with ≥10 meaningful AI entries
