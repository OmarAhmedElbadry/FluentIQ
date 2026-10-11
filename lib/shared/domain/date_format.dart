/// Short, locale-agnostic date format shared by every history display
/// (home's latest-result summary, the results list, the detail screen).
String formatShortDate(DateTime date) => '${date.month}/${date.day}/${date.year}';
