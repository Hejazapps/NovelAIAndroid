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

  int chapterCount = 4;

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
    final description =
    _descriptionController.text.trim();

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

    debugPrint('============= BOOK =============');
    debugPrint('Title: $title');
    debugPrint('Author: $author');
    debugPrint('Description: $description');
    debugPrint('Chapter: $chapterCount');
    debugPrint('Genre: $selectedGenre');
    debugPrint('Language: $selectedLanguage');
    debugPrint('Tone: $selectedTone');
    debugPrint('Length: $selectedLength');
    debugPrint('================================');

    // Book generation/API later.
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
