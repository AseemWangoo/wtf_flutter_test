import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/user.dart';
import '../../providers/log_providers.dart';
import '../../utils/app_colors.dart';
import '../../utils/session_log_utils.dart';
import '../../widgets/session_log_tile.dart';

class SessionLogsPage extends ConsumerStatefulWidget {
  const SessionLogsPage({
    super.key,
    required this.currentUser,
    required this.primaryColor,
  });

  final User currentUser;
  final Color primaryColor;

  @override
  ConsumerState<SessionLogsPage> createState() => _SessionLogsPageState();
}

class _SessionLogsPageState extends ConsumerState<SessionLogsPage> {
  SessionLogFilter _filter = SessionLogFilter.all;

  @override
  Widget build(BuildContext context) {
    final logsAsync = ref.watch(sessionLogsProvider(widget.currentUser));
    final title = widget.currentUser.role == UserRole.member
        ? 'My Sessions'
        : 'Sessions';

    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: SegmentedButton<SessionLogFilter>(
              segments: SessionLogFilter.values
                  .map(
                    (f) => ButtonSegment(
                      value: f,
                      label: Text(sessionLogFilterLabel(f)),
                    ),
                  )
                  .toList(),
              selected: {_filter},
              onSelectionChanged: (selection) {
                setState(() => _filter = selection.first);
              },
            ),
          ),
          Expanded(
            child: logsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Could not load sessions: $e')),
              data: (logs) {
                final filtered = filterSessionLogs(logs, _filter);
                if (filtered.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.history,
                            size: 72,
                            color: AppColors.neutral700.withValues(alpha: 0.4),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            _filter == SessionLogFilter.all
                                ? 'No sessions yet. Complete a video call to see logs here.'
                                : 'No sessions in this period.',
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                  color: AppColors.neutral700,
                                ),
                          ),
                        ],
                      ),
                    ),
                  );
                }
                return ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: filtered.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) => SessionLogTile(
                    log: filtered[index],
                    viewerRole: widget.currentUser.role,
                    primary: widget.primaryColor,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
