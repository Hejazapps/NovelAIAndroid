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
  final TextEditingController _settingsController = TextEditingController();

  String selectedGenre = 'Adventure';
  String selectedTone = 'Dramatic';
  String selectedScriptFormat = 'Standard Screenplay';
  String selectedIncludedElements = 'Everything';
  String selectedContentRating = 'PG-13 – Ages 13+';
  String selectedLanguage = 'English';
  String selectedLength = 'Short';

  int sceneCount = 4;

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

  final List<String> screenplayTones = const [
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

  final List<ScreenplayGenre> genres = const [
    ScreenplayGenre(
      name: 'Adventure',
      image: 'assets/genres/adventure.png',
    ),
    ScreenplayGenre(
      name: 'Fairy Tale',
      image: 'assets/genres/fairy_tale.png',
    ),
    ScreenplayGenre(
      name: 'Historical',
      image: 'assets/genres/historical.png',
    ),
    ScreenplayGenre(
      name: 'Comedy',
      image: 'assets/genres/comedy.png',
    ),
    ScreenplayGenre(
      name: 'Sad',
      image: 'assets/genres/sad.png',
    ),
    ScreenplayGenre(
      name: 'Non-Fiction',
      image: 'assets/genres/non_fiction.png',
    ),
    ScreenplayGenre(
      name: 'Drama',
      image: 'assets/genres/drama.png',
    ),
    ScreenplayGenre(
      name: 'Fantasy',
      image: 'assets/genres/fantasy.png',
    ),
    ScreenplayGenre(
      name: 'Mystery',
      image: 'assets/genres/mystery.png',
    ),
    ScreenplayGenre(
      name: 'Thriller',
      image: 'assets/genres/thriller.png',
    ),
    ScreenplayGenre(
      name: 'Horror',
      image: 'assets/genres/horror.png',
    ),
    ScreenplayGenre(
      name: 'Science Fiction',
      image: 'assets/genres/science_fiction.png',
    ),
    ScreenplayGenre(
      name: 'Romance',
      image: 'assets/genres/romance.png',
    ),
    ScreenplayGenre(
      name: 'Mythology',
      image: 'assets/genres/mythology.png',
    ),
    ScreenplayGenre(
      name: 'Superhero',
      image: 'assets/genres/superhero.png',
    ),
    ScreenplayGenre(
      name: 'Historical Fiction',
      image: 'assets/genres/historical_fiction.png',
    ),
    ScreenplayGenre(
      name: 'Crime',
      image: 'assets/genres/crime.png',
    ),
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _authorController.dispose();
    _ideaController.dispose();
    _synopsisController.dispose();
    _settingsController.dispose();
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
                    hint: 'Enter Title',
                    controller: _titleController,
                  ),

                  const SizedBox(height: 17),

                  _buildTextField(
                    title: 'Author',
                    hint: 'Enter Author Name',
                    controller: _authorController,
                  ),

                  const SizedBox(height: 22),

                  _buildLargeTextField(
                    title: 'Screenplay Idea',
                    hint:
                    'Describe your screenplay idea in one or two sentences.',
                    controller: _ideaController,
                    height: 145,
                  ),

                  const SizedBox(height: 20),

                  _buildLargeTextField(
                    title: 'Synopsis',
                    hint:
                    'Summarize the plot, characters, and key events of your screenplay.',
                    controller: _synopsisController,
                    height: 165,
                  ),

                  const SizedBox(height: 20),

                  _buildTextField(
                    title: 'Settings & Era',
                    hint: 'Neo-tokyo, 2087 - moonsoon season',
                    controller: _settingsController,
                  ),

                  const SizedBox(height: 25),

                  _buildGenreSection(),

                  const SizedBox(height: 25),

                  _buildDropdownTile(
                    title: 'Tone',
                    value: selectedTone,
                    icon: Icons.graphic_eq_rounded,
                    onTap: () {
                      _showSelector(
                        title: 'Select Tone',
                        values: screenplayTones,
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

                  _buildDropdownTile(
                    title: 'Script Format',
                    value: selectedScriptFormat,
                    icon: Icons.movie_creation_outlined,
                    onTap: () {
                      _showSelector(
                        title: 'Select Script Format',
                        values: scriptFormats,
                        selectedValue: selectedScriptFormat,
                        onSelected: (value) {
                          setState(() {
                            selectedScriptFormat = value;
                          });
                        },
                      );
                    },
                  ),

                  _buildDropdownTile(
                    title: 'Language',
                    value: selectedLanguage,
                    icon: Icons.language_rounded,
                    onTap: () {
                      _showSelector(
                        title: 'Select Language',
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
                    title: 'Include',
                    value: selectedIncludedElements,
                    icon: Icons.checklist_rounded,
                    onTap: () {
                      _showSelector(
                        title: 'Include',
                        values: includeOptions,
                        selectedValue: selectedIncludedElements,
                        onSelected: (value) {
                          setState(() {
                            selectedIncludedElements = value;
                          });
                        },
                      );
                    },
                  ),

                  _buildDropdownTile(
                    title: 'Content Rating',
                    value: selectedContentRating,
                    icon: Icons.shield_outlined,
                    onTap: () {
                      _showSelector(
                        title: 'Content Rating',
                        values: contentRatings,
                        selectedValue: selectedContentRating,
                        onSelected: (value) {
                          setState(() {
                            selectedContentRating = value;
                          });
                        },
                      );
                    },
                  ),

                  const SizedBox(height: 15),

                  _buildSceneCount(),

                  const SizedBox(height: 26),

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
      padding: const EdgeInsets.fromLTRB(
        14,
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
              'Create Screenplay',
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
  // NORMAL TEXT FIELD
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
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1B1B1B),
          ),
        ),

        const SizedBox(height: 9),

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
            controller: controller,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF222222),
            ),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: const TextStyle(
                fontSize: 14,
                color: Color(0xFFA0A0A0),
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
  // LARGE TEXT FIELD
  // ============================================================

  Widget _buildLargeTextField({
    required String title,
    required String hint,
    required TextEditingController controller,
    required double height,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1B1B1B),
          ),
        ),

        const SizedBox(height: 9),

        Container(
          height: height,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: const Color(0xFFE8E8E8),
            ),
          ),
          child: TextField(
            controller: controller,
            expands: true,
            maxLines: null,
            textAlignVertical: TextAlignVertical.top,
            style: const TextStyle(
              fontSize: 14,
              height: 1.45,
              color: Color(0xFF222222),
            ),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: const TextStyle(
                fontSize: 14,
                height: 1.4,
                color: Color(0xFFA0A0A0),
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
  // GENRE
  // ============================================================

  Widget _buildGenreSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Expanded(
              child: Text(
                'Select Genre',
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

        const SizedBox(height: 13),

        SizedBox(
          height: 130,
          child: ListView.separated(
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

  Widget _buildGenreItem(
      ScreenplayGenre genre,
      ) {
    final selected =
        selectedGenre == genre.name;

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedGenre = genre.name;
        });
      },
      child: SizedBox(
        width: 92,
        child: Column(
          children: [
            AnimatedContainer(
              duration:
              const Duration(milliseconds: 180),
              width: 88,
              height: 88,
              padding: EdgeInsets.all(
                selected ? 3 : 0,
              ),
              decoration: BoxDecoration(
                borderRadius:
                BorderRadius.circular(18),
                border: selected
                    ? Border.all(
                  color:
                  const Color(0xFFFF6435),
                  width: 2,
                )
                    : null,
              ),
              child: ClipRRect(
                borderRadius:
                BorderRadius.circular(
                  selected ? 14 : 17,
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
                        top: 6,
                        right: 6,
                        child: CircleAvatar(
                          radius: 10,
                          backgroundColor:
                          Color(0xFFFF6435),
                          child: Icon(
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
                    ? const Color(0xFFFF6435)
                    : const Color(0xFF333333),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // VIEW ALL GENRES
  // ============================================================

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
            MediaQuery.sizeOf(context).height *
                0.72,
            child: Column(
              children: [
                const SizedBox(height: 10),

                Container(
                  width: 42,
                  height: 5,
                  decoration: BoxDecoration(
                    color:
                    const Color(0xFFDADADA),
                    borderRadius:
                    BorderRadius.circular(10),
                  ),
                ),

                const Padding(
                  padding: EdgeInsets.fromLTRB(
                    20,
                    20,
                    20,
                    15,
                  ),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Select Genre',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight:
                        FontWeight.w700,
                      ),
                    ),
                  ),
                ),

                Expanded(
                  child: GridView.builder(
                    padding:
                    const EdgeInsets.fromLTRB(
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
                    itemBuilder:
                        (context, index) {
                      final genre =
                      genres[index];

                      final selected =
                          selectedGenre ==
                              genre.name;

                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            selectedGenre =
                                genre.name;
                          });

                          Navigator.pop(context);
                        },
                        child: Column(
                          children: [
                            Expanded(
                              child: Container(
                                padding:
                                EdgeInsets.all(
                                  selected ? 3 : 0,
                                ),
                                decoration:
                                BoxDecoration(
                                  borderRadius:
                                  BorderRadius
                                      .circular(
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
                                  BorderRadius
                                      .circular(
                                    14,
                                  ),
                                  child:
                                  Image.asset(
                                    genre.image,
                                    width: double
                                        .infinity,
                                    fit:
                                    BoxFit.cover,
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(
                              height: 7,
                            ),

                            Text(
                              genre.name,
                              maxLines: 1,
                              overflow:
                              TextOverflow
                                  .ellipsis,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: selected
                                    ? FontWeight
                                    .w700
                                    : FontWeight
                                    .w500,
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
  // DROPDOWN TILE
  // ============================================================

  Widget _buildDropdownTile({
    required String title,
    required String value,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding:
      const EdgeInsets.only(bottom: 11),
      child: InkWell(
        onTap: onTap,
        borderRadius:
        BorderRadius.circular(15),
        child: Container(
          constraints:
          const BoxConstraints(
            minHeight: 62,
          ),
          padding:
          const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 10,
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius:
            BorderRadius.circular(15),
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
                  color:
                  const Color(0xFFFFF0EA),
                  borderRadius:
                  BorderRadius.circular(
                    11,
                  ),
                ),
                child: Icon(
                  icon,
                  size: 19,
                  color:
                  const Color(0xFFFF6435),
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
                      style:
                      const TextStyle(
                        fontSize: 12,
                        color:
                        Color(0xFF888888),
                      ),
                    ),

                    const SizedBox(height: 3),

                    Text(
                      value,
                      style:
                      const TextStyle(
                        fontSize: 14,
                        fontWeight:
                        FontWeight.w600,
                        color:
                        Color(0xFF222222),
                      ),
                    ),
                  ],
                ),
              ),

              const Icon(
                Icons
                    .keyboard_arrow_down_rounded,
                color: Color(0xFF777777),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // SCENE COUNT
  // ============================================================

  Widget _buildSceneCount() {
    return Column(
      crossAxisAlignment:
      CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Expanded(
              child: Text(
                'Scenes',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight:
                  FontWeight.w700,
                  color:
                  Color(0xFF1B1B1B),
                ),
              ),
            ),

            Container(
              constraints:
              const BoxConstraints(
                minWidth: 38,
              ),
              height: 32,
              padding:
              const EdgeInsets.symmetric(
                horizontal: 10,
              ),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color:
                const Color(0xFFFFF0EA),
                borderRadius:
                BorderRadius.circular(10),
              ),
              child: Text(
                '$sceneCount',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight:
                  FontWeight.w700,
                  color:
                  Color(0xFFFF6435),
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 8),

        SliderTheme(
          data:
          SliderTheme.of(context).copyWith(
            trackHeight: 4,
            activeTrackColor:
            const Color(0xFFFF6435),
            inactiveTrackColor:
            const Color(0xFFE5E5E5),
            thumbColor:
            const Color(0xFFFF6435),
            overlayColor:
            const Color(0xFFFF6435)
                .withValues(
              alpha: 0.12,
            ),
          ),
          child: Slider(
            value: sceneCount.toDouble(),
            min: 1,
            max: 25,
            divisions: 24,
            onChanged: (value) {
              setState(() {
                sceneCount =
                    value.round();
              });

              // Free user > 4 subscription
              // check later.
            },
          ),
        ),

        const Row(
          mainAxisAlignment:
          MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '1',
              style: TextStyle(
                fontSize: 11,
                color:
                Color(0xFF999999),
              ),
            ),
            Text(
              '25',
              style: TextStyle(
                fontSize: 11,
                color:
                Color(0xFF999999),
              ),
            ),
          ],
        ),
      ],
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
      crossAxisAlignment:
      CrossAxisAlignment.start,
      children: [
        const Text(
          'Screenplay Length',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1B1B1B),
          ),
        ),

        const SizedBox(height: 12),

        Container(
          height: 48,
          padding:
          const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color:
            const Color(0xFFF1F1F1),
            borderRadius:
            BorderRadius.circular(14),
          ),
          child: Row(
            children:
            values.map((value) {
              final selected =
                  selectedLength == value;

              return Expanded(
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedLength =
                          value;
                    });
                  },
                  child:
                  AnimatedContainer(
                    duration:
                    const Duration(
                      milliseconds: 180,
                    ),
                    alignment:
                    Alignment.center,
                    decoration:
                    BoxDecoration(
                      color: selected
                          ? Colors.white
                          : Colors
                          .transparent,
                      borderRadius:
                      BorderRadius
                          .circular(11),
                      boxShadow: selected
                          ? [
                        BoxShadow(
                          color: Colors
                              .black
                              .withValues(
                            alpha:
                            0.07,
                          ),
                          blurRadius:
                          6,
                          offset:
                          const Offset(
                            0,
                            2,
                          ),
                        ),
                      ]
                          : null,
                    ),
                    child: Text(
                      value,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: selected
                            ? FontWeight
                            .w700
                            : FontWeight
                            .w500,
                        color: selected
                            ? const Color(
                          0xFFFF6435,
                        )
                            : const Color(
                          0xFF707070,
                        ),
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
        padding:
        const EdgeInsets.fromLTRB(
          20,
          10,
          20,
          12,
        ),
        decoration: BoxDecoration(
          color: const Color(0xFFF9F9F9),
          boxShadow: [
            BoxShadow(
              color:
              Colors.black.withValues(
                alpha: 0.04,
              ),
              blurRadius: 10,
              offset:
              const Offset(0, -3),
            ),
          ],
        ),
        child: GestureDetector(
          onTap: _createScreenplay,
          child: Container(
            height: 54,
            decoration: BoxDecoration(
              color:
              const Color(0xFFFF6435),
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
                  'Create',
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
    );
  }

  void _createScreenplay() {
    final title =
    _titleController.text.trim();

    final idea =
    _ideaController.text.trim();

    if (title.isEmpty) {
      _showAlert(
        'Missing Title',
        'Please enter a screenplay title.',
      );
      return;
    }

    if (idea.isEmpty) {
      _showAlert(
        'Missing Screenplay Idea',
        'Please describe your screenplay idea.',
      );
      return;
    }

    debugPrint(
        '========== SCREENPLAY ==========');
    debugPrint('Title: $title');
    debugPrint(
      'Author: ${_authorController.text.trim()}',
    );
    debugPrint('Idea: $idea');
    debugPrint(
      'Synopsis: ${_synopsisController.text.trim()}',
    );
    debugPrint(
      'Settings: ${_settingsController.text.trim()}',
    );
    debugPrint('Genre: $selectedGenre');
    debugPrint('Tone: $selectedTone');
    debugPrint(
        'Format: $selectedScriptFormat');
    debugPrint(
        'Language: $selectedLanguage');
    debugPrint(
        'Include: $selectedIncludedElements');
    debugPrint(
        'Rating: $selectedContentRating');
    debugPrint('Scenes: $sceneCount');
    debugPrint('Length: $selectedLength');
    debugPrint(
        '================================');

    // API generation later.
  }

  void _showAlert(
      String title,
      String message,
      ) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text(
                'OK',
                style: TextStyle(
                  color:
                  Color(0xFFFF6435),
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
    required ValueChanged<String>
    onSelected,
    bool searchable = false,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape:
      const RoundedRectangleBorder(
        borderRadius:
        BorderRadius.vertical(
          top: Radius.circular(25),
        ),
      ),
      builder: (context) {
        return _ScreenplaySelectorSheet(
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
// SELECTOR
// ============================================================

class _ScreenplaySelectorSheet
    extends StatefulWidget {
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
  State<_ScreenplaySelectorSheet>
  createState() =>
      _ScreenplaySelectorSheetState();
}

class _ScreenplaySelectorSheetState
    extends State<_ScreenplaySelectorSheet> {
  final TextEditingController
  _searchController =
  TextEditingController();

  String search = '';

  List<String> get filtered {
    if (search.trim().isEmpty) {
      return widget.values;
    }

    return widget.values.where((value) {
      return value
          .toLowerCase()
          .contains(
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
    return SafeArea(
      child: SizedBox(
        height:
        MediaQuery.sizeOf(context)
            .height *
            0.70,
        child: Column(
          children: [
            const SizedBox(height: 10),

            Container(
              width: 42,
              height: 5,
              decoration: BoxDecoration(
                color:
                const Color(0xFFDADADA),
                borderRadius:
                BorderRadius.circular(
                  10,
                ),
              ),
            ),

            Padding(
              padding:
              const EdgeInsets.fromLTRB(
                20,
                18,
                20,
                12,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      widget.title,
                      style:
                      const TextStyle(
                        fontSize: 20,
                        fontWeight:
                        FontWeight.w700,
                      ),
                    ),
                  ),

                  IconButton(
                    onPressed: () {
                      Navigator.pop(
                          context);
                    },
                    icon: const Icon(
                      Icons.close_rounded,
                    ),
                  ),
                ],
              ),
            ),

            if (widget.searchable &&
                widget.values.length > 10)
              Padding(
                padding:
                const EdgeInsets.fromLTRB(
                  20,
                  0,
                  20,
                  12,
                ),
                child: Container(
                  height: 46,
                  decoration: BoxDecoration(
                    color:
                    const Color(0xFFF4F4F4),
                    borderRadius:
                    BorderRadius.circular(
                      13,
                    ),
                  ),
                  child: TextField(
                    controller:
                    _searchController,
                    onChanged: (value) {
                      setState(() {
                        search = value;
                      });
                    },
                    decoration:
                    const InputDecoration(
                      hintText: 'Search',
                      prefixIcon: Icon(
                        Icons.search_rounded,
                      ),
                      border:
                      InputBorder.none,
                    ),
                  ),
                ),
              ),

            Expanded(
              child: ListView.separated(
                itemCount:
                filtered.length,
                separatorBuilder: (_, __) {
                  return const Divider(
                    height: 1,
                    indent: 20,
                    endIndent: 20,
                  );
                },
                itemBuilder:
                    (context, index) {
                  final value =
                  filtered[index];

                  final selected =
                      value ==
                          widget
                              .selectedValue;

                  return ListTile(
                    contentPadding:
                    const EdgeInsets
                        .symmetric(
                      horizontal: 20,
                    ),
                    title: Text(
                      value,
                      style: TextStyle(
                        fontWeight: selected
                            ? FontWeight
                            .w700
                            : FontWeight
                            .w500,
                        color: selected
                            ? const Color(
                          0xFFFF6435,
                        )
                            : const Color(
                          0xFF222222,
                        ),
                      ),
                    ),
                    trailing: selected
                        ? const Icon(
                      Icons
                          .check_circle_rounded,
                      color:
                      Color(0xFFFF6435),
                    )
                        : null,
                    onTap: () {
                      widget
                          .onSelected(value);
                    },
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

class ScreenplayGenre {
  final String name;
  final String image;

  const ScreenplayGenre({
    required this.name,
    required this.image,
  });
}