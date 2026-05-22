# 100ms Token Server

Minimal Express server that mints **100ms auth tokens** for the Guru and Trainer Flutter apps.

## Setup

```bash
cd token_server
cp .env.example .env
# Edit .env with values from https://dashboard.100ms.live/ → Developer
npm install
npm start
```

Server runs at `http://localhost:3000`.

## Endpoints

| Method | Path | Query | Response |
|--------|------|-------|----------|
| GET | `/health` | — | `{ ok, accessKey (masked), roles }` |
| GET | `/token` | `userId`, `role`, `roomId` | `{ token, userId, role, hmsRole, roomId }` |

### `role` values

| App | Query `role` | Maps to (default) |
|-----|--------------|-------------------|
| Trainer (Aarav) | `trainer` | `HMS_ROLE_TRAINER` → `host` |
| Member (DK) | `member` | `HMS_ROLE_MEMBER` → `guest` |

Override `HMS_ROLE_TRAINER` / `HMS_ROLE_MEMBER` in `.env` to match your template exactly.

### Example

```bash
curl "http://localhost:3000/token?userId=dk&role=member&roomId=YOUR_ROOM_ID"
```

## Android emulator

Flutter apps on the Android emulator should use:

```
TOKEN_SERVER_URL=http://10.0.2.2:3000
```

(`10.0.2.2` is the host machine from the emulator.)

## iOS simulator

Use `http://localhost:3000`.

## Security

- Never commit `.env`.
- Keys are masked in `/health` logs only.
