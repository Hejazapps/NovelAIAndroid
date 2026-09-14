Compile fix for Screenplay feature

Replace these files in lib/screens/:
- screenplay_models.dart
- screenplay_detail_screen.dart

Fixes:
1. Added GeneratedScreenplayEpisode.wordCount
2. Added GeneratedScreenplayEpisode.estimatedReadMinutes
3. Added GeneratedScreenplay.totalWordCount
4. Added GeneratedScreenplay.estimatedReadMinutes
5. Replaced invalid Icons.menu_screenplay_rounded with Icons.movie_creation_outlined

The Kotlin Built-in Kotlin text is a warning, not the Dart compile failure shown in your log.
