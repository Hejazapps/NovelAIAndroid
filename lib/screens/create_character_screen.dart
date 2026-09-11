import 'package:flutter/material.dart';

class CreateCharacterScreen extends StatefulWidget {
  const CreateCharacterScreen({super.key});

  @override
  State<CreateCharacterScreen> createState() => _CreateCharacterScreenState();
}

class _CreateCharacterScreenState extends State<CreateCharacterScreen> {
  final _nameController = TextEditingController();
  final _detailController = TextEditingController();
  final _goalController = TextEditingController();
  final _strengthController = TextEditingController();
  final _weaknessController = TextEditingController();

  String _language = 'English';
  String _personality = 'Romantic';
  String _roleInStory = 'Hero';
  String _storyGenre = 'Horror';
  int _credibilityIndex = 0;

  final ScrollController _genreScrollController = ScrollController();

  final List<String> _personalityOptions = const [
    'Romantic',
    'Funny',
    'Serious',
    'Cold',
    'Kind',
    'Smart',
    'Shy',
    'Confident',
    'Mysterious',
    'Carefree / Chill',
    'Teasing / Playful',
    'Childish / Naive',
    'Hyperactive / Energetic',
    'Stoic / Emotionless',
    'Apathetic / Indifferent',
    'Introverted / Hermit',
    'Strict / Disciplined',
    'Charismatic / Leader',
    'The Mentor / Wise',
    'The Chosen One',
    'Honorbound / Samurai',
    'Sarcastic / Witty',
    'Rebellious',
    'Arrogant',
    'Aggressive',
    'Flirtatious',
    'Loyal / Brave',
    'Melancholic / Gloomy',
    'Anxious / Overthinking',
    'Paranoid',
    'Bipolar / Unpredictable',
    'Cynical',
    'Nihilistic',
    'Gluttonous / Hedonistic',
    'Evil / Villainous',
    'Sadistic',
    'Obsessive / Yandere',
    'Manipulatory / Mastermind',
    'AI Suggest',
  ];

  final List<String> _roleOptions = const [
    'Hero',
    'Villain',
    'Anti-Hero',
    'Supporting Character',
    'Mentor',
    'Love Interest',
    'Rival',
    'Sidekick',
  ];

  final List<String> _genreOptions = const [
    'Horror',
    'Comedy',
    'Sad',
    'Romance',
    'Adventure',
    'Fantasy',
    'Mystery',
    'Thriller',
    'Drama',
    'Crime',
    'Science Fiction',
    'Mythology',
    'Superhero',
    'Fairy Tale',
    'Historical',
    'Historical Fiction',
    'Non-Fiction',
    'Detective',
    'Young Adult',
    'Dystopian',
    'Time Travel',
    'Dark Fantasy',
    'Cyberpunk',
    'Post-Apocalyptic',
    'Spy',
  ];

  final List<String> _languageOptions = const [
    'English',
    'Arabic',
    'Bengali',
    'Catalan',
    'Chinese (Simplified)',
    'Chinese (Traditional)',
    'Croatian',
    'Czech',
    'Danish',
    'Dutch',
    'Finnish',
    'French',
    'German',
    'Greek',
    'Hebrew',
    'Hindi',
    'Hungarian',
    'Indonesian',
    'Italian',
    'Japanese',
    'Korean',
    'Malay',
    'Polish',
    'Portuguese',
    'Romanian',
    'Russian',
    'Slovak',
    'Spanish',
    'Swedish',
    'Thai',
    'Turkish',
    'Ukrainian',
    'Vietnamese',
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _detailController.dispose();
    _goalController.dispose();
    _strengthController.dispose();
    _weaknessController.dispose();
    _genreScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDark ? const Color(0xFF160D26) : const Color(0xFFF8F7FA),
      appBar: AppBar(
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        backgroundColor:
            isDark ? const Color(0xFF160D26) : const Color(0xFFF8F7FA),
        foregroundColor: theme.colorScheme.onSurface,
        title: const Text(
          'Create Character',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: [
          TextButton(
            onPressed: _createCharacter,
            child: Text(
              'Create',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isDark
                    ? Colors.white
                    : theme.colorScheme.onSurface,
              ),
            ),
          ),
          const SizedBox(width: 6),
        ],
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: ListView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          padding: const EdgeInsets.fromLTRB(16, 18, 16, 36),
          children: [
            _sectionTitle(context, 'Character Name'),
            const SizedBox(height: 10),
            _textField(
              context,
              controller: _nameController,
              hint: 'Enter Character Name',
            ),
            const SizedBox(height: 24),

            _sectionTitle(context, 'Character Detailed'),
            const SizedBox(height: 10),
            _textArea(
              context,
              controller: _detailController,
              hint:
                  'Describe their background, appearance, or mood. (e.g., A sarcastic cyber-hacker in neon-lit Tokyo, seeking revenge...)',
            ),
            const SizedBox(height: 24),

            _sectionTitle(context, 'Choose Language'),
            const SizedBox(height: 10),
            _dropdown(
              context,
              value: _language,
              items: _languageOptions,
              onChanged: (value) {
                if (value == null) return;
                setState(() => _language = value);
              },
            ),
            const SizedBox(height: 24),

            _sectionTitle(context, 'Choose Personality'),
            const SizedBox(height: 10),
            _dropdown(
              context,
              value: _personality,
              items: _personalityOptions,
              onChanged: (value) {
                if (value == null) return;
                setState(() => _personality = value);
              },
            ),
            const SizedBox(height: 24),

            _sectionTitle(context, 'Role in Story'),
            const SizedBox(height: 10),
            _dropdown(
              context,
              value: _roleInStory,
              items: _roleOptions,
              onChanged: (value) {
                if (value == null) return;
                setState(() => _roleInStory = value);
              },
            ),
            const SizedBox(height: 24),

            _sectionTitle(context, 'Character Goal'),
            const SizedBox(height: 10),
            _textField(
              context,
              controller: _goalController,
              hint: 'What does this character want to achieve?',
            ),
            const SizedBox(height: 24),

            _sectionTitle(context, 'Strength (Optional)'),
            const SizedBox(height: 10),
            _textField(
              context,
              controller: _strengthController,
              hint: 'Example: Brave, intelligent, loyal...',
            ),
            const SizedBox(height: 24),

            _sectionTitle(context, 'Weakness / Flaw (Optional)'),
            const SizedBox(height: 10),
            _textField(
              context,
              controller: _weaknessController,
              hint: 'Example: Impulsive, jealous, fearful...',
            ),
            const SizedBox(height: 24),

            _storyGenreSelector(context),
            const SizedBox(height: 24),

            _sectionTitle(context, 'Choose Credibility'),
            const SizedBox(height: 10),
            _credibilitySelector(context),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(BuildContext context, String text) {
    return Text(
      text,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontSize: 17,
            fontWeight: FontWeight.w600,
          ),
    );
  }

  Widget _textField(
    BuildContext context, {
    required TextEditingController controller,
    required String hint,
  }) {
    return TextField(
      controller: controller,
      textInputAction: TextInputAction.done,
      decoration: _inputDecoration(context, hint),
    );
  }

  Widget _textArea(
    BuildContext context, {
    required TextEditingController controller,
    required String hint,
  }) {
    return TextField(
      controller: controller,
      minLines: 5,
      maxLines: 7,
      textInputAction: TextInputAction.newline,
      decoration: _inputDecoration(context, hint),
    );
  }

  Widget _dropdown(
    BuildContext context, {
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return InkWell(
      onTap: () {
        _showTraditionalSelector(
          context,
          items: items,
          selectedValue: value,
          onSelected: (selected) {
            onChanged(selected);
          },
        );
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        height: 56,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF21152F) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isDark
                ? const Color(0xFF49305F)
                : const Color(0xFFE0DCE8),
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 14,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ),
            Icon(
              Icons.keyboard_arrow_down_rounded,
              size: 24,
              color: isDark
                  ? const Color(0xFFB9AEC8)
                  : const Color(0xFF666666),
            ),
          ],
        ),
      ),
    );
  }

  void _showTraditionalSelector(
    BuildContext context, {
    required List<String> items,
    required String selectedValue,
    required ValueChanged<String> onSelected,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return _CharacterSelectorSheet(
          items: items,
          selectedValue: selectedValue,
          onSelected: (value) {
            Navigator.pop(sheetContext);
            onSelected(value);
          },
        );
      },
    );
  }

  InputDecoration _inputDecoration(
    BuildContext context,
    String hint,
  ) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return InputDecoration(
      hintText: hint.isEmpty ? null : hint,
      hintStyle: TextStyle(
        fontSize: 14,
        color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.72),
      ),
      filled: true,
      fillColor: isDark ? const Color(0xFF21152F) : Colors.white,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 16,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color:
              isDark ? const Color(0xFF49305F) : const Color(0xFFE0DCE8),
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: theme.colorScheme.primary,
          width: 1.4,
        ),
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }


  String _genreAsset(String genre) {
    switch (genre) {
      case 'Horror':
        return 'assets/genres/horror.png';
      case 'Comedy':
        return 'assets/genres/comedy.png';
      case 'Sad':
        return 'assets/genres/sad.png';
      case 'Romance':
        return 'assets/genres/romance.png';
      case 'Adventure':
        return 'assets/genres/adventure.png';
      case 'Fantasy':
        return 'assets/genres/fantasy.png';
      case 'Mystery':
        return 'assets/genres/mystery.png';
      case 'Thriller':
        return 'assets/genres/thriller.png';
      case 'Drama':
        return 'assets/genres/drama.png';
      case 'Crime':
        return 'assets/genres/crime.png';
      case 'Science Fiction':
        return 'assets/genres/science_fiction.png';
      case 'Mythology':
        return 'assets/genres/mythology.png';
      case 'Superhero':
        return 'assets/genres/superhero.png';
      case 'Fairy Tale':
        return 'assets/genres/fairy_tale.png';
      case 'Historical':
        return 'assets/genres/historical.png';
      case 'Historical Fiction':
        return 'assets/genres/historical_fiction.png';
      case 'Non-Fiction':
        return 'assets/genres/non_fiction.png';
      case 'Detective':
        return 'assets/genres/detective.png';
      case 'Young Adult':
        return 'assets/genres/young_adult.png';
      case 'Dystopian':
        return 'assets/genres/dystopian.png';
      case 'Time Travel':
        return 'assets/genres/time_travel.png';
      case 'Dark Fantasy':
        return 'assets/genres/dark_fantasy.png';
      case 'Cyberpunk':
        return 'assets/genres/cyberpunk.png';
      case 'Post-Apocalyptic':
        return 'assets/genres/post_apocalyptic.png';
      case 'Spy':
        return 'assets/genres/spy.png';
      default:
        return 'assets/genres/horror.png';
    }
  }

  void _selectStoryGenre(String genre, {bool autoScroll = true}) {
    setState(() {
      _storyGenre = genre;
    });

    if (!autoScroll) return;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_genreScrollController.hasClients) return;

      final index = _genreOptions.indexOf(genre);
      if (index < 0) return;

      const itemWidth = 76.0;
      const separator = 14.0;
      final rawOffset = index * (itemWidth + separator);
      final viewport = _genreScrollController.position.viewportDimension;
      final centeredOffset = rawOffset - ((viewport - itemWidth) / 2);

      final target = centeredOffset.clamp(
        _genreScrollController.position.minScrollExtent,
        _genreScrollController.position.maxScrollExtent,
      );

      _genreScrollController.animateTo(
        target.toDouble(),
        duration: const Duration(milliseconds: 320),
        curve: Curves.easeOutCubic,
      );
    });
  }

  Widget _storyGenreSelector(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accent =
        isDark ? const Color(0xFF9146E8) : const Color(0xFFFF6435);
    final textColor =
        isDark ? Colors.white : const Color(0xFF1B1B1B);
    final muted =
        isDark ? const Color(0xFFB9AEC8) : const Color(0xFF666666);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'Story Genre',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                  color: textColor,
                ),
              ),
            ),
            TextButton(
              onPressed: () => _showAllGenres(context),
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
                minimumSize: const Size(60, 34),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text(
                'View All',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: accent,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 112,
          child: ListView.separated(
            controller: _genreScrollController,
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: _genreOptions.length,
            separatorBuilder: (_, __) => const SizedBox(width: 14),
            itemBuilder: (context, index) {
              final genre = _genreOptions[index];
              final selected = genre == _storyGenre;

              return GestureDetector(
                onTap: () {
                  _selectStoryGenre(genre);
                },
                child: SizedBox(
                  width: 76,
                  child: Column(
                    children: [
                      Stack(
                        children: [
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 180),
                            width: 76,
                            height: 76,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(15),
                              border: Border.all(
                                color: selected
                                    ? accent
                                    : Colors.transparent,
                                width: selected ? 2 : 1,
                              ),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(13),
                              child: Image.asset(
                                _genreAsset(genre),
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) {
                                  return Container(
                                    color: isDark
                                        ? const Color(0xFF21152F)
                                        : const Color(0xFFF2F2F2),
                                    child: Icon(
                                      Icons.auto_stories_rounded,
                                      color: muted,
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                          if (selected)
                            Positioned(
                              top: 6,
                              right: 6,
                              child: Container(
                                width: 20,
                                height: 20,
                                decoration: BoxDecoration(
                                  color: accent,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.check_rounded,
                                  size: 14,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 7),
                      Text(
                        genre,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight:
                              selected ? FontWeight.w600 : FontWeight.w500,
                          color: selected ? accent : textColor,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  void _showAllGenres(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final background =
        isDark ? const Color(0xFF21152F) : Colors.white;
    final accent =
        isDark ? const Color(0xFF9146E8) : const Color(0xFFFF6435);
    final textColor =
        isDark ? Colors.white : const Color(0xFF1B1B1B);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.sizeOf(context).height * 0.62,
          ),
          decoration: BoxDecoration(
            color: background,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(24),
            ),
          ),
          padding: EdgeInsets.only(
            bottom: MediaQuery.paddingOf(sheetContext).bottom,
          ),
          child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 10),
                Container(
                  width: 42,
                  height: 5,
                  decoration: BoxDecoration(
                    color: isDark
                        ? const Color(0xFF6F5A80)
                        : const Color(0xFFDADADA),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(18, 14, 18, 10),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Story Genre',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: textColor,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(sheetContext),
                        icon: Icon(
                          Icons.close_rounded,
                          color: textColor,
                        ),
                      ),
                    ],
                  ),
                ),
                Flexible(
                  child: GridView.builder(
                    shrinkWrap: true,
                    padding: const EdgeInsets.fromLTRB(18, 0, 18, 18),
                    physics: const BouncingScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      mainAxisSpacing: 14,
                      crossAxisSpacing: 12,
                      childAspectRatio: 0.84,
                    ),
                    itemCount: _genreOptions.length,
                    itemBuilder: (context, index) {
                      final genre = _genreOptions[index];
                      final selected = genre == _storyGenre;

                      return GestureDetector(
                        onTap: () {
                          Navigator.pop(sheetContext);
                          _selectStoryGenre(genre);
                        },
                        child: Column(
                          children: [
                            Stack(
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(14),
                                    border: Border.all(
                                      color: selected
                                          ? accent
                                          : Colors.transparent,
                                      width: selected ? 2 : 1,
                                    ),
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: AspectRatio(
                                      aspectRatio: 1,
                                      child: Image.asset(
                                        _genreAsset(genre),
                                        fit: BoxFit.cover,
                                        errorBuilder: (_, __, ___) {
                                          return Container(
                                            color: isDark
                                                ? const Color(0xFF2A1A3B)
                                                : const Color(0xFFF2F2F2),
                                            child: const Icon(
                                              Icons.auto_stories_rounded,
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                  ),
                                ),
                                if (selected)
                                  Positioned(
                                    top: 5,
                                    right: 5,
                                    child: Container(
                                      width: 19,
                                      height: 19,
                                      decoration: BoxDecoration(
                                        color: accent,
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.check_rounded,
                                        size: 13,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text(
                              genre,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 10.5,
                                fontWeight: selected
                                    ? FontWeight.w600
                                    : FontWeight.w500,
                                color: selected ? accent : textColor,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
      },
    );
  }

  Widget _credibilitySelector(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    const titles = ['Low', 'Medium', 'High'];

    return Container(
      height: 50,
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF2A2138) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark
              ? const Color(0xFF3A2F4B)
              : const Color(0xFFEDEDED),
        ),
      ),
      child: Row(
        children: List.generate(
          titles.length,
          (index) => Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() => _credibilityIndex = index);
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                curve: Curves.easeOut,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: _credibilityIndex == index
                      ? (isDark
                          ? const Color(0xFF514368)
                          : const Color(0xFFF1F1F1))
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(9),
                ),
                child: Text(
                  titles[index],
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: _credibilityIndex == index
                        ? FontWeight.w700
                        : FontWeight.w500,
                    color: isDark
                        ? Colors.white
                        : const Color(0xFF171717),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  String get _credibilityValue {
    const values = ['Low', 'Medium', 'High'];
    return values[_credibilityIndex];
  }

  String _optionalPromptValue(String value) {
    final cleaned = value.trim();
    return cleaned.isEmpty ? 'Not specified' : cleaned;
  }

  void _createCharacter() {
    FocusScope.of(context).unfocus();

    final name = _nameController.text.trim();
    final detail = _detailController.text.trim();

    if (name.isEmpty) {
      _showWarning('Please enter character name.');
      return;
    }

    if (detail.isEmpty) {
      _showWarning('Please enter character description.');
      return;
    }

    final prompt = _buildCharacterPrompt();

    debugPrint('========== CHARACTER ==========');
    debugPrint('Character Name: $name');
    debugPrint('Character Detail: $detail');
    debugPrint('Language: $_language');
    debugPrint('Personality: $_personality');
    debugPrint('Credibility: $_credibilityValue');
    debugPrint('Role in Story: $_roleInStory');
    debugPrint('Character Goal: ${_goalController.text.trim()}');
    debugPrint('Strength: ${_strengthController.text.trim()}');
    debugPrint('Weakness: ${_weaknessController.text.trim()}');
    debugPrint('Story Genre: $_storyGenre');
    debugPrint('========== GENERATED PROMPT ==========');
    debugPrint(prompt);
    debugPrint('======================================');

    // API / generation screen connection can be added here later.
  }

  void _showWarning(String message) {
    showDialog(
      context: context,
      builder: (context) {
        final isDark =
            Theme.of(context).brightness == Brightness.dark;

        return AlertDialog(
          backgroundColor:
              isDark ? const Color(0xFF21152F) : Colors.white,
          title: Text(
            'Alert',
            style: TextStyle(
              color: isDark ? Colors.white : const Color(0xFF1B1B1B),
            ),
          ),
          content: Text(
            message,
            style: TextStyle(
              color: isDark
                  ? const Color(0xFFB9AEC8)
                  : const Color(0xFF555555),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'OK',
                style: TextStyle(
                  color: isDark
                      ? const Color(0xFF9146E8)
                      : const Color(0xFFFF9500),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  String _buildCharacterPrompt() {
    final characterName = _nameController.text.trim();
    final characterDetail = _detailController.text.trim();
    final characterGoal = _goalController.text.trim();
    final strength = _strengthController.text.trim();
    final weakness = _weaknessController.text.trim();

    return """
You are a professional character biographer. Your task is to generate a clean, highly natural, context-specific Character Sketch based strictly on the user's character settings below.

### STYLE, PROSE & VOCABULARY

- Keep the language simple and natural.
- Use common, everyday vocabulary.
- Keep sentences clear and easy to read.
- Avoid overly complex, academic, poetic, or flowery language.
- Avoid unnecessary metaphors.
- Do not invent cryptic or poetic headings.
- Make the character feel consistent with the selected personality, role, genre, goals, strengths, weaknesses, and credibility.

### OUTPUT STRUCTURE

First, generate 3-5 metadata bullet points.

Choose only useful fields from:

- Name
- Age
- Occupation / Role
- Location / Origin
- Affiliation / Faction
- Title / Rank

Name must always be included.

Then dynamically choose 4-6 useful sections from:

- Physical Appearance
- Background
- Origin
- History
- Personality
- Interests and Hobbies
- Relationships
- Goals and Aspirations
- Conflict and Growth
- Professional Demeanor
- Abilities and Skills
- Equipment and Gear
- Philosophy and Beliefs
- Strengths and Weaknesses
- Legacy and Impact

### FORMATTING

- Never write "Part 1" or "Part 2".
- Never add a heading above the metadata bullets.
- Start directly with the first metadata bullet.
- Every section heading must be followed by a colon.
- Start the section description on the next line.
- Do not repeat the same information unnecessarily.

Example:

Physical Appearance:
Description begins here.

### CHARACTER CONTROL RULES

Character Personality:
The selected personality must clearly influence the character's behavior, decisions, emotions, and interactions.

Role in Story:
Treat the selected role as the character's narrative function. A Hero, Villain, Anti-Hero, Mentor, Rival, Sidekick, Love Interest, or Supporting Character should behave appropriately for that role.

Character Goal:
If a goal is provided, make it an important motivation for the character. Connect their decisions and conflicts to this goal.

Strength:
If a strength is provided, integrate it naturally into the character instead of merely repeating the input.

Weakness / Flaw:
If a weakness or flaw is provided, show how it can create believable problems, conflicts, or opportunities for growth.

Story Genre:
The selected genre should influence the character's context, background, role, conflicts, abilities, and overall world.

Credibility:
- HIGH: Highly realistic, grounded, and believable.
- MEDIUM: Balanced and relatable with engaging fictional traits.
- LOW: More fun, exaggerated, imaginative, or trope-friendly.

Language:
The ENTIRE response, including headings, labels, bullet points, and descriptions, must be written strictly in the Target Language.

### INPUT VARIABLES

- Character Name: $characterName
- Character Description: $characterDetail
- Character Personality: $_personality
- Role in Story: $_roleInStory
- Character Goal: ${_optionalPromptValue(characterGoal)}
- Strength: ${_optionalPromptValue(strength)}
- Weakness / Flaw: ${_optionalPromptValue(weakness)}
- Story Genre: $_storyGenre
- Credibility: $_credibilityValue
- Target Language: $_language
""";
  }

}

class _CharacterSelectorSheet extends StatefulWidget {
  const _CharacterSelectorSheet({
    required this.items,
    required this.selectedValue,
    required this.onSelected,
  });

  final List<String> items;
  final String selectedValue;
  final ValueChanged<String> onSelected;

  @override
  State<_CharacterSelectorSheet> createState() =>
      _CharacterSelectorSheetState();
}

class _CharacterSelectorSheetState
    extends State<_CharacterSelectorSheet> {
  final TextEditingController _searchController =
      TextEditingController();
  String _search = '';

  bool get _showSearch => widget.items.length > 10;

  List<String> get _filteredItems {
    final query = _search.trim().toLowerCase();

    if (query.isEmpty) {
      return widget.items;
    }

    return widget.items
        .where((item) => item.toLowerCase().contains(query))
        .toList();
  }

  double _sheetHeight(BuildContext context) {
    final maxHeight = MediaQuery.sizeOf(context).height * 0.50;

    if (_showSearch) {
      return maxHeight;
    }

    const topArea = 42.0;
    const rowHeight = 56.0;

    return (topArea + widget.items.length * rowHeight)
        .clamp(180.0, maxHeight)
        .toDouble();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final items = _filteredItems;

    final background =
        isDark ? const Color(0xFF21152F) : Colors.white;
    final secondary =
        isDark ? const Color(0xFF2A1A3B) : const Color(0xFFF4F4F4);
    final border =
        isDark ? const Color(0xFF49305F) : const Color(0xFFE8E8E8);
    final accent =
        isDark ? const Color(0xFF9146E8) : const Color(0xFFFF9500);
    final muted =
        isDark ? const Color(0xFFB9AEC8) : const Color(0xFF777777);

    return SafeArea(
      top: false,
      child: Container(
        height: _sheetHeight(context),
        decoration: BoxDecoration(
          color: background,
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(24),
          ),
        ),
        child: Column(
          children: [
            const SizedBox(height: 10),
            Container(
              width: 42,
              height: 5,
              decoration: BoxDecoration(
                color: isDark
                    ? const Color(0xFF6F5A80)
                    : const Color(0xFFDADADA),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            if (_showSearch)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
                child: Container(
                  height: 46,
                  decoration: BoxDecoration(
                    color: secondary,
                    borderRadius: BorderRadius.circular(13),
                    border: Border.all(color: border),
                  ),
                  child: TextField(
                    controller: _searchController,
                    onChanged: (value) {
                      setState(() => _search = value);
                    },
                    style: TextStyle(
                      fontSize: 14,
                      color: theme.colorScheme.onSurface,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Search',
                      hintStyle: TextStyle(color: muted),
                      prefixIcon: Icon(
                        Icons.search_rounded,
                        color: muted,
                      ),
                      border: InputBorder.none,
                    ),
                  ),
                ),
              )
            else
              const SizedBox(height: 10),
            Expanded(
              child: ListView.separated(
                padding: EdgeInsets.zero,
                physics: const BouncingScrollPhysics(),
                itemCount: items.length,
                separatorBuilder: (_, __) => Divider(
                  height: 1,
                  indent: 18,
                  endIndent: 18,
                  color: border,
                ),
                itemBuilder: (context, index) {
                  final item = items[index];
                  final selected =
                      item == widget.selectedValue;

                  return SizedBox(
                    height: 56,
                    child: ListTile(
                      contentPadding:
                          const EdgeInsets.symmetric(horizontal: 20),
                      title: Text(
                        item,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: selected
                              ? FontWeight.w700
                              : FontWeight.w500,
                          color: selected
                              ? accent
                              : theme.colorScheme.onSurface,
                        ),
                      ),
                      trailing: selected
                          ? Icon(
                              Icons.check_circle_rounded,
                              color: accent,
                            )
                          : null,
                      onTap: () => widget.onSelected(item),
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

