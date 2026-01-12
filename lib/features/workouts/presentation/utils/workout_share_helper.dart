import 'package:share_plus/share_plus.dart';
import '../../domain/models/workout_library_entry.dart';

class WorkoutShareHelper {
  const WorkoutShareHelper._();

  static String buildShareUrl(WorkoutLibraryEntry entry) {
    final slug = _slugify(entry.name);
    return 'https://kinesa.app/workout/$slug';
  }

  static String buildShareMessage(
    WorkoutLibraryEntry entry, {
    String? note,
  }) {
    final buffer = StringBuffer();
    buffer.writeln('Check out this workout on Kinesa: ${entry.name}');
    if (note != null && note.trim().isNotEmpty) {
      buffer.writeln();
      buffer.writeln(note.trim());
    }
    buffer.writeln();
    buffer.writeln(buildShareUrl(entry));
    return buffer.toString();
  }

  static Future<void> shareWorkout(
    WorkoutLibraryEntry entry, {
    String? note,
  }) async {
    await Share.share(
      buildShareMessage(entry, note: note),
      subject: entry.name,
    );
  }

  static String _slugify(String input) {
    final slug = input
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9]+'), '-')
        .replaceAll(RegExp(r'^-+|-+$'), '');
    return slug.isEmpty ? 'workout' : slug;
  }
}
