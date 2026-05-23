import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../utils/app_colors.dart';
import '../utils/dev_log.dart';

final devLogEntriesProvider = StreamProvider<List<DevLogEntry>>(
  (ref) => DevLog.watchEntries(),
);

/// Wraps app root with a floating DevPanel trigger (assessment §8).
class DevPanelShell extends StatelessWidget {
  const DevPanelShell({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        child,
        if (kDebugMode)
          const Positioned(
            right: 12,
            bottom: 12,
            child: DevPanelFab(),
          ),
      ],
    );
  }
}

class DevPanelFab extends StatelessWidget {
  const DevPanelFab({super.key});

  void _openPanel(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => const DevPanelSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 4,
      shape: const CircleBorder(),
      color: AppColors.neutral900,
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: () => _openPanel(context),
        child: const SizedBox(
          width: 48,
          height: 48,
          child: Icon(Icons.more_vert, color: Colors.white),
        ),
      ),
    );
  }
}

class DevPanelSheet extends ConsumerWidget {
  const DevPanelSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final entriesAsync = ref.watch(devLogEntriesProvider);

    return SafeArea(
      child: SizedBox(
        height: MediaQuery.sizeOf(context).height * 0.55,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 12, 8),
              child: Row(
                children: [
                  Text('DevPanel', style: Theme.of(context).textTheme.titleLarge),
                  const Spacer(),
                  TextButton(
                    onPressed: () {
                      DevLog.clear();
                      ref.invalidate(devLogEntriesProvider);
                    },
                    child: const Text('Clear'),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: entriesAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (_, __) => const Center(child: Text('Log stream error')),
                data: (entries) {
                  if (entries.isEmpty) {
                    return Center(
                      child: Text(
                        'No logs yet. Use chat, schedule, or video to generate entries.',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppColors.neutral700,
                            ),
                      ),
                    );
                  }
                  return ListView.separated(
                    padding: const EdgeInsets.all(12),
                    itemCount: entries.length,
                    separatorBuilder: (_, __) => const Divider(height: 12),
                    itemBuilder: (context, index) {
                      final entry = entries[index];
                      return _DevLogRow(entry: entry);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DevLogRow extends StatelessWidget {
  const _DevLogRow({required this.entry});

  final DevLogEntry entry;

  Color _tagColor(String tag) {
    switch (tag) {
      case 'AUTH':
        return AppColors.guruPrimary;
      case 'CHAT':
        return AppColors.trainerPrimary;
      case 'RTC':
        return AppColors.warning;
      case 'SCHEDULE':
        return AppColors.success;
      case 'LOG':
        return AppColors.neutral900;
      default:
        return AppColors.neutral700;
    }
  }

  @override
  Widget build(BuildContext context) {
    final time = MaterialLocalizations.of(context).formatTimeOfDay(
      TimeOfDay.fromDateTime(entry.at),
    );
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(time, style: Theme.of(context).textTheme.labelSmall),
        const SizedBox(width: 8),
        Expanded(
          child: RichText(
            text: TextSpan(
              style: Theme.of(context).textTheme.bodySmall,
              children: [
                TextSpan(
                  text: '[${entry.tag}] ',
                  style: TextStyle(
                    color: _tagColor(entry.tag),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                TextSpan(text: entry.message),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
