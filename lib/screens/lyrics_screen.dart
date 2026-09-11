
import 'package:flutter/material.dart';

bool _lyricsDark(BuildContext context) =>
    Theme.of(context).brightness == Brightness.dark;

Color _lyricsPage(BuildContext context) =>
    _lyricsDark(context) ? const Color(0xFF160D26) : const Color(0xFFF7F7F8);

Color _lyricsSurface(BuildContext context) =>
    _lyricsDark(context) ? const Color(0xFF2A2138) : Colors.white;

Color _lyricsBorder(BuildContext context) =>
    _lyricsDark(context) ? const Color(0xFF493B5F) : const Color(0xFFE4E4E7);

Color _lyricsText(BuildContext context) =>
    _lyricsDark(context) ? Colors.white : const Color(0xFF171717);

Color _lyricsMuted(BuildContext context) =>
    _lyricsDark(context) ? const Color(0xFFB9AEC8) : const Color(0xFF777777);

Color _lyricsHint(BuildContext context) =>
    _lyricsDark(context) ? const Color(0xFF756A83) : const Color(0xFF999999);


class LyricsScreen extends StatefulWidget {
  const LyricsScreen({
    super.key,
    this.onPromptCreated,
  });

  final ValueChanged<String>? onPromptCreated;

  @override
  State<LyricsScreen> createState() => _LyricsScreenState();
}

class _LyricsScreenState extends State<LyricsScreen> {
  static const Color _background = Color(0xFF160D26);
  static const Color _field = Color(0xFF2A2138);

  static const List<String> genres = [
    'Rap',
    'Rock',
    'Pop',
    'Metal',
    'Country Music',
    'Worship',
    'Other',
  ];

  static const List<String> themes = [
    'Broken',
    'Nostalgia',
    'Happy',
    'Sad',
    'Self Discovery',
    'Betrayed',
    'Best Friend',
    'Party',
    'Success',
    'Miss you',
    'Love',
    'Fire',
    'Power',
    'Hurt',
    'Dream',
    'Heartbreak',
    'Nature',
  ];

  static const List<String> languages = [
    'English',
    'Bengali',
    'Arabic',
    'Catalan',
    'Czech',
    'Danish',
    'German',
    'Greek',
    'Spanish',
    'Finnish',
    'French',
    'Hebrew',
    'Hindi',
    'Hungarian',
    'Indonesian',
    'Italian',
    'Japanese',
    'Korean',
    'Malay',
    'Dutch',
    'Norwegian Bokmål',
    'Polish',
    'Portuguese',
    'Portuguese (Brazil)',
    'Romanian',
    'Russian',
    'Slovak',
    'Swedish',
    'Thai',
    'Turkish',
    'Ukrainian',
    'Vietnamese',
    'Chinese Simplified',
    'Chinese Traditional',
  ];

  static const List<String> rhymeTypes = [
    'Perfect Rhyme',
    'Near Rhyme',
    'Internal Rhyme',
    'Slant Rhyme',
    'Multisyllabic Rhyme',
  ];

  static const List<String> rhymeStructures = [
    'AABB',
    'ABAB',
    'ABBA',
    'AAAA',
    'Free Structure',
  ];

  static const List<String> rhymeDetails = [
    'Simple',
    'Emotional',
    'Romantic',
    'Poetic',
    'Playful',
    'Dark',
    'Powerful',
  ];

  static const List<String> chorusStructures = [
    'Simple Chorus',
    'Hook Focused',
    'Call & Response',
    'Repeating Refrain',
    'Melodic Chorus',
  ];

  static const List<String> chorusLengths = [
    'Short',
    'Medium',
    'Long',
  ];

  void _openCreateLyrics({String? genre, String? theme}) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => _CreateLyricsPage(
          initialGenre: genre,
          initialTheme: theme,
          genres: genres,
          languages: languages,
          onPromptCreated: _handlePrompt,
        ),
      ),
    );
  }

  void _openCreateChorus() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => _CreateChorusPage(
          structures: chorusStructures,
          lengths: chorusLengths,
          languages: languages,
          onPromptCreated: _handlePrompt,
        ),
      ),
    );
  }

  void _openCreateVerse({String? genre}) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => _CreateVersePage(
          initialGenre: genre,
          genres: genres,
          languages: languages,
          onPromptCreated: _handlePrompt,
        ),
      ),
    );
  }

  void _openRhyming() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => _CreateRhymingPage(
          rhymeTypes: rhymeTypes,
          rhymeStructures: rhymeStructures,
          rhymeDetails: rhymeDetails,
          languages: languages,
          onPromptCreated: _handlePrompt,
        ),
      ),
    );
  }

  void _handlePrompt(String prompt) {
    debugPrint('================ LYRICS PROMPT ================');
    debugPrint(prompt);
    debugPrint('================================================');
    widget.onPromptCreated?.call(prompt);
  }

  void _showAllGenres() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => _SeeAllLyricsPage(
          title: 'Lyrics',
          items: genres,
          imagePrefix: 'topic',
          onSelected: (value) {
            Navigator.pop(context);
            _openCreateLyrics(genre: value);
          },
        ),
      ),
    );
  }

  void _showAllThemes() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => _SeeAllLyricsPage(
          title: 'Lyrics',
          items: themes,
          imagePrefix: 'cat',
          onSelected: (value) {
            Navigator.pop(context);
            _openCreateLyrics(theme: value);
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _lyricsPage(context),
      body: SafeArea(
        child: Column(
          children: [
            _header(),
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 30),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _mainHero(),
                    const SizedBox(height: 14),
                    _actionGrid(),
                    const SizedBox(height: 24),
                    _section(
                      title: 'Genre',
                      items: genres,
                      prefix: 'topic',
                      onSeeAll: _showAllGenres,
                      onTap: (value) => _openCreateLyrics(genre: value),
                    ),
                    const SizedBox(height: 24),
                    _section(
                      title: 'Themes',
                      items: themes,
                      prefix: 'cat',
                      onSeeAll: _showAllThemes,
                      onTap: (value) => _openCreateLyrics(theme: value),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _header() {
    return SizedBox(
      height: 76,
      child: Row(
        children: [
          SizedBox(
            width: 48,
            child: IconButton(
              padding: EdgeInsets.zero,
              onPressed: () => Navigator.maybePop(context),
              icon: Icon(
                Icons.arrow_back_ios_new_rounded,
                color: _lyricsText(context),
                size: 23,
              ),
            ),
          ),
          Expanded(
            child: Text(
              'Lyrics',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: _lyricsText(context),
                fontSize: 22,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: 48),
        ],
      ),
    );
  }

  Widget _mainHero() {
    return GestureDetector(
      onTap: _openCreateLyrics,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: SizedBox(
          height: 205,
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.asset(
                'assets/Lyrics/topf.png',
                fit: BoxFit.cover,
                alignment: Alignment.topCenter,
                errorBuilder: (_, __, ___) =>
                    Container(color: const Color(0xFF0A5AA1)),
              ),
              DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      const Color(0xFF075A9E).withValues(alpha: .08),
                      const Color(0xFF075A9E).withValues(alpha: .88),
                    ],
                    stops: const [0.0, 0.48, 1.0],
                  ),
                ),
              ),
              Positioned(
                left: 18,
                right: 18,
                bottom: 18,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: .16),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.auto_awesome_rounded,
                        color: Colors.white,
                        size: 27,
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Create AI Lyrics',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Write professional-quality lyrics in seconds with AI assistance.',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 13.5,
                        height: 1.28,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _actionGrid() {
    return SizedBox(
      height: 272,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: GestureDetector(
              onTap: _openCreateChorus,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(18),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.asset(
                      'assets/Lyrics/Frame 1597882017.png',
                      fit: BoxFit.cover,
                      alignment: Alignment.bottomCenter,
                      errorBuilder: (_, __, ___) =>
                          Container(color: const Color(0xFF8612E8)),
                    ),
                    DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            const Color(0xFF8D16EF).withValues(alpha: .72),
                            Colors.transparent,
                            Colors.black.withValues(alpha: .16),
                          ],
                          stops: const [0.0, .48, 1.0],
                        ),
                      ),
                    ),
                    Positioned(
                      left: 14,
                      top: 16,
                      right: 12,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _CardBadge(
                            icon: Icons.music_note_rounded,
                            background: Colors.white.withValues(alpha: .14),
                          ),
                          const SizedBox(height: 10),
                          const Text(
                            'Create Chorus',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 5),
                          const Text(
                            'Write choruses that resonate with listeners and strengthen your song',
                            maxLines: 4,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12.2,
                              height: 1.27,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: _openCreateVerse,
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(18),
                        gradient: const LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Color(0xFF4A0714),
                            Color(0xFF170005),
                          ],
                        ),
                      ),
                      padding: const EdgeInsets.fromLTRB(13, 11, 11, 9),
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          return FittedBox(
                            fit: BoxFit.scaleDown,
                            alignment: Alignment.topLeft,
                            child: SizedBox(
                              width: constraints.maxWidth,
                              child: const Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _CardBadge(
                                    icon: Icons.queue_music_rounded,
                                    background: Color(0xFF63303B),
                                  ),
                                  SizedBox(height: 5),
                                  Text(
                                    'Create Verse',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    'Craft meaningful verses to tell the core story of your song.',
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 10.5,
                                      height: 1.18,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: GestureDetector(
                    onTap: _openRhyming,
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(18),
                        gradient: const LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Color(0xFF4A0714),
                            Color(0xFF170005),
                          ],
                        ),
                      ),
                      padding: const EdgeInsets.fromLTRB(13, 11, 11, 9),
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          return FittedBox(
                            fit: BoxFit.scaleDown,
                            alignment: Alignment.topLeft,
                            child: SizedBox(
                              width: constraints.maxWidth,
                              child: const Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _CardBadge(
                                    icon: Icons.record_voice_over_rounded,
                                    background: Color(0xFF5C351F),
                                  ),
                                  SizedBox(height: 5),
                                  Text(
                                    'Rhyming',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    'Find creative rhyming words and phrases for every line.',
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 10.5,
                                      height: 1.18,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _section({
    required String title,
    required List<String> items,
    required String prefix,
    required VoidCallback onSeeAll,
    required ValueChanged<String> onTap,
  }) {
    return Column(
      children: [
        Row(
          children: [
            Text(
              title,
              style: TextStyle(
                color: _lyricsText(context),
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const Spacer(),
            GestureDetector(
              onTap: onSeeAll,
              child: Text(
                'See All',
                style: TextStyle(
                  color: _lyricsText(context),
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 84,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: items.length,
            separatorBuilder: (_, __) => const SizedBox(width: 10),
            itemBuilder: (_, index) {
              return GestureDetector(
                onTap: () => onTap(items[index]),
                child: SizedBox(
                  width: 135,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        Image.asset(
                          'assets/Lyrics/$prefix$index.png',
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) =>
                              Container(color: _field),
                        ),
                        DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.transparent,
                                Colors.black.withValues(alpha: 0.45),
                              ],
                            ),
                          ),
                        ),
                        Positioned(
                          left: 12,
                          right: 8,
                          bottom: 8,
                          child: Text(
                            items[index],
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _CardBadge extends StatelessWidget {
  const _CardBadge({
    required this.icon,
    required this.background,
  });

  final IconData icon;
  final Color background;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 30,
      height: 30,
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(9),
      ),
      child: Icon(
        icon,
        color: Colors.white,
        size: 18,
      ),
    );
  }
}

class _CreateLyricsPage extends StatefulWidget {
  const _CreateLyricsPage({
    required this.genres,
    required this.languages,
    required this.onPromptCreated,
    this.initialGenre,
    this.initialTheme,
  });

  final List<String> genres;
  final List<String> languages;
  final String? initialGenre;
  final String? initialTheme;
  final ValueChanged<String> onPromptCreated;

  @override
  State<_CreateLyricsPage> createState() => _CreateLyricsPageState();
}

class _CreateLyricsPageState extends State<_CreateLyricsPage> {
  final _keyPoints = TextEditingController();
  final _description = TextEditingController();
  String? _genre;
  String? _language;

  @override
  void initState() {
    super.initState();
    _genre = widget.initialGenre;
    if (widget.initialTheme != null) {
      _keyPoints.text = widget.initialTheme!;
    }
  }

  @override
  void dispose() {
    _keyPoints.dispose();
    _description.dispose();
    super.dispose();
  }

  void _create() {
    final keyPoints = _keyPoints.text.trim();
    final description = _description.text.trim();

    if (keyPoints.isEmpty &&
        description.isEmpty &&
        (_genre == null || _genre!.isEmpty)) {
      _showMessage(context, 'Please add some song details.');
      return;
    }

    if (_language == null) {
      _showMessage(context, 'Please select a language.');
      return;
    }

    final prompt = '''
You are a professional songwriter and lyricist.

Write one complete, original song based on the user's direction.

SONG DETAILS
Key Points: ${keyPoints.isEmpty ? 'Use the description as the main creative direction.' : keyPoints}
Description: ${description.isEmpty ? 'No additional description provided.' : description}
Music Genre: ${_genre ?? 'Choose the most suitable genre for the idea.'}
Language: $_language

WRITING REQUIREMENTS
- Write lyrics that feel natural, emotionally believable, memorable, and written by a skilled human songwriter.
- Match the vocabulary, rhythm, attitude, imagery, and emotional intensity to the selected music genre.
- Build a clear emotional or narrative progression instead of producing disconnected lines.
- Use specific imagery and meaningful details. Avoid generic AI-sounding phrases, filler, and unnecessary repetition.
- Create a strong hook that can be remembered after one listen.
- Keep verses purposeful and make each section move the song forward.
- Use rhyme only when it sounds natural. Do not force rhyme at the expense of meaning.
- Keep the lyrics singable and rhythmically coherent.
- Respect the user's key points without mechanically repeating them.
- The entire song must be written in $_language.

STRUCTURE
Use a professional song structure appropriate to the selected genre. Include clearly labeled sections such as Verse, Pre-Chorus, Chorus, Bridge, or Outro only when they genuinely fit the song.

OUTPUT RULES
Return only the finished lyrics. Do not explain your process, do not add notes, and do not include any commentary before or after the lyrics.
''';

    widget.onPromptCreated(prompt);
  }

  @override
  Widget build(BuildContext context) {
    return _LyricsFormScaffold(
      title: 'Create AI Lyrics',
      onCreate: _create,
      children: [
        _FormLabel('Key Points'),
        _LyricsTextBox(
          controller: _keyPoints,
          hint: 'e.g., love, heartbreak, summer vibe, rain...',
          minLines: 3,
          maxLines: 4,
        ),
        _FormLabel('Description'),
        _LyricsTextBox(
          controller: _description,
          hint: 'Provide a brief description of the songs',
          minLines: 3,
          maxLines: 4,
        ),
        _FormLabel('Music Genre'),
        _LyricsDropdown(
          value: _genre,
          hint: 'Choose genre',
          options: widget.genres,
          onChanged: (v) => setState(() => _genre = v),
        ),
        _FormLabel('Select Language'),
        _LyricsDropdown(
          value: _language,
          hint: 'Choose Language',
          options: widget.languages,
          searchable: true,
          onChanged: (v) => setState(() => _language = v),
        ),
      ],
    );
  }
}

class _CreateChorusPage extends StatefulWidget {
  const _CreateChorusPage({
    required this.structures,
    required this.lengths,
    required this.languages,
    required this.onPromptCreated,
  });

  final List<String> structures;
  final List<String> lengths;
  final List<String> languages;
  final ValueChanged<String> onPromptCreated;

  @override
  State<_CreateChorusPage> createState() => _CreateChorusPageState();
}

class _CreateChorusPageState extends State<_CreateChorusPage> {
  final _description = TextEditingController();
  String? _structure;
  String? _length;
  String? _language;

  @override
  void dispose() {
    _description.dispose();
    super.dispose();
  }

  void _create() {
    final description = _description.text.trim();
    if (description.isEmpty) {
      _showMessage(context, 'Please enter a description.');
      return;
    }
    if (_language == null) {
      _showMessage(context, 'Please select a language.');
      return;
    }

    final prompt = '''
You are an expert songwriter specializing in memorable choruses and hooks.

Create one original chorus from the user's description.

DESCRIPTION
$description

CHORUS STYLE
Structure: ${_structure ?? 'Choose the most natural chorus structure.'}
Length: ${_length ?? 'Medium'}
Language: $_language

REQUIREMENTS
- Write a chorus that feels immediately memorable, emotionally clear, and easy to sing.
- Establish one strong central hook or phrase.
- Keep the chorus focused on one emotional idea rather than introducing too many concepts.
- Use repetition intentionally, not mechanically.
- Match the structure and requested length.
- Use natural rhyme and musical phrasing; never force a rhyme.
- Avoid generic filler and obvious AI-style expressions.
- Make every line contribute to the hook, emotion, or momentum.
- Write entirely in $_language.

OUTPUT RULES
Return only the chorus lyrics. Do not add explanations, headings, notes, analysis, or commentary.
''';

    widget.onPromptCreated(prompt);
  }

  @override
  Widget build(BuildContext context) {
    return _LyricsFormScaffold(
      title: 'Create Chorus',
      onCreate: _create,
      children: [
        _FormLabel('Enter Description'),
        _LyricsTextBox(
          controller: _description,
          hint: 'Enter Description',
          minLines: 2,
          maxLines: 3,
        ),
        _FormLabel('Rhyme Style'),
        _LyricsDropdown(
          value: _structure,
          hint: 'Choose Structure',
          options: widget.structures,
          onChanged: (v) => setState(() => _structure = v),
        ),
        _FormLabel('Chorus Length'),
        _LyricsDropdown(
          value: _length,
          hint: 'Choose Length',
          options: widget.lengths,
          onChanged: (v) => setState(() => _length = v),
        ),
        _FormLabel('Select Language'),
        _LyricsDropdown(
          value: _language,
          hint: 'Choose Language',
          options: widget.languages,
          searchable: true,
          onChanged: (v) => setState(() => _language = v),
        ),
      ],
    );
  }
}

class _CreateVersePage extends StatefulWidget {
  const _CreateVersePage({
    required this.genres,
    required this.languages,
    required this.onPromptCreated,
    this.initialGenre,
  });

  final List<String> genres;
  final List<String> languages;
  final String? initialGenre;
  final ValueChanged<String> onPromptCreated;

  @override
  State<_CreateVersePage> createState() => _CreateVersePageState();
}

class _CreateVersePageState extends State<_CreateVersePage> {
  final _keyPoints = TextEditingController();
  String? _genre;
  String? _language;

  @override
  void initState() {
    super.initState();
    _genre = widget.initialGenre;
  }

  @override
  void dispose() {
    _keyPoints.dispose();
    super.dispose();
  }

  void _create() {
    final keyPoints = _keyPoints.text.trim();
    if (keyPoints.isEmpty) {
      _showMessage(context, 'Please enter your verse idea.');
      return;
    }
    if (_language == null) {
      _showMessage(context, 'Please select a language.');
      return;
    }

    final prompt = '''
You are a professional songwriter.

Write one original song verse based on the user's idea.

VERSE IDEA
$keyPoints

Music Genre: ${_genre ?? 'Use the genre that best supports the idea.'}
Language: $_language

REQUIREMENTS
- Create a vivid, natural verse with a clear point of view.
- Make it feel like part of a real song rather than a standalone poem.
- Match the rhythm, vocabulary, tone, and energy to the music genre.
- Use concrete imagery and specific details.
- Develop the story or emotion line by line.
- Avoid clichés, filler, awkward phrasing, and generic AI language.
- Use rhyme only when natural.
- Keep the lines singable and musically balanced.
- Write entirely in $_language.

OUTPUT RULES
Return only the finished verse. No explanation, notes, headings, analysis, or commentary.
''';

    widget.onPromptCreated(prompt);
  }

  @override
  Widget build(BuildContext context) {
    return _LyricsFormScaffold(
      title: 'Create Verse',
      onCreate: _create,
      children: [
        _FormLabel('Key Points'),
        _LyricsTextBox(
          controller: _keyPoints,
          hint: 'Enter your verse (eg. Feeling lost but alive)',
          minLines: 3,
          maxLines: 4,
        ),
        _FormLabel('Music Genre'),
        _LyricsDropdown(
          value: _genre,
          hint: 'Choose genre',
          options: widget.genres,
          onChanged: (v) => setState(() => _genre = v),
        ),
        _FormLabel('Select Language'),
        _LyricsDropdown(
          value: _language,
          hint: 'Choose Language',
          options: widget.languages,
          searchable: true,
          onChanged: (v) => setState(() => _language = v),
        ),
      ],
    );
  }
}

class _CreateRhymingPage extends StatefulWidget {
  const _CreateRhymingPage({
    required this.rhymeTypes,
    required this.rhymeStructures,
    required this.rhymeDetails,
    required this.languages,
    required this.onPromptCreated,
  });

  final List<String> rhymeTypes;
  final List<String> rhymeStructures;
  final List<String> rhymeDetails;
  final List<String> languages;
  final ValueChanged<String> onPromptCreated;

  @override
  State<_CreateRhymingPage> createState() => _CreateRhymingPageState();
}

class _CreateRhymingPageState extends State<_CreateRhymingPage> {
  final _keyPoints = TextEditingController();
  String? _type;
  String? _structure;
  String? _details;
  String? _language;

  @override
  void dispose() {
    _keyPoints.dispose();
    super.dispose();
  }

  void _create() {
    final keyPoints = _keyPoints.text.trim();
    if (keyPoints.isEmpty) {
      _showMessage(context, 'Please enter a word or line.');
      return;
    }
    if (_language == null) {
      _showMessage(context, 'Please select a language.');
      return;
    }

    final prompt = '''
You are an expert lyricist and rhyme specialist.

Generate creative, usable rhyming lines for the user's word, phrase, or lyric.

SOURCE
$keyPoints

Rhyme Type: ${_type ?? 'Choose the most natural rhyme type.'}
Rhyme Structure: ${_structure ?? 'Use a flexible structure.'}
Rhyme Details / Mood: ${_details ?? 'Natural and lyrical'}
Language: $_language

REQUIREMENTS
- Preserve the meaning and emotional direction of the source whenever possible.
- Produce rhymes that sound natural when sung aloud.
- Prioritize meaning, rhythm, and musicality over technically perfect but awkward rhyme.
- Match the requested rhyme type and structure.
- Avoid repeating the same ending word unless repetition is artistically useful.
- Include fresh wording and varied imagery.
- Avoid childish, forced, or nonsensical rhyme unless the requested mood calls for it.
- Write entirely in $_language.

OUTPUT RULES
Return only the rhyming lyric options, one option per line. Do not explain the rhyme scheme or add commentary.
''';

    widget.onPromptCreated(prompt);
  }

  @override
  Widget build(BuildContext context) {
    return _LyricsFormScaffold(
      title: 'Create Rhyming',
      onCreate: _create,
      children: [
        _FormLabel('Key Points'),
        _LyricsTextBox(
          controller: _keyPoints,
          hint:
              'Enter a word or line to find matching rhymes (e.g., love, dream or Hold on tight, the night is ours)',
          minLines: 3,
          maxLines: 4,
        ),
        _FormLabel('Rhyme Type'),
        _LyricsDropdown(
          value: _type,
          hint: 'Choose Rhyme',
          options: widget.rhymeTypes,
          onChanged: (v) => setState(() => _type = v),
        ),
        _FormLabel('Rhyme Structure'),
        _LyricsDropdown(
          value: _structure,
          hint: 'Choose Structure',
          options: widget.rhymeStructures,
          onChanged: (v) => setState(() => _structure = v),
        ),
        _FormLabel('Rhyme Details'),
        _LyricsDropdown(
          value: _details,
          hint: 'Choose Personality',
          options: widget.rhymeDetails,
          onChanged: (v) => setState(() => _details = v),
        ),
        _FormLabel('Select Language'),
        _LyricsDropdown(
          value: _language,
          hint: 'Choose Language',
          options: widget.languages,
          searchable: true,
          onChanged: (v) => setState(() => _language = v),
        ),
      ],
    );
  }
}

class _LyricsFormScaffold extends StatelessWidget {
  const _LyricsFormScaffold({
    required this.title,
    required this.onCreate,
    required this.children,
  });

  final String title;
  final VoidCallback onCreate;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _lyricsPage(context),
      body: SafeArea(
        child: Column(
          children: [
            SizedBox(
              height: 66,
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(
                      Icons.arrow_back_ios_new_rounded,
                      color: _lyricsText(context),
                      size: 20,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      title,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: _lyricsText(context),
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: onCreate,
                    child: Text(
                      'Create',
                      style: TextStyle(
                        color: _lyricsText(context),
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 28),
                children: children,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FormLabel extends StatelessWidget {
  const _FormLabel(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 7),
      child: Text(
        text,
        style: TextStyle(
          color: _lyricsText(context),
          fontSize: 15,
          fontWeight: FontWeight.w400,
        ),
      ),
    );
  }
}

class _LyricsTextBox extends StatelessWidget {
  const _LyricsTextBox({
    required this.controller,
    required this.hint,
    required this.minLines,
    required this.maxLines,
  });

  final TextEditingController controller;
  final String hint;
  final int minLines;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      minLines: minLines,
      maxLines: maxLines,
      style: TextStyle(color: _lyricsText(context), fontSize: 14),
      cursorColor: const Color(0xFF9146E8),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(
          color: _lyricsHint(context),
          fontSize: 13,
        ),
        filled: true,
        fillColor: _lyricsSurface(context),
        contentPadding: const EdgeInsets.all(14),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(7),
          borderSide: BorderSide(color: _lyricsBorder(context)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(7),
          borderSide: const BorderSide(color: Color(0xFF6E5A88)),
        ),
      ),
    );
  }
}

class _LyricsDropdown extends StatelessWidget {
  const _LyricsDropdown({
    required this.value,
    required this.hint,
    required this.options,
    required this.onChanged,
    this.searchable = false,
  });

  final String? value;
  final String hint;
  final List<String> options;
  final ValueChanged<String> onChanged;
  final bool searchable;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        final selected = await showModalBottomSheet<String>(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (_) => _LyricsSelectorSheet(
            title: hint,
            options: options,
            selected: value,
            searchable: searchable,
          ),
        );
        if (selected != null) onChanged(selected);
      },
      child: Container(
        height: 49,
        padding: const EdgeInsets.symmetric(horizontal: 13),
        decoration: BoxDecoration(
          color: _lyricsSurface(context),
          borderRadius: BorderRadius.circular(7),
          border: Border.all(color: _lyricsBorder(context)),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                value ?? hint,
                style: TextStyle(
                  color: value == null
                      ? _lyricsHint(context)
                      : _lyricsText(context),
                  fontSize: 13,
                ),
              ),
            ),
            Icon(
              Icons.keyboard_arrow_down_rounded,
              color: _lyricsText(context),
              size: 22,
            ),
          ],
        ),
      ),
    );
  }
}

class _LyricsSelectorSheet extends StatefulWidget {
  const _LyricsSelectorSheet({
    required this.title,
    required this.options,
    required this.selected,
    required this.searchable,
  });

  final String title;
  final List<String> options;
  final String? selected;
  final bool searchable;

  @override
  State<_LyricsSelectorSheet> createState() => _LyricsSelectorSheetState();
}

class _LyricsSelectorSheetState extends State<_LyricsSelectorSheet> {
  final _search = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filtered = widget.options
        .where((e) => e.toLowerCase().contains(_query.toLowerCase()))
        .toList();

    return SafeArea(
      top: false,
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * .50,
        ),
        decoration: BoxDecoration(
          color: _lyricsDark(context) ? const Color(0xFF21152F) : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
        ),
        padding: const EdgeInsets.fromLTRB(18, 10, 18, 18),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 42,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFF5A4D68),
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            const SizedBox(height: 14),
            Text(
              widget.title,
              style: TextStyle(
                color: _lyricsText(context),
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            if (widget.searchable || widget.options.length > 10) ...[
              const SizedBox(height: 12),
              TextField(
                controller: _search,
                onChanged: (v) => setState(() => _query = v),
                style: TextStyle(color: _lyricsText(context)),
                decoration: InputDecoration(
                  hintText: 'Search',
                  hintStyle: TextStyle(color: _lyricsHint(context)),
                  prefixIcon: const Icon(
                    Icons.search,
                    color: Color(0xFF8D819A),
                  ),
                  filled: true,
                  fillColor: _lyricsDark(context)
                      ? const Color(0xFF2A2138)
                      : const Color(0xFFF2F2F4),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ],
            const SizedBox(height: 5),
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: filtered.length,
                itemBuilder: (_, index) {
                  final item = filtered[index];
                  final selected = item == widget.selected;
                  return ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 4),
                    title: Text(
                      item,
                      style: TextStyle(color: _lyricsText(context)),
                    ),
                    trailing: selected
                        ? const Icon(
                            Icons.check_rounded,
                            color: Color(0xFF9146E8),
                          )
                        : null,
                    onTap: () => Navigator.pop(context, item),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SeeAllLyricsPage extends StatelessWidget {
  const _SeeAllLyricsPage({
    required this.title,
    required this.items,
    required this.imagePrefix,
    required this.onSelected,
  });

  final String title;
  final List<String> items;
  final String imagePrefix;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _lyricsPage(context),
      body: SafeArea(
        child: Column(
          children: [
            SizedBox(
              height: 72,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: _lyricsText(context),
                      fontSize: 22,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Positioned(
                    left: 10,
                    child: IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: Icon(
                        Icons.arrow_back_ios_new_rounded,
                        color: _lyricsText(context),
                        size: 21,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 30),
                itemCount: items.length,
                gridDelegate:
                    const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  mainAxisSpacing: 14,
                  crossAxisSpacing: 14,
                  childAspectRatio: 1.45,
                ),
                itemBuilder: (_, index) {
                  return GestureDetector(
                    onTap: () => onSelected(items[index]),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: Image.asset(
                        'assets/Lyrics/$imagePrefix$index.png',
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) =>
                            Container(color: const Color(0xFF2A2138)),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

void _showMessage(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
      backgroundColor:
          _lyricsDark(context) ? const Color(0xFF2A2138) : const Color(0xFF303030),
    ),
  );
}
