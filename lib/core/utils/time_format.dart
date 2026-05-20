abstract final class TimeFormat {
  static String mmSs(int totalSeconds) {
    final safe = totalSeconds.clamp(0, 86400);
    final minutes = safe ~/ 60;
    final seconds = safe % 60;
    return '${minutes.toString().padLeft(2, '0')}:'
        '${seconds.toString().padLeft(2, '0')}';
  }
}
