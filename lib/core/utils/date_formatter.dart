class DateFormatter {
  static String timeAgo(DateTime dateTime, {bool isApplied = false}) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inSeconds < 60) {
      return isApplied ? 'Applied just now' : 'Posted just now';
    } else if (difference.inMinutes < 60) {
      final mins = difference.inMinutes;
      return isApplied ? 'Applied ${mins}m ago' : 'Posted ${mins}m ago';
    } else if (difference.inHours < 24) {
      final hrs = difference.inHours;
      return isApplied ? 'Applied ${hrs}h ago' : 'Posted ${hrs}h ago';
    } else {
      final days = difference.inDays;
      if (days == 1) {
        return isApplied ? 'Applied yesterday' : 'Posted yesterday';
      }
      return isApplied ? 'Applied $days days ago' : 'Posted ${days}d ago';
    }
  }
}
