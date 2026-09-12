import 'package:flutter/material.dart';

class BookScreen extends StatefulWidget {
  const BookScreen({super.key});

  @override
  State<BookScreen> createState() => _BookScreenState();
}

class _BookScreenState extends State<BookScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _authorController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  String selectedGenre = 'Fairy Tale';
  String selectedLanguage = 'English';
  String selectedTone = 'Standard';
  String selectedLength = 'Short';
  String selectedAgeGroup = 'Adults (18+)';

  int chapterCount = 4;

  final List<BookCharacterSpec> _characters = [];

  final ScrollController _genreScrollController = ScrollController();

  final List<BookGenre> genres = const [
    BookGenre(name: 'Horror', image: 'assets/genres/horror.png'),
    BookGenre(name: 'Comedy', image: 'assets/genres/comedy.png'),
    BookGenre(name: 'Sad', image: 'assets/genres/sad.png'),
    BookGenre(name: 'Romance', image: 'assets/genres/romance.png'),
    BookGenre(name: 'Adventure', image: 'assets/genres/adventure.png'),
    BookGenre(name: 'Fantasy', image: 'assets/genres/fantasy.png'),
    BookGenre(name: 'Mystery', image: 'assets/genres/mystery.png'),
    BookGenre(name: 'Thriller', image: 'assets/genres/thriller.png'),
    BookGenre(name: 'Drama', image: 'assets/genres/drama.png'),
    BookGenre(name: 'Crime', image: 'assets/genres/crime.png'),
    BookGenre(name: 'Science Fiction', image: 'assets/genres/science_fiction.png'),
    BookGenre(name: 'Mythology', image: 'assets/genres/mythology.png'),
    BookGenre(name: 'Superhero', image: 'assets/genres/superhero.png'),
    BookGenre(name: 'Fairy Tale', image: 'assets/genres/fairy_tale.png'),
    BookGenre(name: 'Historical', image: 'assets/genres/historical.png'),
    BookGenre(name: 'Historical Fiction', image: 'assets/genres/historical_fiction.png'),
    BookGenre(name: 'Non-Fiction', image: 'assets/genres/non_fiction.png'),
    BookGenre(name: 'Detective', image: 'assets/genres/detective.png'),
    BookGenre(name: 'Young Adult', image: 'assets/genres/young_adult.png'),
    BookGenre(name: 'Dystopian', image: 'assets/genres/dystopian.png'),
    BookGenre(name: 'Time Travel', image: 'assets/genres/time_travel.png'),
    BookGenre(name: 'Dark Fantasy', image: 'assets/genres/dark_fantasy.png'),
    BookGenre(name: 'Cyberpunk', image: 'assets/genres/cyberpunk.png'),
    BookGenre(name: 'Post-Apocalyptic', image: 'assets/genres/post_apocalyptic.png'),
    BookGenre(name: 'Spy', image: 'assets/genres/spy.png'),
  ];

  final List<String> languages = const [
    'English',
    'Bengali',
    'Arabic',
    'Catalan',
    'Chinese Simplified',
    'Chinese Traditional',
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
    'Norwegian Bokmål',
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

  final List<String> tones = const [
    'Standard',
    'Creative',
    'Professional',
    'Casual',
    'Funny',
    'Serious',
    'Dark',
    'Emotional',
    'Romantic',
    'Inspirational',
    'Mysterious',
    'Dramatic',
    'Suspenseful',
    'Humorous',
    'Poetic',
  ];

  final List<String> ageGroups = const [
    'Adults (18+)',
    'Teen (13–17)',
    'Pre-teen (8–12)',
    'Children (1–7)',
  ];



  bool _isDark(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark;

  Color _pageBackground(BuildContext context) =>
      _isDark(context) ? const Color(0xFF160D26) : const Color(0xFFF9F9F9);

  Color _surface(BuildContext context) =>
      _isDark(context) ? const Color(0xFF21152F) : Colors.white;

  Color _surfaceAlt(BuildContext context) =>
      _isDark(context) ? const Color(0xFF2A1A3B) : const Color(0xFFF1F1F1);

  Color _border(BuildContext context) =>
      _isDark(context) ? const Color(0xFF49305F) : const Color(0xFFE8E8E8);

  Color _text(BuildContext context) =>
      _isDark(context) ? Colors.white : const Color(0xFF1B1B1B);

  Color _bodyText(BuildContext context) =>
      _isDark(context) ? const Color(0xFFE9E2F3) : const Color(0xFF222222);

  Color _muted(BuildContext context) =>
      _isDark(context) ? const Color(0xFFB9AEC8) : const Color(0xFF777777);

  Color _hint(BuildContext context) =>
      _isDark(context) ? const Color(0xFF81758F) : const Color(0xFFA0A0A0);

  Color _accent(BuildContext context) =>
      _isDark(context) ? const Color(0xFF9146E8) : const Color(0xFFFF6435);

  Color _accentSoft(BuildContext context) =>
      _isDark(context) ? const Color(0xFF2D1A43) : const Color(0xFFFFF0EA);

  @override
  void dispose() {
    _titleController.dispose();
    _authorController.dispose();
    _descriptionController.dispose();
    _genreScrollController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _pageBackground(context),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: ListView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(
                  20,
                  4,
                  20,
                  120,
                ),
                children: [
                  _buildTextField(
                    title: 'Title',
                    hint: 'Enter book title',
                    controller: _titleController,
                  ),

                  const SizedBox(height: 17),

                  _buildTextField(
                    title: 'Author',
                    hint: 'Enter author name',
                    controller: _authorController,
                  ),

                  const SizedBox(height: 17),

                  _buildDescription(),

                  const SizedBox(height: 24),

                  _buildChapterSection(),

                  const SizedBox(height: 25),

                  _buildGenreSection(),

                  const SizedBox(height: 25),

                  _buildDropdownTile(
                    title: 'Choose Language',
                    value: selectedLanguage,
                    icon: Icons.language_rounded,
                    onTap: () {
                      _showSelector(
                        title: 'Choose Language',
                        values: languages,
                        selectedValue: selectedLanguage,
                        searchable: true,
                        onSelected: (value) {
                          setState(() {
                            selectedLanguage = value;
                          });
                        },
                      );
                    },
                  ),

                  _buildDropdownTile(
                    title: 'Choose Tone',
                    value: selectedTone,
                    icon: Icons.graphic_eq_rounded,
                    onTap: () {
                      _showSelector(
                        title: 'Choose Tone',
                        values: tones,
                        selectedValue: selectedTone,
                        searchable: true,
                        onSelected: (value) {
                          setState(() {
                            selectedTone = value;
                          });
                        },
                      );
                    },
                  ),

                  const SizedBox(height: 12),

                  _buildLengthSection(),

                  const SizedBox(height: 25),

                  _buildAgeGroupSection(),

                  const SizedBox(height: 25),

                  _buildCharactersSection(),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  // ============================================================
  // HEADER
  // ============================================================

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 10, 20, 12),
      child: Row(
        children: [
          InkWell(
            onTap: () {
              Navigator.pop(context);
            },
            borderRadius: BorderRadius.circular(30),
            child: SizedBox(
              width: 42,
              height: 42,
              child: Icon(
                Icons.arrow_back_ios_new_rounded,
                size: 21,
                color: _text(context),
              ),
            ),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: Text(
              'Create Book',
              style: TextStyle(
                fontSize: 23,
                fontWeight: FontWeight.w700,
                color: _text(context),
              ),
            ),
          ),
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: _surface(context),
              borderRadius: BorderRadius.circular(13),
              border: Border.all(color: _border(context)),
              boxShadow: _isDark(context)
                  ? null
                  : [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.06),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ],
            ),
            child: Icon(
              Icons.workspace_premium_outlined,
              size: 21,
              color: _accent(context),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // TEXT FIELD
  // ============================================================

  Widget _buildTextField({
    required String title,
    required String hint,
    required TextEditingController controller,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: _text(context),
          ),
        ),

        const SizedBox(height: 9),

        Container(
          height: 52,
          decoration: BoxDecoration(
            color: _surface(context),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: _border(context),
            ),
          ),
          child: TextField(
            controller: controller,
            style: TextStyle(
              fontSize: 14,
              color: _bodyText(context),
            ),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(
                fontSize: 14,
                color: _hint(context),
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 15,
                vertical: 16,
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ============================================================
  // DESCRIPTION
  // ============================================================

  Widget _buildDescription() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Description',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: _text(context),
          ),
        ),

        const SizedBox(height: 9),

        Container(
          height: 150,
          decoration: BoxDecoration(
            color: _surface(context),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: _border(context),
            ),
          ),
          child: TextField(
            controller: _descriptionController,
            expands: true,
            maxLines: null,
            textAlignVertical: TextAlignVertical.top,
            style: TextStyle(
              fontSize: 14,
              height: 1.45,
              color: _bodyText(context),
            ),
            decoration: InputDecoration(
              hintText: 'Describe your book idea...',
              hintStyle: TextStyle(
                fontSize: 14,
                color: _hint(context),
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.all(15),
            ),
          ),
        ),
      ],
    );
  }

  // ============================================================
  // CHAPTERS
  // ============================================================

  Widget _buildChapterSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'Chapter',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: _text(context),
                ),
              ),
            ),

            Container(
              constraints: const BoxConstraints(
                minWidth: 38,
              ),
              height: 32,
              padding: const EdgeInsets.symmetric(
                horizontal: 10,
              ),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: _accentSoft(context),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '$chapterCount',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: _accent(context),
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 8),

        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            trackHeight: 4,
            activeTrackColor: _accent(context),
            inactiveTrackColor: _isDark(context)
                ? const Color(0xFF2A1A3B)
                : const Color(0xFFE5E5E5),
            thumbColor: _accent(context),
            overlayColor: _accent(context).withValues(
              alpha: 0.12,
            ),
          ),
          child: Slider(
            value: chapterCount.toDouble(),
            min: 1,
            max: 25,
            divisions: 24,
            onChanged: (value) {
              final newValue = value.round();

              // Swift version gates free users above 4.
              // Subscription check will be connected later.
              setState(() {
                chapterCount = newValue;
              });
            },
          ),
        ),

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 2),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '1',
                style: TextStyle(
                  fontSize: 11,
                  color: _muted(context),
                ),
              ),
              Text(
                '25',
                style: TextStyle(
                  fontSize: 11,
                  color: _muted(context),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ============================================================
  // GENRE
  // ============================================================

  Widget _buildGenreSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'Select Genre',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: _text(context),
                ),
              ),
            ),

            InkWell(
              onTap: _showAllGenres,
              child: Padding(
                padding: const EdgeInsets.all(6),
                child: Text(
                  'View All',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: _accent(context),
                  ),
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 13),

        SizedBox(
          height: 130,
          child: ListView.separated(
            controller: _genreScrollController,
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: genres.length,
            separatorBuilder: (_, __) {
              return const SizedBox(width: 10);
            },
            itemBuilder: (context, index) {
              return _buildGenreItem(
                genres[index],
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildGenreItem(BookGenre genre) {
    final selected = selectedGenre == genre.name;

    return GestureDetector(
      onTap: () => _selectGenre(genre.name),
      child: SizedBox(
        width: 92,
        child: Column(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              width: 88,
              height: 88,
              padding: EdgeInsets.all(
                selected ? 3 : 0,
              ),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                border: selected
                    ? Border.all(
                  color: _accent(context),
                  width: 2,
                )
                    : null,
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(
                  selected ? 14 : 17,
                ),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.asset(
                      genre.image,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        color: _surfaceAlt(context),
                        alignment: Alignment.center,
                        child: Icon(
                          Icons.auto_stories_outlined,
                          color: _muted(context),
                        ),
                      ),
                    ),

                    if (selected)
                      Positioned(
                        top: 6,
                        right: 6,
                        child: CircleAvatar(
                          radius: 10,
                          backgroundColor: _accent(context),
                          child: const Icon(
                            Icons.check_rounded,
                            color: Colors.white,
                            size: 13,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 7),

            Text(
              genre.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 11,
                fontWeight: selected
                    ? FontWeight.w700
                    : FontWeight.w500,
                color: selected
                    ? _accent(context)
                    : _text(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _selectGenre(String genreName) {
    final index = genres.indexWhere((genre) => genre.name == genreName);
    if (index == -1) return;

    setState(() {
      selectedGenre = genreName;
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_genreScrollController.hasClients || !mounted) return;

      const itemWidth = 92.0;
      const spacing = 10.0;
      final screenWidth = MediaQuery.sizeOf(context).width;

      double targetOffset =
          (index * (itemWidth + spacing)) -
          ((screenWidth - itemWidth) / 2);

      targetOffset = targetOffset.clamp(
        0.0,
        _genreScrollController.position.maxScrollExtent,
      );

      _genreScrollController.animateTo(
        targetOffset,
        duration: const Duration(milliseconds: 420),
        curve: Curves.easeInOutCubic,
      );
    });
  }

  void _showAllGenres() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: _surface(context),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(25),
        ),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: SizedBox(
            height: MediaQuery.sizeOf(context).height * 0.50,
            child: Column(
              children: [
                const SizedBox(height: 10),
                Container(
                  width: 42,
                  height: 5,
                  decoration: BoxDecoration(
                    color: _border(context),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 15),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Select Genre',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: _text(context),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: GridView.builder(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      mainAxisSpacing: 18,
                      crossAxisSpacing: 15,
                      childAspectRatio: 0.82,
                    ),
                    itemCount: genres.length,
                    itemBuilder: (context, index) {
                      final genre = genres[index];
                      final selected = selectedGenre == genre.name;

                      return GestureDetector(
                        onTap: () {
                          Navigator.pop(sheetContext);
                          Future.delayed(
                            const Duration(milliseconds: 120),
                            () {
                              if (mounted) {
                                _selectGenre(genre.name);
                              }
                            },
                          );
                        },
                        child: Column(
                          children: [
                            Expanded(
                              child: Container(
                                padding: EdgeInsets.all(
                                  selected ? 3 : 0,
                                ),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(18),
                                  border: selected
                                      ? Border.all(
                                          color: _accent(context),
                                          width: 2,
                                        )
                                      : null,
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(14),
                                  child: Stack(
                                    fit: StackFit.expand,
                                    children: [
                                      Image.asset(
                                        genre.image,
                                        fit: BoxFit.cover,
                                        errorBuilder: (_, __, ___) =>
                                            Container(
                                          color: _surfaceAlt(context),
                                          alignment: Alignment.center,
                                          child: Icon(
                                            Icons.auto_stories_outlined,
                                            color: _muted(context),
                                          ),
                                        ),
                                      ),
                                      if (selected)
                                        Positioned(
                                          top: 6,
                                          right: 6,
                                          child: CircleAvatar(
                                            radius: 10,
                                            backgroundColor:
                                                _accent(context),
                                            child: const Icon(
                                              Icons.check_rounded,
                                              size: 13,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 7),
                            Text(
                              genre.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: selected
                                    ? FontWeight.w700
                                    : FontWeight.w500,
                                color: selected
                                    ? _accent(context)
                                    : _text(context),
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
          ),
        );
      },
    );
  }

  // ============================================================
  // LANGUAGE / TONE
  // ============================================================

  Widget _buildDropdownTile({
    required String title,
    required String value,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 11),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(15),
        child: Container(
          constraints: const BoxConstraints(
            minHeight: 62,
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 10,
          ),
          decoration: BoxDecoration(
            color: _surface(context),
            borderRadius: BorderRadius.circular(15),
            border: Border.all(
              color: _border(context),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: _accentSoft(context),
                  borderRadius: BorderRadius.circular(11),
                ),
                child: Icon(
                  icon,
                  size: 19,
                  color: _accent(context),
                ),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 12,
                        color: _muted(context),
                      ),
                    ),

                    const SizedBox(height: 3),

                    Text(
                      value,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: _bodyText(context),
                      ),
                    ),
                  ],
                ),
              ),

              Icon(
                Icons.keyboard_arrow_down_rounded,
                color: _muted(context),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // LENGTH
  // ============================================================

  Widget _buildLengthSection() {
    const values = [
      'Short',
      'Medium',
      'Long',
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Book Length',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: _text(context),
          ),
        ),
        const SizedBox(height: 12),
        Container(
          height: 48,
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: _isDark(context)
                ? const Color(0xFF2A2138)
                : Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: _isDark(context)
                  ? const Color(0xFF3A2F4B)
                  : const Color(0xFFEDEDED),
            ),
          ),
          child: Row(
            children: values.map((value) {
              final selected = selectedLength == value;

              return Expanded(
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedLength = value;
                    });
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: selected
                          ? (_isDark(context)
                              ? const Color(0xFF514368)
                              : const Color(0xFFF1F1F1))
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(11),
                    ),
                    child: Text(
                      value,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: selected
                            ? FontWeight.w700
                            : FontWeight.w500,
                        color: _isDark(context)
                            ? Colors.white
                            : const Color(0xFF171717),
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }


  // ============================================================
  // TARGET AUDIENCE / AGE GROUP
  // ============================================================

  Widget _buildAgeGroupSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Target Audience',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: _text(context),
          ),
        ),
        const SizedBox(height: 10),
        _buildDropdownTile(
          title: 'Age Group',
          value: selectedAgeGroup,
          icon: Icons.groups_2_outlined,
          onTap: () {
            _showSelector(
              title: 'Choose Age Group',
              values: ageGroups,
              selectedValue: selectedAgeGroup,
              onSelected: (value) {
                setState(() {
                  selectedAgeGroup = value;
                });
              },
            );
          },
        ),
      ],
    );
  }

  // ============================================================
  // CHARACTERS
  // ============================================================

  Widget _buildCharactersSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'Main Characters',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: _text(context),
                ),
              ),
            ),
            if (_characters.isNotEmpty)
              Text(
                '${_characters.length}',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: _accent(context),
                ),
              ),
          ],
        ),
        const SizedBox(height: 10),
        if (_characters.isNotEmpty)
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _characters.asMap().entries.map((entry) {
              final index = entry.key;
              final character = entry.value;

              return Container(
                padding: const EdgeInsets.fromLTRB(12, 8, 7, 8),
                decoration: BoxDecoration(
                  color: _accentSoft(context),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: _accentSoft(context)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.person_outline_rounded,
                      size: 17,
                      color: _accent(context),
                    ),
                    const SizedBox(width: 6),
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 150),
                      child: Text(
                        character.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: _text(context),
                        ),
                      ),
                    ),
                    const SizedBox(width: 4),
                    InkWell(
                      onTap: () {
                        setState(() {
                          _characters.removeAt(index);
                        });
                      },
                      borderRadius: BorderRadius.circular(20),
                      child: Padding(
                        padding: const EdgeInsets.all(3),
                        child: Icon(
                          Icons.close_rounded,
                          size: 16,
                          color: _muted(context),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        if (_characters.isNotEmpty) const SizedBox(height: 10),
        InkWell(
          onTap: _showAddCharacterSheet,
          borderRadius: BorderRadius.circular(15),
          child: Container(
            height: 56,
            decoration: BoxDecoration(
              color: _surface(context),
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: _border(context)),
            ),
            child: Row(
              children: [
                const SizedBox(width: 15),
                CircleAvatar(
                  radius: 16,
                  backgroundColor: _accentSoft(context),
                  child: Icon(
                    Icons.add_rounded,
                    size: 20,
                    color: _accent(context),
                  ),
                ),
                const SizedBox(width: 11),
                Text(
                  'Add New Character',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: _text(context),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _showAddCharacterSheet() async {
    FocusScope.of(context).unfocus();

    final character = await showModalBottomSheet<BookCharacterSpec>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: _surface(context),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) => _BookCharacterInputSheet(
        surfaceAlt: _surfaceAlt(context),
        borderColor: _border(context),
        textColor: _bodyText(context),
        mutedColor: _muted(context),
        hintColor: _hint(context),
        accentColor: _accent(context),
        accentSoftColor: _accentSoft(context),
      ),
    );

    if (!mounted || character == null) return;

    setState(() {
      _characters.add(character);
    });
  }

  // ============================================================
  // CREATE
  // ============================================================

  Widget _buildBottomBar() {
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(
          20,
          10,
          20,
          12,
        ),
        decoration: BoxDecoration(
          color: _pageBackground(context),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, -3),
            ),
          ],
        ),
        child: GestureDetector(
          onTap: _createBook,
          child: Container(
            height: 54,
            decoration: BoxDecoration(
              color: _accent(context),
              borderRadius: BorderRadius.circular(16),
            ),
            alignment: Alignment.center,
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.auto_awesome_rounded,
                  color: Colors.white,
                  size: 18,
                ),
                SizedBox(width: 8),
                Text(
                  'Create',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _createBook() {
    final title = _titleController.text.trim();
    final author = _authorController.text.trim();
    final description = _descriptionController.text.trim();

    if (title.isEmpty) {
      _showAlert(
        'Missing Title',
        'Please enter a book title.',
      );
      return;
    }

    if (description.isEmpty) {
      _showAlert(
        'Missing Description',
        'Please enter your book description.',
      );
      return;
    }

    final characters = List<BookCharacterSpec>.unmodifiable(_characters);

    final spec = BookGenerationSpec(
      title: title,
      bookDescription: description,
      author: author,
      language: selectedLanguage,
      tone: selectedTone,
      category: selectedGenre,
      length: selectedLength,
      chapterCount: chapterCount,
      ageGroup: selectedAgeGroup,
      characters: characters,
    );

    final outlinePrompt = _buildOutlinePrompt(spec);

    debugPrint('============= BOOK SPEC =============');
    debugPrint('Title: ${spec.title}');
    debugPrint('Author: ${spec.author}');
    debugPrint('Description: ${spec.bookDescription}');
    debugPrint('Chapter: ${spec.chapterCount}');
    debugPrint('Genre: ${spec.category}');
    debugPrint('Language: ${spec.language}');
    debugPrint('Tone: ${spec.tone}');
    debugPrint('Length: ${spec.length}');
    debugPrint('Age Group: ${spec.ageGroup}');
    debugPrint('Character Count: ${spec.characters.length}');

    for (var i = 0; i < spec.characters.length; i++) {
      final character = spec.characters[i];
      debugPrint('Character ${i + 1} Name: ${character.name}');
      debugPrint(
        'Character ${i + 1} Description: ${character.description}',
      );
    }

    debugPrint('Chapter Target: ${_chapterTargetText(spec.length)}');
    debugPrint('============= OUTLINE PROMPT =============');
    debugPrint(outlinePrompt);
    debugPrint('===========================================');

    // Intentionally stops at prompt creation.
    // Connect this prompt to your generation/API layer later.
  }

  String _charactersBlock(BookGenerationSpec spec) {
    if (spec.characters.isEmpty) {
      return 'None specified.';
    }

    return spec.characters
        .map((character) {
          final name =
              character.name.isEmpty ? 'Unnamed character' : character.name;
          final description = character.description.isEmpty
              ? 'No description provided.'
              : character.description;
          return '- $name: $description';
        })
        .join('\n');
  }

  String _chapterTargetText(String length) {
    final normalized = length.toLowerCase();

    if (normalized.contains('short')) {
      return '300-400 words';
    }

    if (normalized.contains('long')) {
      return '800-1000 words';
    }

    return '500-700 words';
  }

  String _buildOutlinePrompt(BookGenerationSpec spec) {
    final total = spec.chapterCount > 0 ? spec.chapterCount : 12;
    final language =
        spec.language.trim().isEmpty ? 'English' : spec.language;
    final tone = spec.tone.trim().isEmpty
        ? 'engaging and consistent'
        : spec.tone;
    final author =
        spec.author.trim().isEmpty ? 'Not specified' : spec.author;

    return """
You are an elite story architect, developmental editor, and professional novelist.

Your job is to design a coherent, emotionally satisfying, causally connected book before prose is written.

Think in terms of:
- character desire
- obstacles
- choices
- consequences
- escalation
- reversals
- relationships
- setup and payoff
- emotional progression
- thematic pressure
- pacing
- chapter variety

A strong story is not a sequence of unrelated incidents.
Each chapter should be caused partly by what came before and should change what becomes possible afterward.
Characters must influence the plot through decisions.

Avoid repetitive chapter formulas.
Avoid solving the central problem too early.
Avoid arbitrary twists with no setup.
Avoid convenient coincidences that erase consequences.

Design a professional $total-chapter ${spec.category} book.

BOOK TITLE:
${spec.title}

PREMISE / USER DESCRIPTION:
${spec.bookDescription}

AUTHOR / VOICE REFERENCE:
$author

LANGUAGE:
$language

TONE:
$tone

TARGET AUDIENCE:
${spec.ageGroup}

TARGET CHAPTER LENGTH:
${_chapterTargetText(spec.length)}

CHARACTERS:
${_charactersBlock(spec)}

CORE GOAL

Design ONE connected book with a clear dramatic spine.
The story should feel deliberately constructed rather than generated chapter by chapter.

Build:
beginning → escalation → complications → major turn → increasing cost → climax → earned aftermath / resolution.

THROUGHLINE

Define one central dramatic question or conflict.
Every chapter must meaningfully interact with this throughline.

A chapter may focus on relationships, discovery, reflection, travel, politics, mystery, action, or another mode, but it must still alter the larger story.

CAUSALITY

Design the chapters so that important events happen because of earlier:
- choices
- discoveries
- mistakes
- promises
- conflicts
- sacrifices
- consequences

Avoid a sequence where chapters could be reordered without damaging the story.

CHARACTER ARCS

Character development should happen progressively.
Major emotional changes need causes.

Relationships should evolve through interaction, disagreement, trust, betrayal, sacrifice, discovery, boundaries, or shared experience.

Do not make characters suddenly behave differently simply because the plot needs them to.

COST / STAKES

Define a real price demanded by the central conflict.

The cost may be:
- emotional
- relational
- moral
- physical
- social
- financial
- professional
- existential

The cost must matter.
It cannot disappear through an easy conversation or convenient reconciliation.

CLIMAX

Set "climaxChapter" to the chapter where the central dramatic pressure reaches its peak.
Usually this should fall in the final third.

Before the climax:
- keep the central problem alive
- allow partial victories
- allow losses
- raise complications
- reveal information
- deepen consequences

Do NOT fully pay or erase the central cost before the climax.
At or after the climax, the story must genuinely confront the established cost.

CHAPTER DESIGN

Each chapter needs its own internal dramatic shape:
goal → pressure/conflict → development → meaningful turn → consequence → chapter landing.

The "beat" field must describe this progression concretely.

Do NOT write vague beats like:
"The characters learn more."
"The story continues."
"Tension increases."
"The protagonist faces challenges."

State what actually happens.

CHAPTER IDENTITY

Every chapter should have a distinct identity.

Vary:
- scene mode
- dominant relationship
- dramatic question
- setting
- pacing
- emotional temperature
- information revealed
- type of conflict

Do not repeatedly use the same pattern such as:
meeting → explanation → argument → departure.

Do not use the same character pairing in every chapter.
Do not make every chapter an action scene.
Do not make every chapter end with a cliffhanger.

PACING

Important events deserve space.

Use quieter chapters when they create:
- emotional consequence
- character decisions
- relationship movement
- new understanding
- anticipation

But quiet chapters must still change something.

SETTINGS AND TIME

Give each chapter a concrete setting.
Give each chapter a meaningful timeframe.

Use time jumps only when the story benefits from them.
A tight thriller may remain nearly continuous.
A family saga may jump months or years.

Do not force identical pacing onto every genre.

SETUP AND PAYOFF

Plant information, tensions, objects, promises, relationships, fears, or questions early enough for later payoffs to feel earned.

Major revelations should connect to prior information where possible.
Foreshadow without making every setup obvious.

ENDING

The final chapter must resolve the central dramatic question according to the genre and intended ending.

Resolution does not mean everything becomes perfect.
Preserve consequences.

If the story is tragic, bittersweet, ambiguous, romantic, hopeful, dark, mysterious, or comedic, make the resolution appropriate to that mode.

TITLES

Each chapter title must be:
- specific
- evocative
- 2-6 words
- connected to that chapter

Never use:
"Chapter 1"
"Chapter One"
"Untitled"
a bare number

AUTHOR VOICE

If an author or voice reference is provided, use it only as broad stylistic guidance such as pacing, atmosphere, emotional intimacy, humor, or descriptive density.

Do not reproduce recognizable passages or distinctive wording from another work.

OUTPUT

Return ONLY this valid JSON object:

{
  "title": "<book title>",
  "premise": "<2-3 sentence refined premise>",
  "throughline": "<single central dramatic question/conflict>",
  "arc": "<3-5 sentences describing the progression from opening through escalation, climax, cost, and resolution>",
  "cost": "<the meaningful price or sacrifice demanded by the central conflict>",
  "climaxChapter": <integer from 1 to $total>,
  "chapters": [
    {
      "title": "<specific evocative 2-6 word title>",
      "mode": "<action / discovery / relationship / confrontation / revelation / reflection / pursuit / investigation / negotiation / travel / survival / other suitable mode>",
      "setting": "<specific place or environment>",
      "timeframe": "<when it happens and any meaningful time shift>",
      "focusCharacters": ["<character names>"],
      "beat": "<concrete chapter mini-arc: immediate goal → conflict/pressure → important development → turn/decision/revelation → consequence/landing>",
      "advances": "<exactly what changes in the overall plot, character arc, relationship, stakes, knowledge, or possibility because of this chapter>"
    }
  ]
}

The chapters array must contain EXACTLY $total objects.

Return JSON only.
""";
  }

  void _showAlert(
      String title,
      String message,
      ) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: _surface(context),
          title: Text(
            title,
            style: TextStyle(color: _text(context)),
          ),
          content: Text(
            message,
            style: TextStyle(color: _muted(context)),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text(
                'OK',
                style: TextStyle(
                  color: _accent(context),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // ============================================================
  // SELECTOR
  // ============================================================

  void _showSelector({
    required String title,
    required List<String> values,
    required String selectedValue,
    required ValueChanged<String> onSelected,
    bool searchable = false,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return _BookSelectorSheet(
          title: title,
          values: values,
          selectedValue: selectedValue,
          searchable: searchable,
          onSelected: (value) {
            Navigator.pop(context);
            onSelected(value);
          },
        );
      },
    );
  }
}

// ============================================================
// SELECTOR SHEET
// ============================================================

class _BookSelectorSheet extends StatefulWidget {
  final String title;
  final List<String> values;
  final String selectedValue;
  final bool searchable;
  final ValueChanged<String> onSelected;

  const _BookSelectorSheet({
    required this.title,
    required this.values,
    required this.selectedValue,
    required this.searchable,
    required this.onSelected,
  });

  @override
  State<_BookSelectorSheet> createState() =>
      _BookSelectorSheetState();
}

class _BookSelectorSheetState
    extends State<_BookSelectorSheet> {
  final TextEditingController _searchController =
  TextEditingController();

  String search = '';

  List<String> get filtered {
    if (search.trim().isEmpty) {
      return widget.values;
    }

    return widget.values.where((item) {
      return item.toLowerCase().contains(
        search.trim().toLowerCase(),
      );
    }).toList();
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
    final maxHeight = MediaQuery.sizeOf(context).height * 0.50;
    final showSearch = widget.searchable && widget.values.length > 10;
    final items = filtered;

    final background =
        isDark ? const Color(0xFF21152F) : Colors.white;
    final secondary =
        isDark ? const Color(0xFF2A1A3B) : const Color(0xFFF4F4F4);
    final border =
        isDark ? const Color(0xFF49305F) : const Color(0xFFE8E8E8);
    final accent =
        isDark ? const Color(0xFF9146E8) : const Color(0xFFFF6435);
    final muted =
        isDark ? const Color(0xFFB9AEC8) : const Color(0xFF777777);
    final textColor =
        isDark ? Colors.white : const Color(0xFF222222);

    final naturalHeight = showSearch
        ? maxHeight
        : (88.0 + widget.values.length * 56.0)
            .clamp(190.0, maxHeight)
            .toDouble();

    return SafeArea(
      top: false,
      child: Container(
        height: naturalHeight,
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
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 14, 10),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      widget.title,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: textColor,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(
                      Icons.close_rounded,
                      size: 21,
                      color: textColor,
                    ),
                  ),
                ],
              ),
            ),
            if (showSearch)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
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
                      setState(() {
                        search = value;
                      });
                    },
                    style: TextStyle(
                      fontSize: 14,
                      color: textColor,
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
              ),
            Expanded(
              child: items.isEmpty
                  ? Center(
                      child: Text(
                        'No results found',
                        style: TextStyle(color: muted),
                      ),
                    )
                  : ListView.separated(
                      physics: const BouncingScrollPhysics(),
                      itemCount: items.length,
                      separatorBuilder: (_, __) => Divider(
                        height: 1,
                        indent: 20,
                        endIndent: 20,
                        color: border,
                      ),
                      itemBuilder: (context, index) {
                        final value = items[index];
                        final selected =
                            value == widget.selectedValue;

                        return SizedBox(
                          height: 56,
                          child: ListTile(
                            contentPadding:
                                const EdgeInsets.symmetric(horizontal: 20),
                            title: Text(
                              value,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: selected
                                    ? FontWeight.w700
                                    : FontWeight.w500,
                                color: selected ? accent : textColor,
                              ),
                            ),
                            trailing: selected
                                ? Icon(
                                    Icons.check_circle_rounded,
                                    color: accent,
                                  )
                                : null,
                            onTap: () {
                              widget.onSelected(value);
                            },
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

// ============================================================
// MODEL
// ============================================================

class BookGenre {
  final String name;
  final String image;

  const BookGenre({
    required this.name,
    required this.image,
  });
}

class BookCharacterSpec {
  final String name;
  final String description;

  const BookCharacterSpec({
    required this.name,
    required this.description,
  });
}

class BookGenerationSpec {
  final String title;
  final String bookDescription;
  final String author;
  final String language;
  final String tone;
  final String category;
  final String length;
  final int chapterCount;
  final String ageGroup;
  final List<BookCharacterSpec> characters;

  const BookGenerationSpec({
    required this.title,
    required this.bookDescription,
    required this.author,
    required this.language,
    required this.tone,
    required this.category,
    required this.length,
    required this.chapterCount,
    required this.ageGroup,
    required this.characters,
  });
}

class _BookCharacterInputSheet extends StatefulWidget {
  const _BookCharacterInputSheet({
    required this.surfaceAlt,
    required this.borderColor,
    required this.textColor,
    required this.mutedColor,
    required this.hintColor,
    required this.accentColor,
    required this.accentSoftColor,
  });

  final Color surfaceAlt;
  final Color borderColor;
  final Color textColor;
  final Color mutedColor;
  final Color hintColor;
  final Color accentColor;
  final Color accentSoftColor;

  @override
  State<_BookCharacterInputSheet> createState() =>
      _BookCharacterInputSheetState();
}

class _BookCharacterInputSheetState extends State<_BookCharacterInputSheet> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  bool get _canAdd => _nameController.text.trim().isNotEmpty;

  @override
  void initState() {
    super.initState();
    _nameController.addListener(_refresh);
  }

  void _refresh() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _nameController.removeListener(_refresh);
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_canAdd) return;

    final character = BookCharacterSpec(
      name: _nameController.text.trim(),
      description: _descriptionController.text.trim(),
    );

    FocusScope.of(context).unfocus();
    Navigator.of(context).pop(character);
  }

  @override
  Widget build(BuildContext context) {
    final keyboard = MediaQuery.viewInsetsOf(context).bottom;

    return AnimatedPadding(
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOut,
      padding: EdgeInsets.only(bottom: keyboard),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 18),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 5,
              decoration: BoxDecoration(
                color: widget.borderColor,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            const SizedBox(height: 18),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Add Main Character',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: widget.textColor,
                ),
              ),
            ),
            const SizedBox(height: 18),
            TextField(
              controller: _nameController,
              autofocus: true,
              textInputAction: TextInputAction.next,
              style: TextStyle(color: widget.textColor),
              decoration: InputDecoration(
                labelText: 'Character Name',
                hintText: 'Enter character name',
                labelStyle: TextStyle(color: widget.mutedColor),
                hintStyle: TextStyle(color: widget.hintColor),
                filled: true,
                fillColor: widget.surfaceAlt,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(color: widget.borderColor),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(color: widget.borderColor),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(
                    color: widget.accentColor,
                    width: 1.4,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _descriptionController,
              minLines: 3,
              maxLines: 5,
              textInputAction: TextInputAction.done,
              onSubmitted: (_) => _submit(),
              style: TextStyle(color: widget.textColor),
              decoration: InputDecoration(
                labelText: 'Character Description',
                hintText:
                    'Describe personality, role, goal, appearance, or important details',
                alignLabelWithHint: true,
                labelStyle: TextStyle(color: widget.mutedColor),
                hintStyle: TextStyle(color: widget.hintColor),
                filled: true,
                fillColor: widget.surfaceAlt,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(color: widget.borderColor),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(color: widget.borderColor),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(
                    color: widget.accentColor,
                    width: 1.4,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _canAdd ? _submit : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: widget.accentColor,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: widget.accentSoftColor,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                child: const Text(
                  'Add Character',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

