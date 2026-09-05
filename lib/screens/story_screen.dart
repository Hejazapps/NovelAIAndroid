import 'package:flutter/material.dart';

class StoryScreen extends StatefulWidget {
  const StoryScreen({super.key});

  @override
  State<StoryScreen> createState() => _StoryScreenState();
}

class _StoryScreenState extends State<StoryScreen> {
  final TextEditingController _promptController = TextEditingController();
  final TextEditingController _titleController = TextEditingController();

  String selectedGenre = 'Horror';
  String selectedLength = 'Short';

  bool get canGenerate => _promptController.text.trim().isNotEmpty;

  final List<StoryGenre> genres = const [
    StoryGenre(
      name: 'Horror',
      image: 'assets/genres/horror.png',
    ),
    StoryGenre(
      name: 'Comedy',
      image: 'assets/genres/comedy.png',
    ),
    StoryGenre(
      name: 'Sad',
      image: 'assets/genres/sad.png',
    ),
    StoryGenre(
      name: 'Romance',
      image: 'assets/genres/romance.png',
    ),
    StoryGenre(
      name: 'Adventure',
      image: 'assets/genres/adventure.png',
    ),
    StoryGenre(
      name: 'Fantasy',
      image: 'assets/genres/fantasy.png',
    ),
    StoryGenre(
      name: 'Mystery',
      image: 'assets/genres/mystery.png',
    ),
    StoryGenre(
      name: 'Thriller',
      image: 'assets/genres/thriller.png',
    ),
    StoryGenre(
      name: 'Drama',
      image: 'assets/genres/drama.png',
    ),
    StoryGenre(
      name: 'Crime',
      image: 'assets/genres/crime.png',
    ),
    StoryGenre(
      name: 'Science Fiction',
      image: 'assets/genres/science_fiction.png',
    ),
    StoryGenre(
      name: 'Mythology',
      image: 'assets/genres/mythology.png',
    ),
    StoryGenre(
      name: 'Superhero',
      image: 'assets/genres/superhero.png',
    ),
    StoryGenre(
      name: 'Fairy Tale',
      image: 'assets/genres/fairy_tale.png',
    ),
    StoryGenre(
      name: 'Historical',
      image: 'assets/genres/historical.png',
    ),
    StoryGenre(
      name: 'Historical Fiction',
      image: 'assets/genres/historical_fiction.png',
    ),
    StoryGenre(
      name: 'Non-Fiction',
      image: 'assets/genres/non_fiction.png',
    ),
  ];

  @override
  void initState() {
    super.initState();

    _promptController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _promptController.dispose();
    _titleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),

      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),

            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.only(
                  bottom: 120,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildPromptSection(),

                    const SizedBox(height: 24),

                    _buildTitleSection(),

                    const SizedBox(height: 26),

                    _buildGenreSection(),

                    const SizedBox(height: 28),

                    _buildLengthSection(),

                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),

      bottomNavigationBar: _buildBottomGenerateArea(),
    );
  }

  // ============================================================
  // HEADER
  // ============================================================

  Widget _buildHeader() {
    return Container(
      color: const Color(0xFFF9F9F9),
      padding: const EdgeInsets.fromLTRB(
        16,
        10,
        20,
        12,
      ),
      child: Row(
        children: [
          InkWell(
            onTap: () {
              Navigator.pop(context);
            },
            borderRadius: BorderRadius.circular(30),
            child: const SizedBox(
              width: 42,
              height: 42,
              child: Icon(
                Icons.arrow_back_ios_new_rounded,
                size: 21,
                color: Colors.black,
              ),
            ),
          ),

          const SizedBox(width: 4),

          const Expanded(
            child: Text(
              'Create Story',
              style: TextStyle(
                fontSize: 23,
                fontWeight: FontWeight.w700,
                color: Color(0xFF171717),
              ),
            ),
          ),

          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(13),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(
                    alpha: 0.06,
                  ),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: const Icon(
              Icons.workspace_premium_outlined,
              size: 21,
              color: Color(0xFFFF6435),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // PROMPT
  // ============================================================

  Widget _buildPromptSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 20,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Enter Your Imaginations',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1B1B1B),
            ),
          ),

          const SizedBox(height: 12),

          Container(
            height: 205,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: const Color(0xFFE8E8E8),
              ),
            ),
            child: Column(
              children: [
                _buildRewriteHeader(),

                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(
                      15,
                      4,
                      15,
                      4,
                    ),
                    child: TextField(
                      controller: _promptController,
                      maxLines: null,
                      expands: true,
                      textAlignVertical: TextAlignVertical.top,
                      style: const TextStyle(
                        fontSize: 14,
                        height: 1.45,
                        color: Color(0xFF222222),
                      ),
                      decoration: const InputDecoration(
                        hintText: 'Describe your prompt here…',
                        hintStyle: TextStyle(
                          fontSize: 14,
                          color: Color(0xFFA2A2A2),
                        ),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                ),

                _buildPromptBottomBar(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRewriteHeader() {
    return Container(
      height: 45,
      padding: const EdgeInsets.symmetric(
        horizontal: 14,
      ),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Color(0xFFF0F0F0),
          ),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 27,
            height: 27,
            decoration: BoxDecoration(
              color: const Color(0xFFFFEEE8),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.auto_awesome_rounded,
              size: 16,
              color: Color(0xFFFF6435),
            ),
          ),

          const SizedBox(width: 8),

          const Text(
            'Rewrite with AI',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Color(0xFF272727),
            ),
          ),

          const Spacer(),

          const Icon(
            Icons.chevron_right_rounded,
            size: 20,
            color: Color(0xFF777777),
          ),
        ],
      ),
    );
  }

  Widget _buildPromptBottomBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        14,
        6,
        10,
        10,
      ),
      child: Row(
        children: [
          if (_promptController.text.trim().isNotEmpty)
            InkWell(
              onTap: () {
                _promptController.clear();
              },
              borderRadius: BorderRadius.circular(12),
              child: const Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: 4,
                  vertical: 5,
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.close_rounded,
                      size: 17,
                      color: Color(0xFF777777),
                    ),
                    SizedBox(width: 4),
                    Text(
                      'Clear',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF555555),
                      ),
                    ),
                  ],
                ),
              ),
            ),

          const Spacer(),

          InkWell(
            onTap: () {
              _promptController.text =
              'A mysterious stranger arrives in a quiet town carrying a secret that could change everyone forever.';

              _promptController.selection =
                  TextSelection.fromPosition(
                    TextPosition(
                      offset: _promptController.text.length,
                    ),
                  );
            },
            borderRadius: BorderRadius.circular(20),
            child: Container(
              height: 32,
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
              ),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF0EA),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Row(
                children: [
                  Icon(
                    Icons.auto_awesome,
                    size: 15,
                    color: Color(0xFFFF6435),
                  ),
                  SizedBox(width: 6),
                  Text(
                    'Inspire Me',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFFFF6435),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // STORY TITLE
  // ============================================================

  Widget _buildTitleSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 20,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Story Title',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1B1B1B),
            ),
          ),

          const SizedBox(height: 10),

          Container(
            height: 52,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: const Color(0xFFE8E8E8),
              ),
            ),
            child: TextField(
              controller: _titleController,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black,
              ),
              decoration: const InputDecoration(
                hintText: 'Enter story title',
                hintStyle: TextStyle(
                  fontSize: 14,
                  color: Color(0xFFA0A0A0),
                ),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 15,
                  vertical: 16,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // GENRES
  // ============================================================

  Widget _buildGenreSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 20,
          ),
          child: Row(
            children: [
              const Expanded(
                child: Text(
                  'Story Genre',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1B1B1B),
                  ),
                ),
              ),

              InkWell(
                onTap: _showAllGenres,
                child: const Padding(
                  padding: EdgeInsets.all(6),
                  child: Text(
                    'View All',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFFFF6435),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 13),

        SizedBox(
          height: 115,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(
              horizontal: 20,
            ),
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: genres.length,
            separatorBuilder: (_, __) {
              return const SizedBox(width: 11);
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

  Widget _buildGenreItem(StoryGenre genre) {
    final selected = genre.name == selectedGenre;

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedGenre = genre.name;
        });
      },
      child: SizedBox(
        width: 82,
        child: Column(
          children: [
            AnimatedContainer(
              duration: const Duration(
                milliseconds: 180,
              ),
              width: 78,
              height: 78,
              padding: EdgeInsets.all(
                selected ? 3 : 0,
              ),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(17),
                border: selected
                    ? Border.all(
                  color: const Color(0xFFFF6435),
                  width: 2,
                )
                    : null,
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(
                  selected ? 13 : 16,
                ),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.asset(
                      genre.image,
                      fit: BoxFit.cover,
                    ),

                    if (selected)
                      const Positioned(
                        top: 5,
                        right: 5,
                        child: CircleAvatar(
                          radius: 9,
                          backgroundColor:
                          Color(0xFFFF6435),
                          child: Icon(
                            Icons.check_rounded,
                            color: Colors.white,
                            size: 12,
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
              style: TextStyle(
                fontSize: 11,
                fontWeight: selected
                    ? FontWeight.w700
                    : FontWeight.w500,
                color: selected
                    ? const Color(0xFFFF6435)
                    : const Color(0xFF333333),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAllGenres() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(25),
        ),
      ),
      builder: (context) {
        return SafeArea(
          child: SizedBox(
            height:
            MediaQuery.sizeOf(context).height * 0.72,
            child: Column(
              children: [
                const SizedBox(height: 10),

                Container(
                  width: 42,
                  height: 5,
                  decoration: BoxDecoration(
                    color: const Color(0xFFDADADA),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),

                const Padding(
                  padding: EdgeInsets.fromLTRB(
                    20,
                    20,
                    20,
                    15,
                  ),
                  child: Row(
                    children: [
                      Text(
                        'Select Genre',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),

                Expanded(
                  child: GridView.builder(
                    padding: const EdgeInsets.fromLTRB(
                      20,
                      0,
                      20,
                      20,
                    ),
                    gridDelegate:
                    const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      mainAxisSpacing: 18,
                      crossAxisSpacing: 15,
                      childAspectRatio: 0.82,
                    ),
                    itemCount: genres.length,
                    itemBuilder: (
                        context,
                        index,
                        ) {
                      final genre = genres[index];

                      final selected =
                          genre.name == selectedGenre;

                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            selectedGenre = genre.name;
                          });

                          Navigator.pop(context);
                        },
                        child: Column(
                          children: [
                            Expanded(
                              child: Container(
                                padding: EdgeInsets.all(
                                  selected ? 3 : 0,
                                ),
                                decoration: BoxDecoration(
                                  borderRadius:
                                  BorderRadius.circular(
                                    18,
                                  ),
                                  border: selected
                                      ? Border.all(
                                    color:
                                    const Color(
                                      0xFFFF6435,
                                    ),
                                    width: 2,
                                  )
                                      : null,
                                ),
                                child: ClipRRect(
                                  borderRadius:
                                  BorderRadius.circular(
                                    14,
                                  ),
                                  child: Image.asset(
                                    genre.image,
                                    width:
                                    double.infinity,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(height: 7),

                            Text(
                              genre.name,
                              maxLines: 1,
                              overflow:
                              TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: selected
                                    ? FontWeight.w700
                                    : FontWeight.w500,
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
  // LENGTH
  // ============================================================

  Widget _buildLengthSection() {
    const values = [
      'Short',
      'Medium',
      'Long',
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 20,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Story Length',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1B1B1B),
            ),
          ),

          const SizedBox(height: 12),

          Container(
            height: 48,
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F1F1),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: values.map((value) {
                final selected =
                    selectedLength == value;

                return Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedLength = value;
                      });
                    },
                    child: AnimatedContainer(
                      duration:
                      const Duration(
                        milliseconds: 180,
                      ),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: selected
                            ? Colors.white
                            : Colors.transparent,
                        borderRadius:
                        BorderRadius.circular(11),
                        boxShadow: selected
                            ? [
                          BoxShadow(
                            color:
                            Colors.black.withValues(
                              alpha: 0.07,
                            ),
                            blurRadius: 6,
                            offset:
                            const Offset(0, 2),
                          ),
                        ]
                            : null,
                      ),
                      child: Text(
                        value,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: selected
                              ? FontWeight.w700
                              : FontWeight.w500,
                          color: selected
                              ? const Color(0xFFFF6435)
                              : const Color(0xFF707070),
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // BOTTOM BAR
  // ============================================================

  Widget _buildBottomGenerateArea() {
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
          color: const Color(0xFFF9F9F9),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(
                alpha: 0.04,
              ),
              blurRadius: 10,
              offset: const Offset(0, -3),
            ),
          ],
        ),
        child: Row(
          children: [
            InkWell(
              onTap: _showAdvancedSettings,
              borderRadius: BorderRadius.circular(15),
              child: Container(
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(
                    color: const Color(0xFFE6E6E6),
                  ),
                ),
                child: const Icon(
                  Icons.tune_rounded,
                  color: Color(0xFF202020),
                ),
              ),
            ),

            const SizedBox(width: 12),

            Expanded(
              child: AnimatedOpacity(
                duration: const Duration(
                  milliseconds: 160,
                ),
                opacity: canGenerate ? 1 : 0.4,
                child: GestureDetector(
                  onTap: canGenerate
                      ? () {
                    // Generation logic later.
                  }
                      : null,
                  child: Container(
                    height: 54,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFF6435),
                      borderRadius:
                      BorderRadius.circular(16),
                    ),
                    alignment: Alignment.center,
                    child: const Row(
                      mainAxisAlignment:
                      MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.auto_awesome_rounded,
                          color: Colors.white,
                          size: 18,
                        ),
                        SizedBox(width: 8),
                        Text(
                          'Generate',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight:
                            FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ],
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

  void _showAdvancedSettings() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) {
          return const AdvancedStorySettingsScreen();
        },
      ),
    );
  }
}

// ============================================================
// ADVANCED SETTINGS SCREEN
// ============================================================

class AdvancedStorySettingsScreen extends StatefulWidget {
  const AdvancedStorySettingsScreen({
    super.key,
  });

  @override
  State<AdvancedStorySettingsScreen> createState() =>
      _AdvancedStorySettingsScreenState();
}

class _AdvancedStorySettingsScreenState
    extends State<AdvancedStorySettingsScreen> {
  String language = 'English';
  String storyType = 'Fictional';
  String ending = 'Happy';
  String narrative = 'First Person';
  String pacing = 'Balanced';
  String focus = 'Balanced';
  String dialogue = 'Balanced';
  String emotionalDepth = 'Moderate';
  String ageGroup = 'Adults (18+)';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF9F9F9),
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            size: 20,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text(
          'Advance Settings',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),

      body: ListView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(
          20,
          8,
          20,
          30,
        ),
        children: [
          _settingTile(
            'Language',
            language,
            Icons.language_rounded,
                () {
              _selectValue(
                title: 'Language',
                values: const [
                  'English',
                  'Bengali',
                  'Arabic',
                  'Spanish',
                  'French',
                  'German',
                  'Hindi',
                  'Japanese',
                  'Korean',
                ],
                current: language,
                onSelected: (value) {
                  setState(() {
                    language = value;
                  });
                },
              );
            },
          ),

          _settingTile(
            'Story Type',
            storyType,
            Icons.auto_stories_outlined,
                () {
              _selectValue(
                title: 'Story Type',
                values: const [
                  'Fictional',
                  'Social Media',
                ],
                current: storyType,
                onSelected: (value) {
                  setState(() {
                    storyType = value;
                  });
                },
              );
            },
          ),

          _settingTile(
            'Ending Type',
            ending,
            Icons.flag_outlined,
                () {},
          ),

          _settingTile(
            'Narrative',
            narrative,
            Icons.record_voice_over_outlined,
                () {},
          ),

          _settingTile(
            'Pacing',
            pacing,
            Icons.speed_rounded,
                () {},
          ),

          _settingTile(
            'Story Focus',
            focus,
            Icons.center_focus_strong_rounded,
                () {},
          ),

          _settingTile(
            'Dialogue Level',
            dialogue,
            Icons.chat_bubble_outline_rounded,
                () {},
          ),

          _settingTile(
            'Emotional Depth',
            emotionalDepth,
            Icons.favorite_border_rounded,
                () {},
          ),

          const SizedBox(height: 14),

          const Text(
            'Main Characters',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),

          const SizedBox(height: 10),

          Container(
            height: 56,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
              border: Border.all(
                color: const Color(0xFFE7E7E7),
              ),
            ),
            child: const Row(
              children: [
                SizedBox(width: 15),
                CircleAvatar(
                  radius: 16,
                  backgroundColor: Color(0xFFFFEEE8),
                  child: Icon(
                    Icons.add_rounded,
                    size: 20,
                    color: Color(0xFFFF6435),
                  ),
                ),
                SizedBox(width: 11),
                Text(
                  'Add Main Character',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          _settingTile(
            'Age Group',
            ageGroup,
            Icons.groups_2_outlined,
                () {
              _selectValue(
                title: 'Age Group',
                values: const [
                  'Adults (18+)',
                  'Teenagers (13–17)',
                  'Pre-teen (8–12)',
                  'Children (1–7)',
                ],
                current: ageGroup,
                onSelected: (value) {
                  setState(() {
                    ageGroup = value;
                  });
                },
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _settingTile(
      String title,
      String value,
      IconData icon,
      VoidCallback onTap,
      ) {
    return Padding(
      padding: const EdgeInsets.only(
        bottom: 11,
      ),
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
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
            border: Border.all(
              color: const Color(0xFFE9E9E9),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF0EA),
                  borderRadius: BorderRadius.circular(11),
                ),
                child: Icon(
                  icon,
                  size: 19,
                  color: const Color(0xFFFF6435),
                ),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF888888),
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      value,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF222222),
                      ),
                    ),
                  ],
                ),
              ),

              const Icon(
                Icons.keyboard_arrow_down_rounded,
                color: Color(0xFF777777),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _selectValue({
    required String title,
    required List<String> values,
    required String current,
    required ValueChanged<String> onSelected,
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(24),
        ),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 10),

              Container(
                width: 40,
                height: 5,
                decoration: BoxDecoration(
                  color: const Color(0xFFDADADA),
                  borderRadius:
                  BorderRadius.circular(10),
                ),
              ),

              Padding(
                padding: const EdgeInsets.fromLTRB(
                  20,
                  18,
                  20,
                  10,
                ),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 19,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),

              ListView.builder(
                shrinkWrap: true,
                itemCount: values.length,
                itemBuilder: (context, index) {
                  final value = values[index];

                  return ListTile(
                    title: Text(value),
                    trailing: value == current
                        ? const Icon(
                      Icons.check_circle_rounded,
                      color: Color(0xFFFF6435),
                    )
                        : null,
                    onTap: () {
                      onSelected(value);
                      Navigator.pop(context);
                    },
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }
}

// ============================================================
// MODEL
// ============================================================

class StoryGenre {
  final String name;
  final String image;

  const StoryGenre({
    required this.name,
    required this.image,
  });
}