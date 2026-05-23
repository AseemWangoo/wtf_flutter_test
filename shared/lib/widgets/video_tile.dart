import 'package:flutter/material.dart';
import 'package:hmssdk_flutter/hmssdk_flutter.dart';

import '../utils/app_colors.dart';

class VideoTile extends StatelessWidget {
  const VideoTile({
    super.key,
    required this.label,
    this.track,
    this.mirror = false,
  });

  final String label;
  final HMSVideoTrack? track;
  final bool mirror;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: ColoredBox(
        color: AppColors.neutral900,
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (track != null)
              HMSVideoView(
                track: track!,
                key: Key(track!.trackId),
                setMirror: mirror,
                scaleType: ScaleType.SCALE_ASPECT_FILL,
              )
            else
              Center(
                child: Icon(
                  Icons.videocam_off_outlined,
                  color: Colors.white.withValues(alpha: 0.5),
                  size: 48,
                ),
              ),
            Positioned(
              left: 8,
              bottom: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  label,
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
