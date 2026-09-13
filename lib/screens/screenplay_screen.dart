import 'package:flutter/material.dart';

class ScreenplayScreen extends StatefulWidget {
  const ScreenplayScreen({super.key});

  @override
  State<ScreenplayScreen> createState() => _ScreenplayScreenState();
}

class _ScreenplayScreenState extends State<ScreenplayScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _authorController = TextEditingController();
  final TextEditingController _ideaController = TextEditingController();
  final TextEditingController _synopsisController = TextEditingController();
  final TextEditingController _settingController = TextEditingController();

  final List<ScreenplayCharacterSpec> _characters = [];
  final ScrollController _genreScrollController = ScrollController();

  String selectedGenre = 'Adventure';
  String selectedTone = 'Dramatic';
  String selectedScriptFormat = 'Standard Screenplay';
  String selectedLanguage = 'English';
  String selectedIncludedElements = 'Everything';
  String selectedContentRating = 'PG-13 – Ages 13+';
  String selectedSceneLength = 'Medium';
  int sceneCount = 4;

  final List<ScreenplayGenre> genres = const [
    ScreenplayGenre(name: 'Horror', image: 'assets/genres/horror.png'),
    ScreenplayGenre(name: 'Comedy', image: 'assets/genres/comedy.png'),
    ScreenplayGenre(name: 'Sad', image: 'assets/genres/sad.png'),
    ScreenplayGenre(name: 'Romance', image: 'assets/genres/romance.png'),
    ScreenplayGenre(name: 'Adventure', image: 'assets/genres/adventure.png'),
    ScreenplayGenre(name: 'Fantasy', image: 'assets/genres/fantasy.png'),
    ScreenplayGenre(name: 'Mystery', image: 'assets/genres/mystery.png'),
    ScreenplayGenre(name: 'Thriller', image: 'assets/genres/thriller.png'),
    ScreenplayGenre(name: 'Drama', image: 'assets/genres/drama.png'),
    ScreenplayGenre(name: 'Crime', image: 'assets/genres/crime.png'),
    ScreenplayGenre(name: 'Science Fiction', image: 'assets/genres/science_fiction.png'),
    ScreenplayGenre(name: 'Mythology', image: 'assets/genres/mythology.png'),
    ScreenplayGenre(name: 'Superhero', image: 'assets/genres/superhero.png'),
    ScreenplayGenre(name: 'Fairy Tale', image: 'assets/genres/fairy_tale.png'),
    ScreenplayGenre(name: 'Historical', image: 'assets/genres/historical.png'),
    ScreenplayGenre(name: 'Historical Fiction', image: 'assets/genres/historical_fiction.png'),
    ScreenplayGenre(name: 'Non-Fiction', image: 'assets/genres/non_fiction.png'),
    ScreenplayGenre(name: 'Detective', image: 'assets/genres/detective.png'),
    ScreenplayGenre(name: 'Young Adult', image: 'assets/genres/young_adult.png'),
    ScreenplayGenre(name: 'Dystopian', image: 'assets/genres/dystopian.png'),
    ScreenplayGenre(name: 'Time Travel', image: 'assets/genres/time_travel.png'),
    ScreenplayGenre(name: 'Dark Fantasy', image: 'assets/genres/dark_fantasy.png'),
    ScreenplayGenre(name: 'Cyberpunk', image: 'assets/genres/cyberpunk.png'),
    ScreenplayGenre(name: 'Post-Apocalyptic', image: 'assets/genres/post_apocalyptic.png'),
    ScreenplayGenre(name: 'Spy', image: 'assets/genres/spy.png'),
  ];

  final List<String> tones = const [
    'Dramatic',
    'Dark',
    'Lighthearted',
    'Emotional',
    'Suspenseful',
    'Mysterious',
    'Romantic',
    'Comedic',
    'Inspirational',
    'Melancholic',
    'Intense',
    'Hopeful',
    'Gritty',
    'Whimsical',
    'Epic',
    'Satirical',
    'Realistic',
    'Heartwarming',
  ];

  final List<String> scriptFormats = const [
    'Standard Screenplay',
    'Film Script',
    'TV Script',
    'Short Film',
    'Stage Play',
    'Web Series',
    'Commercial',
    'YouTube Script',
    'Documentary',
  ];

  final List<String> includeOptions = const [
    'Everything',
    'Scene Headings',
    'Action',
    'Dialogue',
    'Character Descriptions',
    'Transitions',
    'Camera Directions',
    'Voice Over',
    'Narration',
    'Sound Effects',
  ];

  final List<String> contentRatings = const [
    'G – General Audiences',
    'PG – Parental Guidance',
    'PG-13 – Ages 13+',
    'R – Mature Audiences',
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
    _ideaController.dispose();
    _synopsisController.dispose();
    _settingController.dispose();
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
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 120),
                children: [
                  _buildTextField(
                    title: 'Title',
                    hint: 'Enter screenplay title',
                    controller: _titleController,
                  ),
                  const SizedBox(height: 17),
                  _buildTextField(
                    title: 'Written By',
                    hint: 'Enter author name',
                    controller: _authorController,
                  ),
                  const SizedBox(height: 17),
                  _buildLargeTextField(
                    title: 'Screenplay Idea',
                    hint: 'Enter your screenplay idea or logline...',
                    controller: _ideaController,
                    height: 120,
                  ),
                  const SizedBox(height: 17),
                  _buildLargeTextField(
                    title: 'Synopsis',
                    hint: 'Describe the screenplay synopsis...',
                    controller: _synopsisController,
                    height: 150,
                  ),
                  const SizedBox(height: 17),
                  _buildTextField(
                    title: 'Setting & Era',
                    hint: 'e.g. Present Day',
                    controller: _settingController,
                  ),
                  const SizedBox(height: 24),
                  _buildSceneSection(),
                  const SizedBox(height: 25),
                  _buildGenreSection(),
                  const SizedBox(height: 25),
                  _buildDropdownTile(
                    title: 'Choose Tone',
                    value: selectedTone,
                    icon: Icons.graphic_eq_rounded,
                    onTap: () => _showSelector(
                      title: 'Choose Tone',
                      values: tones,
                      selectedValue: selectedTone,
                      onSelected: (value) => setState(() => selectedTone = value),
                    ),
                  ),
                  _buildDropdownTile(
                    title: 'Script Format',
                    value: selectedScriptFormat,
                    icon: Icons.movie_creation_outlined,
                    onTap: () => _showSelector(
                      title: 'Choose Script Format',
                      values: scriptFormats,
                      selectedValue: selectedScriptFormat,
                      onSelected: (value) =>
                          setState(() => selectedScriptFormat = value),
                    ),
                  ),
                  _buildDropdownTile(
                    title: 'Choose Language',
                    value: selectedLanguage,
                    icon: Icons.language_rounded,
                    onTap: () => _showSelector(
                      title: 'Choose Language',
                      values: languages,
                      selectedValue: selectedLanguage,
                      searchable: true,
                      onSelected: (value) =>
                          setState(() => selectedLanguage = value),
                    ),
                  ),
                  _buildDropdownTile(
                    title: 'Include',
                    value: selectedIncludedElements,
                    icon: Icons.playlist_add_check_circle_outlined,
                    onTap: () => _showSelector(
                      title: 'Include',
                      values: includeOptions,
                      selectedValue: selectedIncludedElements,
                      onSelected: (value) =>
                          setState(() => selectedIncludedElements = value),
                    ),
                  ),
                  _buildDropdownTile(
                    title: 'Content Rating',
                    value: selectedContentRating,
                    icon: Icons.shield_outlined,
                    onTap: () => _showSelector(
                      title: 'Content Rating',
                      values: contentRatings,
                      selectedValue: selectedContentRating,
                      onSelected: (value) =>
                          setState(() => selectedContentRating = value),
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildLengthSection(),
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

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 10, 20, 12),
      child: Row(
        children: [
          InkWell(
            onTap: () => Navigator.pop(context),
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
              'Create Screenplay',
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

  Widget _buildTextField({
    required String title,
    required String hint,
    required TextEditingController controller,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle(title),
        const SizedBox(height: 9),
        Container(
          height: 52,
          decoration: BoxDecoration(
            color: _surface(context),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: _border(context)),
          ),
          child: TextField(
            controller: controller,
            style: TextStyle(fontSize: 14, color: _bodyText(context)),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(fontSize: 14, color: _hint(context)),
              border: InputBorder.none,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 15, vertical: 16),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLargeTextField({
    required String title,
    required String hint,
    required TextEditingController controller,
    required double height,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle(title),
        const SizedBox(height: 9),
        Container(
          height: height,
          decoration: BoxDecoration(
            color: _surface(context),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: _border(context)),
          ),
          child: TextField(
            controller: controller,
            expands: true,
            maxLines: null,
            textAlignVertical: TextAlignVertical.top,
            style: TextStyle(
              fontSize: 14,
              height: 1.45,
              color: _bodyText(context),
            ),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(fontSize: 14, color: _hint(context)),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.all(15),
            ),
          ),
        ),
      ],
    );
  }

  Widget _sectionTitle(String value) => Text(
        value,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w700,
          color: _text(context),
        ),
      );

  Widget _buildSceneSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(child: _sectionTitle('Scenes')),
            Container(
              constraints: const BoxConstraints(minWidth: 38),
              height: 32,
              padding: const EdgeInsets.symmetric(horizontal: 10),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: _accentSoft(context),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '$sceneCount',
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
            overlayColor: _accent(context).withValues(alpha: 0.12),
          ),
          child: Slider(
            value: sceneCount.toDouble(),
            min: 1,
            max: 25,
            divisions: 24,
            onChanged: (value) {
              // Swift version gates free users above 4 scenes.
              // Subscription check can be connected here later.
              setState(() => sceneCount = value.round());
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 2),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('1', style: TextStyle(fontSize: 11, color: _muted(context))),
              Text('25', style: TextStyle(fontSize: 11, color: _muted(context))),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildGenreSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(child: _sectionTitle('Select Genre')),
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
            separatorBuilder: (_, __) => const SizedBox(width: 10),
            itemBuilder: (context, index) => _buildGenreItem(genres[index]),
          ),
        ),
      ],
    );
  }

  Widget _buildGenreItem(ScreenplayGenre genre) {
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
              padding: EdgeInsets.all(selected ? 3 : 0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                border: selected
                    ? Border.all(color: _accent(context), width: 2)
                    : null,
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(selected ? 14 : 17),
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
                          Icons.movie_filter_outlined,
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
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                color: selected ? _accent(context) : _text(context),
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
    setState(() => selectedGenre = genreName);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_genreScrollController.hasClients || !mounted) return;
      const itemWidth = 92.0;
      const spacing = 10.0;
      final screenWidth = MediaQuery.sizeOf(context).width;
      double target =
          (index * (itemWidth + spacing)) - ((screenWidth - itemWidth) / 2);
      target = target.clamp(0.0, _genreScrollController.position.maxScrollExtent);
      _genreScrollController.animateTo(
        target,
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
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
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
                          Future.delayed(const Duration(milliseconds: 120), () {
                            if (mounted) _selectGenre(genre.name);
                          });
                        },
                        child: Column(
                          children: [
                            Expanded(
                              child: Container(
                                padding: EdgeInsets.all(selected ? 3 : 0),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(18),
                                  border: selected
                                      ? Border.all(
                                          color: _accent(context), width: 2)
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
                                        errorBuilder: (_, __, ___) => Container(
                                          color: _surfaceAlt(context),
                                          alignment: Alignment.center,
                                          child: Icon(
                                            Icons.movie_filter_outlined,
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
          constraints: const BoxConstraints(minHeight: 62),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: _surface(context),
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: _border(context)),
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
                child: Icon(icon, size: 19, color: _accent(context)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style:
                            TextStyle(fontSize: 12, color: _muted(context))),
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
              Icon(Icons.keyboard_arrow_down_rounded, color: _muted(context)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLengthSection() {
    const values = ['Short', 'Medium', 'Long'];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle('Screenplay Length'),
        const SizedBox(height: 12),
        Container(
          height: 48,
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: _isDark(context) ? const Color(0xFF2A2138) : Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: _isDark(context)
                  ? const Color(0xFF3A2F4B)
                  : const Color(0xFFEDEDED),
            ),
          ),
          child: Row(
            children: values.map((value) {
              final selected = selectedSceneLength == value;
              return Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => selectedSceneLength = value),
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
                        fontWeight:
                            selected ? FontWeight.w700 : FontWeight.w500,
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

  Widget _buildCharactersSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(child: _sectionTitle('Characters')),
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
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.person_outline_rounded,
                        size: 17, color: _accent(context)),
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
                      onTap: () => setState(() => _characters.removeAt(index)),
                      borderRadius: BorderRadius.circular(20),
                      child: Padding(
                        padding: const EdgeInsets.all(3),
                        child: Icon(Icons.close_rounded,
                            size: 16, color: _muted(context)),
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
                  child: Icon(Icons.add_rounded,
                      size: 20, color: _accent(context)),
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
    final character = await showModalBottomSheet<ScreenplayCharacterSpec>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: _surface(context),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => _ScreenplayCharacterInputSheet(
        surfaceAlt: _surfaceAlt(context),
        borderColor: _border(context),
        textColor: _bodyText(context),
        mutedColor: _muted(context),
        hintColor: _hint(context),
        accentColor: _accent(context),
      ),
    );
    if (!mounted || character == null) return;
    setState(() => _characters.add(character));
  }

  Widget _buildBottomBar() {
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 12),
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
          onTap: _createScreenplay,
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
                Icon(Icons.auto_awesome_rounded,
                    color: Colors.white, size: 18),
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

  void _createScreenplay() {
    final title = _titleController.text.trim();
    final writtenBy = _authorController.text.trim();
    final storyLogline = _ideaController.text.trim();
    final synopsis = _synopsisController.text.trim();
    final settingAndEra = _settingController.text.trim().isEmpty
        ? 'Present Day'
        : _settingController.text.trim();

    if (title.isEmpty) {
      _showAlert('Missing Title', 'Please enter a screenplay title.');
      return;
    }
    if (storyLogline.isEmpty) {
      _showAlert(
        'Missing Logline',
        'Please enter your screenplay idea or logline.',
      );
      return;
    }
    if (synopsis.isEmpty) {
      _showAlert('Missing Synopsis', 'Please enter a screenplay synopsis.');
      return;
    }

    final spec = ScreenplayGenerationSpec(
      title: title,
      writtenBy: writtenBy,
      storyLogline: storyLogline,
      synopsis: synopsis,
      tone: selectedTone,
      scriptFormat: selectedScriptFormat,
      language: selectedLanguage,
      includedElements: selectedIncludedElements,
      contentRating: selectedContentRating,
      settingAndEra: settingAndEra,
      genre: selectedGenre,
      sceneLength: selectedSceneLength,
      sceneCount: sceneCount,
      characters: List<ScreenplayCharacterSpec>.unmodifiable(_characters),
    );

    final systemPrompt = _outlineSystemPrompt();
    final userPrompt = _outlinePrompt(spec);

    debugPrint('============= SCREENPLAY SPEC =============');
    debugPrint('Title: ${spec.title}');
    debugPrint('Written By: ${spec.writtenBy}');
    debugPrint('Logline: ${spec.storyLogline}');
    debugPrint('Synopsis: ${spec.synopsis}');
    debugPrint('Genre: ${spec.genre}');
    debugPrint('Tone: ${spec.tone}');
    debugPrint('Script Format: ${spec.scriptFormat}');
    debugPrint('Language: ${spec.language}');
    debugPrint('Included Elements: ${spec.includedElements}');
    debugPrint('Content Rating: ${spec.contentRating}');
    debugPrint('Setting & Era: ${spec.settingAndEra}');
    debugPrint('Scene Length: ${spec.sceneLength}');
    debugPrint('Scene Count: ${spec.resolvedSceneCount}');
    debugPrint('Character Count: ${spec.characters.length}');
    debugPrint('Scene Word Target: ${spec.wordTargetText}');
    debugPrint('============= SYSTEM PROMPT =============');
    debugPrint(systemPrompt);
    debugPrint('============= OUTLINE PROMPT ============');
    debugPrint(userPrompt);
    debugPrint('=========================================');

    // Intentionally stops at prompt creation.
    // No API and no mock generation are used here.
    // Connect these prompts to your generation layer later.
  }

  String _outlineSystemPrompt() {
    return '''
You are an elite professional screenwriter,
story architect, script editor, continuity editor,
and visual dramatist.

Design ONE production-ready screenplay before
individual scenes are written.

A screenplay is not a novel divided into scenes.

Every scene must cause a meaningful change in:
- objective
- knowledge
- relationship
- power
- stakes
- plan
- possibility
- audience understanding

Build strict cause-and-effect progression.

CHARACTER AGENCY

Major characters make meaningful choices.
Supporting characters have independent motives,
loyalties, pressures, limits, and blind spots.

RELATIONSHIP ARCS

Emotional changes must be earned through
behavior, choices, discoveries, and consequences.

CONTINUITY DESIGN

Before planning, establish internally:
- character identities
- ages where supplied
- relationships
- chronology
- important locations
- important objects
- who knows what
- secrets
- injuries
- deaths
- promises
- established history

Once established, these facts are CANON.

Do not create later scene plans that contradict
earlier scene plans.

If a character is alive in one planned scene,
do not casually declare that same character died
before that scene.

Do not rename characters.

Do not change ownership or location of important
objects without planning the transfer.

REVEAL MANAGEMENT

Decide where major information is revealed.
Do not reveal a major answer before the scene
designed to reveal it.
A clue is not the same as a full revelation.

TIMELINE

Keep ages, dates, elapsed time, day/night,
travel time, and sequence of events coherent.

SETUP AND PAYOFF

Major climax solutions must come from previously
established:
- skills
- information
- objects
- relationships
- choices
- vulnerabilities
- rules

Never give a protagonist a new expert skill only
because the climax needs it.

SCENE VARIETY

Avoid neighboring scenes with identical:
objective, conflict engine, location rhythm,
emotional beat, character combination,
information flow, or ending mechanism.

FORMAT

Respect the selected screenplay format.
Return valid JSON only.
Never include markdown.
Never include commentary.
''';
  }

  String _outlinePrompt(ScreenplayGenerationSpec spec) {
    final total = spec.resolvedSceneCount;
    final languageName = spec.language.trim().isEmpty ? 'English' : spec.language;

    return '''
Plan a $total-scene ${spec.scriptFormat} screenplay.

TITLE:
${spec.title}

WRITTEN BY:
${spec.writtenBy}

LOGLINE:
${spec.storyLogline}

SYNOPSIS:
${spec.synopsis}

GENRE:
${spec.genre}

TONE:
${spec.tone}

LANGUAGE:
$languageName

OUTLINE LANGUAGE LOCK

The screenplay language is:
$languageName

Keep JSON property names exactly as requested, but write
ALL audience-facing JSON string VALUES in $languageName,
including:
- screenplay title when generated
- scene titles
- headings where language-specific text is appropriate
- premise
- throughline
- character arc
- beats
- advancements
- setting descriptions
- timeframe descriptions

Do not casually mix English with $languageName.

Proper nouns and conventional screenplay slugline markers
such as INT. and EXT. may remain unchanged when appropriate.

CONTENT RATING:
${spec.contentRating}

SETTING AND ERA:
${spec.settingAndEra}

IMPORTANT:

SETTING AND ERA is contextual world information.
It is NOT automatically a scene slugline location.

REQUIRED ELEMENTS:
${spec.includedElements}

CHARACTERS:
${_charactersBlock(spec)}

FORMAT REQUIREMENTS:
${_formatInstructions(spec.scriptFormat)}

CORE STORY DESIGN

Design ONE connected screenplay:
setup
-> escalation
-> complications
-> midpoint change
-> increasing cost
-> climax
-> earned resolution

THROUGHLINE

Define one central dramatic question.
Every scene must serve, complicate, redirect,
deepen, or resolve that question.

CAUSE AND EFFECT

Each scene should result from earlier:
choices, discoveries, failures, lies,
promises, pressure, or consequences.

CHARACTER ARC

Create a progressive emotional and behavioral arc.
Major changes require causes.

MIDPOINT

Create a meaningful midpoint shift.

CLIMAX

climaxScene must identify where the central
dramatic pressure peaks.

The climax must use established story elements.
Avoid coincidence-based rescue.

CONTINUITY

Plan chronology before writing the scene list.

Preserve:
- names
- ages
- relationships
- established deaths
- injuries
- secrets
- objects
- ownership
- locations
- knowledge
- promises
- timeline

REVEALS

Major revelations should have a planned scene.
Earlier scenes may plant evidence but must not
accidentally disclose the entire answer.

HEADING RULE

For film/TV screenplay formats use a specific
physical location:

INT. TRAIN CARRIAGE - NIGHT
EXT. FAMILY HOME - DAY

Never use the complete SETTING AND ERA description
as the slugline location.

Return ONLY this valid JSON object:

{
  "title": "<screenplay title>",
  "logline": "<one-sentence logline>",
  "premise": "<2-3 sentence premise>",
  "throughline": "<central dramatic question>",
  "characterArc": "<main progressive character arc>",
  "climaxScene": <integer 1-$total>,
  "scenes": [
    {
      "number": 1,
      "title": "<specific scene title>",
      "heading": "<valid specific heading>",
      "setting": "<specific physical place>",
      "timeframe": "<specific time/day or meaningful shift>",
      "focusCharacters": ["<names>"],
      "beat": "<objective -> resistance -> development -> turn -> changed situation>",
      "advances": "<exact story state changed>"
    }
  ]
}

The scenes array MUST contain exactly $total
scene objects.

Return JSON only.
''';
  }

  String _charactersBlock(ScreenplayGenerationSpec spec) {
    if (spec.characters.isEmpty) return 'None specified.';
    return spec.characters
        .map((character) => '- ${character.name}: ${character.description}')
        .join('\n');
  }

  String _formatInstructions(String scriptFormat) {
    final format = scriptFormat.toLowerCase();

    if (format.contains('stage')) {
      return '''
Use ACT and SCENE headings, concise stage
directions, entrances and exits, uppercase
character cues, and performable dialogue.
Do not use film camera shots.
''';
    }

    if (format.contains('commercial')) {
      return '''
Use numbered SHOT headings, concise visual
direction, VO:, ON-SCREEN TEXT:, product
action, and a clear closing message.
''';
    }

    if (format.contains('youtube')) {
      return '''
Use SEGMENT or SHOT headings, HOST: dialogue,
B-ROLL:, ON-SCREEN TEXT:, and concise
transitions.
''';
    }

    if (format.contains('documentary')) {
      return '''
Use SEQUENCE headings, NARRATOR (V.O.):,
INTERVIEW:, ARCHIVAL:, B-ROLL:, and factual
visual direction.
Do not invent factual claims not supplied by
the premise.
''';
    }

    return '''
Begin every scene with ONE INT., EXT., or INT./EXT.
slugline containing a specific physical location
and appropriate time of day.

Write visual present-tense action, uppercase
character cues, natural dialogue, and sparse
parentheticals.

Do not duplicate the opening slugline inside the
scene body when it is already supplied separately
as ===HEADING===.
''';
  }

  void _showAlert(String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: _surface(context),
        title: Text(title, style: TextStyle(color: _text(context))),
        content: Text(message, style: TextStyle(color: _muted(context))),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK', style: TextStyle(color: _accent(context))),
          ),
        ],
      ),
    );
  }

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
      builder: (context) => _ScreenplaySelectorSheet(
        title: title,
        values: values,
        selectedValue: selectedValue,
        searchable: searchable,
        onSelected: (value) {
          Navigator.pop(context);
          onSelected(value);
        },
      ),
    );
  }
}

class ScreenplayGenre {
  final String name;
  final String image;

  const ScreenplayGenre({required this.name, required this.image});
}

class ScreenplayCharacterSpec {
  final String name;
  final String description;

  const ScreenplayCharacterSpec({
    required this.name,
    required this.description,
  });
}

class ScreenplayGenerationSpec {
  final String title;
  final String writtenBy;
  final String storyLogline;
  final String synopsis;
  final String tone;
  final String scriptFormat;
  final String language;
  final String includedElements;
  final String contentRating;
  final String settingAndEra;
  final String genre;
  final String sceneLength;
  final int sceneCount;
  final List<ScreenplayCharacterSpec> characters;

  const ScreenplayGenerationSpec({
    required this.title,
    required this.writtenBy,
    required this.storyLogline,
    required this.synopsis,
    required this.tone,
    required this.scriptFormat,
    required this.language,
    required this.includedElements,
    required this.contentRating,
    required this.settingAndEra,
    required this.genre,
    required this.sceneLength,
    required this.sceneCount,
    required this.characters,
  });

  int get resolvedSceneCount => sceneCount > 0 ? sceneCount : 10;

  String get wordTargetText {
    final normalized = sceneLength.toLowerCase();
    if (normalized.contains('short')) return '200-300 words';
    if (normalized.contains('long')) return '700-900 words';
    return '400-600 words';
  }

  int get characterCap {
    final normalized = sceneLength.toLowerCase();
    if (normalized.contains('short')) return 2600;
    if (normalized.contains('long')) return 7000;
    return 4800;
  }

  int get maxTokens {
    final normalized = sceneLength.toLowerCase();
    if (normalized.contains('short')) return 1800;
    if (normalized.contains('long')) return 4200;
    return 3000;
  }

  int get minWordCount {
    final normalized = sceneLength.toLowerCase();
    if (normalized.contains('short')) return 200;
    if (normalized.contains('long')) return 700;
    return 400;
  }
}

class _ScreenplaySelectorSheet extends StatefulWidget {
  final String title;
  final List<String> values;
  final String selectedValue;
  final bool searchable;
  final ValueChanged<String> onSelected;

  const _ScreenplaySelectorSheet({
    required this.title,
    required this.values,
    required this.selectedValue,
    required this.searchable,
    required this.onSelected,
  });

  @override
  State<_ScreenplaySelectorSheet> createState() =>
      _ScreenplaySelectorSheetState();
}

class _ScreenplaySelectorSheetState extends State<_ScreenplaySelectorSheet> {
  final TextEditingController _searchController = TextEditingController();
  String search = '';

  List<String> get filtered {
    if (search.trim().isEmpty) return widget.values;
    final q = search.trim().toLowerCase();
    return widget.values.where((item) => item.toLowerCase().contains(q)).toList();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final maxHeight = MediaQuery.sizeOf(context).height * 0.50;
    final showSearch = widget.searchable && widget.values.length > 10;
    final items = filtered;
    final background = isDark ? const Color(0xFF21152F) : Colors.white;
    final secondary =
        isDark ? const Color(0xFF2A1A3B) : const Color(0xFFF4F4F4);
    final border =
        isDark ? const Color(0xFF49305F) : const Color(0xFFE8E8E8);
    final accent =
        isDark ? const Color(0xFF9146E8) : const Color(0xFFFF6435);
    final muted =
        isDark ? const Color(0xFFB9AEC8) : const Color(0xFF777777);
    final textColor = isDark ? Colors.white : const Color(0xFF222222);
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
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
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
                    icon: Icon(Icons.close_rounded,
                        size: 21, color: textColor),
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
                    onChanged: (value) => setState(() => search = value),
                    style: TextStyle(fontSize: 14, color: textColor),
                    decoration: InputDecoration(
                      hintText: 'Search',
                      hintStyle: TextStyle(color: muted),
                      prefixIcon: Icon(Icons.search_rounded, color: muted),
                      border: InputBorder.none,
                    ),
                  ),
                ),
              ),
            Expanded(
              child: items.isEmpty
                  ? Center(
                      child: Text('No results found',
                          style: TextStyle(color: muted)),
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
                        final selected = value == widget.selectedValue;
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
                                ? Icon(Icons.check_circle_rounded, color: accent)
                                : null,
                            onTap: () => widget.onSelected(value),
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

class _ScreenplayCharacterInputSheet extends StatefulWidget {
  final Color surfaceAlt;
  final Color borderColor;
  final Color textColor;
  final Color mutedColor;
  final Color hintColor;
  final Color accentColor;

  const _ScreenplayCharacterInputSheet({
    required this.surfaceAlt,
    required this.borderColor,
    required this.textColor,
    required this.mutedColor,
    required this.hintColor,
    required this.accentColor,
  });

  @override
  State<_ScreenplayCharacterInputSheet> createState() =>
      _ScreenplayCharacterInputSheetState();
}

class _ScreenplayCharacterInputSheetState
    extends State<_ScreenplayCharacterInputSheet> {
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
    FocusScope.of(context).unfocus();
    Navigator.of(context).pop(
      ScreenplayCharacterSpec(
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final keyboard = MediaQuery.viewInsetsOf(context).bottom;
    return AnimatedPadding(
      duration: const Duration(milliseconds: 180),
      padding: EdgeInsets.only(bottom: keyboard),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Add Character',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: widget.textColor,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: Icon(Icons.close_rounded, color: widget.textColor),
                ),
              ],
            ),
            const SizedBox(height: 10),
            _input(
              controller: _nameController,
              hint: 'Character name',
              maxLines: 1,
            ),
            const SizedBox(height: 12),
            _input(
              controller: _descriptionController,
              hint: 'Character description',
              maxLines: 4,
            ),
            const SizedBox(height: 18),
            GestureDetector(
              onTap: _canAdd ? _submit : null,
              child: AnimatedOpacity(
                opacity: _canAdd ? 1 : 0.45,
                duration: const Duration(milliseconds: 150),
                child: Container(
                  height: 52,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: widget.accentColor,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: const Text(
                    'Add Character',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _input({
    required TextEditingController controller,
    required String hint,
    required int maxLines,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: widget.surfaceAlt,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: widget.borderColor),
      ),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        style: TextStyle(color: widget.textColor),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: widget.hintColor),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(14),
        ),
      ),
    );
  }
}
