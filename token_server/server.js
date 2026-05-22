/**
 * Minimal 100ms auth token server.
 * GET /token?userId=&role=&roomId=
 * GET /health
 */
require('dotenv').config();

const express = require('express');
const cors = require('cors');
const jwt = require('jsonwebtoken');
const { v4: uuidv4 } = require('uuid');

const app = express();
app.use(cors());

const PORT = process.env.PORT || 3000;
const ACCESS_KEY = process.env.HMS_ACCESS_KEY;
const APP_SECRET = process.env.HMS_APP_SECRET;

/** Map app roles to 100ms template role names from your dashboard. */
const ROLE_MAP = {
  trainer: process.env.HMS_ROLE_TRAINER || 'host',
  member: process.env.HMS_ROLE_MEMBER || 'guest',
};

function mask(value) {
  if (!value || value.length < 8) return '***';
  return `${value.slice(0, 4)}…${value.slice(-4)}`;
}

function generateAuthToken({ userId, role, roomId }) {
  if (!ACCESS_KEY || !APP_SECRET) {
    throw new Error('HMS_ACCESS_KEY and HMS_APP_SECRET must be set in .env');
  }
  if (!roomId) {
    throw new Error('roomId query parameter is required');
  }

  const hmsRole = ROLE_MAP[role];
  if (!hmsRole) {
    throw new Error(`Invalid role "${role}". Use trainer or member.`);
  }

  const now = Math.floor(Date.now() / 1000);
  const payload = {
    access_key: ACCESS_KEY,
    room_id: roomId,
    user_id: userId,
    role: hmsRole,
    type: 'app',
    version: 2,
    iat: now,
    nbf: now - 60,
    exp: now + 24 * 60 * 60,
    jti: uuidv4(),
  };

  return jwt.sign(payload, APP_SECRET, { algorithm: 'HS256' });
}

app.get('/health', (_req, res) => {
  res.json({
    ok: true,
    accessKey: ACCESS_KEY ? mask(ACCESS_KEY) : null,
    roles: ROLE_MAP,
  });
});

app.get('/token', (req, res) => {
  try {
    const userId = req.query.userId;
    const role = req.query.role;
    const roomId = req.query.roomId;

    if (!userId || !role) {
      return res.status(400).json({
        error: 'userId and role query parameters are required',
      });
    }

    const token = generateAuthToken({ userId, role, roomId });
    res.json({
      token,
      userId,
      role,
      hmsRole: ROLE_MAP[role],
      roomId: roomId || null,
    });
  } catch (err) {
    console.error('[token]', err.message);
    res.status(500).json({ error: err.message });
  }
});

app.listen(PORT, () => {
  console.log(`[token_server] listening on http://localhost:${PORT}`);
  console.log(`[token_server] access key: ${ACCESS_KEY ? mask(ACCESS_KEY) : 'NOT SET'}`);
});
