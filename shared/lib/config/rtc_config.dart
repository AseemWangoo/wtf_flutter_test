/// Runtime config for 100ms RTC (dart-define overrides).
abstract final class RtcConfig {
  /// Token server base URL. Android emulator → http://10.0.2.2:3000
  static const tokenServerUrl = String.fromEnvironment(
    'TOKEN_SERVER_URL',
    defaultValue: 'http://10.0.2.2:3000',
  );

  /// Optional fixed 100ms room id from dashboard (recommended for dev).
  static const devRoomId = String.fromEnvironment(
    'HMS_DEV_ROOM_ID',
    defaultValue: '',
  );

  /// When true, any approved call can be joined (assessment demo / simulate now).
  static const demoJoin = bool.fromEnvironment(
    'RTC_DEMO_JOIN',
    defaultValue: true,
  );
}
