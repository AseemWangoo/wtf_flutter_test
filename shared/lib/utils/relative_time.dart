/// Formats timestamps like "5m ago" for chat list previews.
String formatRelativeTime(DateTime dateTime, {DateTime? now}) {
  final reference = now ?? DateTime.now();
  final diff = reference.difference(dateTime);

  if (diff.isNegative || diff.inSeconds < 45) {
    return 'Just now';
  }
  if (diff.inMinutes < 60) {
    return '${diff.inMinutes}m ago';
  }
  if (diff.inHours < 24) {
    return '${diff.inHours}h ago';
  }
  if (diff.inDays < 7) {
    return '${diff.inDays}d ago';
  }
  return '${dateTime.month}/${dateTime.day}';
}
