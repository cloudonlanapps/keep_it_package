import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/video_player_state.dart';

class PlaybackTypeBadge extends ConsumerWidget {
  const PlaybackTypeBadge({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(videoPlayerProvider).value;

    if (state == null || !state.isInitialized) {
      return const SizedBox.shrink();
    }

    final isHls = state.isHls;

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(
          color: Colors.black.withAlpha(150),
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: Colors.white24),
        ),
        child: Text(
          !isHls
              ? 'ORIGINAL'
              : 'STREAM', // If not HLS, it's ORIGINAL. Otherwise, it's STREAM.
          style: const TextStyle(
            color: Colors.white,
            fontSize: 10,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
