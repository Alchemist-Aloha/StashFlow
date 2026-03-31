/// A centralized utility for mapping data between layers and formatting.
class DataMapper {
  /// Formats a duration in seconds into a human-readable string.
  ///
  /// Returns 'H:MM:SS' if the duration is at least one hour,
  /// otherwise returns 'MM:SS'.
  /// Returns '00:00' if [seconds] is null.
  static String formatDuration(double? seconds) {
    if (seconds == null) return '00:00';
    final duration = Duration(seconds: seconds.toInt());
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final secs = duration.inSeconds.remainder(60);
    if (hours > 0) {
      return '$hours:${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
    }
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }
}
