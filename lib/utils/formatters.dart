String formatRuntime(int? minutes) {
  if (minutes == null || minutes <= 0) return '—';
  final hours = minutes ~/ 60;
  final mins = minutes % 60;
  if (hours == 0) return '${mins}m';
  return '${hours}h ${mins}m';
}

String formatDate(String date) {
  if (date.isEmpty) return 'Release date unavailable';
  final parts = date.split('-');
  if (parts.length >= 2) {
    return '${parts[1]}/${parts[0]}';
  }
  return date;
}
