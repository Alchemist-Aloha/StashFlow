/// Formats [seconds] as `m:ss`-style clock time: `MM:SS`, or `H:MM:SS` from
/// one hour up.
String formatClockDuration(num seconds) {
  final duration = Duration(seconds: seconds.toInt());
  final hours = duration.inHours;
  final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
  final secs = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
  return hours > 0 ? '$hours:$minutes:$secs' : '$minutes:$secs';
}
