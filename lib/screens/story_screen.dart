import 'package:flutter/material.dart';

class StoryScreen extends StatefulWidget {
  const StoryScreen({
    super.key,
    this.onGenerate,
  });

  /// Later, when your generation/result screen is ready, pass a callback here.
  /// For now Generate prints the complete prompt to the debug console.
  final ValueChanged<StoryGenerationRequest>? onGenerate;

  @override
  State<StoryScreen> createState() => _StoryScreenState();
}

class _StoryScreenState extends State<StoryScreen> {
  final TextEditingController _promptController = TextEditingController();
  final TextEditingController _titleController = TextEditingController();
  final ScrollController _genreScrollController = ScrollController();

  String selectedGenre = 'Horror';
  String selectedLength = 'Short';
  String selectedCreativity = 'Standard';

  StoryAdvancedSettings advancedSettings = const StoryAdvancedSettings();

  final List<StoryCharacter> characters = [];

  bool get canGenerate => _promptController.text.trim().isNotEmpty;

  final List<StoryGenre> genres = const [
    StoryGenre(name: 'Horror', image: 'assets/genres/horror.png'),
    StoryGenre(name: 'Comedy', image: 'assets/genres/comedy.png'),
    StoryGenre(name: 'Sad', image: 'assets/genres/sad.png'),
    StoryGenre(name: 'Romance', image: 'assets/genres/romance.png'),
    StoryGenre(name: 'Adventure', image: 'assets/genres/adventure.png'),
    StoryGenre(name: 'Fantasy', image: 'assets/genres/fantasy.png'),
    StoryGenre(name: 'Mystery', image: 'assets/genres/mystery.png'),
    StoryGenre(name: 'Thriller', image: 'assets/genres/thriller.png'),
    StoryGenre(name: 'Drama', image: 'assets/genres/drama.png'),
    StoryGenre(name: 'Crime', image: 'assets/genres/crime.png'),
    StoryGenre(
      name: 'Science Fiction',
      image: 'assets/genres/science_fiction.png',
    ),
    StoryGenre(name: 'Mythology', image: 'assets/genres/mythology.png'),
    StoryGenre(name: 'Superhero', image: 'assets/genres/superhero.png'),
    StoryGenre(name: 'Fairy Tale', image: 'assets/genres/fairy_tale.png'),
    StoryGenre(name: 'Historical', image: 'assets/genres/historical.png'),
    StoryGenre(
      name: 'Historical Fiction',
      image: 'assets/genres/historical_fiction.png',
    ),
    StoryGenre(name: 'Non-Fiction', image: 'assets/genres/non_fiction.png'),

    // Genres used by Inspire Me stories.
    // If you have dedicated images for these, keep these asset names.
    // The UI already has an errorBuilder fallback if an asset is missing.
    StoryGenre(name: 'Detective', image: 'assets/genres/detective.png'),
    StoryGenre(name: 'Young Adult', image: 'assets/genres/young_adult.png'),
    StoryGenre(name: 'Dystopian', image: 'assets/genres/dystopian.png'),
    StoryGenre(name: 'Time Travel', image: 'assets/genres/time_travel.png'),
    StoryGenre(name: 'Dark Fantasy', image: 'assets/genres/dark_fantasy.png'),
    StoryGenre(name: 'Cyberpunk', image: 'assets/genres/cyberpunk.png'),
    StoryGenre(
      name: 'Post-Apocalyptic',
      image: 'assets/genres/post_apocalyptic.png',
    ),
    StoryGenre(name: 'Spy', image: 'assets/genres/spy.png'),
  ];

  final List<StoryF> stories = const [
    StoryF(
      id: 1,
      genre: 'Romance',
      title: 'Letters Written by Fate',
      prompt: '''
Write a romance story about two strangers who receive anonymous handwritten love letters meant for each other every year, despite never meeting. As the letters reveal shared dreams and hidden truths, fate gives them one final chance to discover who has been writing them all along.
''',
      length: 'Medium',
      creativityLevel: 'Creative',
      ageGroup: 'Teenagers (13–17)',
    ),
    StoryF(
      id: 2,
      genre: 'Fantasy',
      title: 'The Bookstore of Tomorrow',
      prompt: '''
Write a fantasy story about a forgotten bookstore where every book tells a future that has not happened yet. When one visitor reads a story about their own destiny, they must decide whether to change it or let magic follow its course.
''',
      length: 'Long',
      creativityLevel: 'Creative',
      ageGroup: 'Teenagers (13–17)',
    ),
    StoryF(
      id: 3,
      genre: 'Mystery',
      title: 'The Lighthouse That Never Sleeps',
      prompt: '''
Write a mystery story about an abandoned lighthouse that mysteriously shines every full moon, despite having no keeper for decades. A determined investigator follows the clues to uncover a disappearance that history tried to erase.
''',
      length: 'Medium',
      creativityLevel: 'Complex',
      ageGroup: 'Adults (18+)',
    ),
    StoryF(
      id: 4,
      genre: 'Thriller',
      title: "Tomorrow's Headline",
      prompt: '''
Write a thriller story about a journalist who receives tomorrow's newspaper and discovers their own murder on the front page. With only twenty-four hours left, they must uncover the truth before the headline becomes reality.
''',
      length: 'Medium',
      creativityLevel: 'Complex',
      ageGroup: 'Adults (18+)',
    ),
    StoryF(
      id: 5,
      genre: 'Horror',
      title: 'The Last Photograph',
      prompt: '''
Write a horror story about a family whose photographs begin showing one extra person after every midnight. Night after night, the mysterious figure moves closer until it finally disappears from the pictures and appears inside their home.
''',
      length: 'Long',
      creativityLevel: 'Complex',
      ageGroup: 'Adults (18+)',
    ),
    StoryF(
      id: 6,
      genre: 'Science Fiction',
      title: 'The Planet That Remembered Tomorrow',
      prompt: '''
Write a science fiction story about humanity's first faster-than-light mission discovering a distant civilization that already knows Earth's entire future. The crew must decide whether changing destiny will save humanity or destroy it forever.
''',
      length: 'Long',
      creativityLevel: 'Creative',
      ageGroup: 'Teenagers (13–17)',
    ),
    StoryF(
      id: 7,
      genre: 'Adventure',
      title: 'The Skybound Kingdom',
      prompt: '''
Write an adventure story about a forgotten map hidden inside an antique pocket watch that leads to a legendary city above the clouds. An explorer races against ruthless treasure hunters to uncover its greatest secret first.
''',
      length: 'Medium',
      creativityLevel: 'Creative',
      ageGroup: 'Pre-teen (8–12)',
    ),
    StoryF(
      id: 8,
      genre: 'Crime',
      title: 'The Island Without Escape',
      prompt: '''
Write a crime story about a billionaire who vanishes from a heavily guarded private island during an exclusive gala, leaving every guest as a suspect. As the investigation unfolds, every clue reveals a deeper conspiracy.
''',
      length: 'Long',
      creativityLevel: 'Complex',
      ageGroup: 'Adults (18+)',
    ),
    StoryF(
      id: 9,
      genre: 'Detective',
      title: 'The Impossible Confession',
      prompt: '''
Write a detective story where every suspect confesses to the same impossible murder, even though only one of them could be guilty. A brilliant detective must solve the contradiction before another victim is found.
''',
      length: 'Medium',
      creativityLevel: 'Complex',
      ageGroup: 'Adults (18+)',
    ),
    StoryF(
      id: 10,
      genre: 'Young Adult',
      title: "Tomorrow's Classroom",
      prompt: '''
Write a young adult story about a quiet high school student who discovers a hidden classroom where tomorrow's events appear on the walls every morning. Every decision they make begins changing the future in unexpected ways.
''',
      length: 'Short',
      creativityLevel: 'Standard',
      ageGroup: 'Teenagers (13–17)',
    ),
    StoryF(
      id: 11,
      genre: 'Comedy',
      title: 'The Truth Took a Day Off',
      prompt: '''
Write a comedy story about an ordinary office worker whose harmless little lies suddenly become reality. As the chaos grows funnier each day, they must find a way to tell the truth before their entire life turns upside down.
''',
      length: 'Short',
      creativityLevel: 'Standard',
      ageGroup: 'Pre-teen (8–12)',
    ),
    StoryF(
      id: 12,
      genre: 'Historical',
      title: "The Empire's Lost Secret",
      prompt: '''
Write a historical story about a young royal archivist who discovers a hidden document revealing the true reason an ancient empire disappeared. Powerful forces will do anything to keep the secret buried forever.
''',
      length: 'Medium',
      creativityLevel: 'Creative',
      ageGroup: 'Teenagers (13–17)',
    ),
    StoryF(
      id: 13,
      genre: 'Dystopian',
      title: 'The Blank Destiny',
      prompt: '''
Write a dystopian story where every citizen's future is assigned by artificial intelligence at birth. When one teenager receives a completely blank future, they uncover a secret capable of rewriting society itself.
''',
      length: 'Long',
      creativityLevel: 'Complex',
      ageGroup: 'Adults (18+)',
    ),
    StoryF(
      id: 14,
      genre: 'Time Travel',
      title: 'A Letter From Tomorrow',
      prompt: '''
Write a time travel story about a scientist who receives a handwritten letter from their future self warning them never to complete their greatest invention. Every choice they make begins rewriting history.
''',
      length: 'Medium',
      creativityLevel: 'Creative',
      ageGroup: 'Teenagers (13–17)',
    ),
    StoryF(
      id: 15,
      genre: 'Superhero',
      title: 'The Sixty-Second Hero',
      prompt: '''
Write a superhero story about an ordinary paramedic who discovers the power to freeze time for exactly sixty seconds whenever someone's life is at risk. As a powerful enemy emerges, every second becomes more valuable than ever.
''',
      length: 'Short',
      creativityLevel: 'Standard',
      ageGroup: 'Pre-teen (8–12)',
    ),
    StoryF(
      id: 16,
      genre: 'Dark Fantasy',
      title: 'The Last Tree of Light',
      prompt: '''
Write a dark fantasy story about a cursed knight sworn to protect the last tree of light in a kingdom consumed by eternal darkness. When the tree begins to die, an ancient evil awakens to claim the world.
''',
      length: 'Long',
      creativityLevel: 'Complex',
      ageGroup: 'Adults (18+)',
    ),
    StoryF(
      id: 17,
      genre: 'Cyberpunk',
      title: 'The Memory Market',
      prompt: '''
Write a cyberpunk story about a gifted hacker who discovers a hidden digital city where stolen memories are traded as currency. One forgotten memory could expose the truth behind humanity's entire existence.
''',
      length: 'Medium',
      creativityLevel: 'Complex',
      ageGroup: 'Adults (18+)',
    ),
    StoryF(
      id: 18,
      genre: 'Post-Apocalyptic',
      title: 'The First Dawn',
      prompt: '''
Write a post-apocalyptic story about the last train crossing a shattered continent with humanity's final survivors aboard. Along the journey, they uncover the real reason civilization collapsed and one last chance to rebuild it.
''',
      length: 'Long',
      creativityLevel: 'Complex',
      ageGroup: 'Adults (18+)',
    ),
    StoryF(
      id: 19,
      genre: 'Spy',
      title: 'Operation Black Echo',
      prompt: '''
Write a spy story about an undercover intelligence agent who discovers that every mission they completed was preparing them for one impossible assignment - to stop a global war planned from inside their own agency.
''',
      length: 'Short',
      creativityLevel: 'Creative',
      ageGroup: 'Adults (18+)',
    ),
    StoryF(
      id: 20,
      genre: 'Fairy Tale',
      title: 'The Tree of Endless Doors',
      prompt: '''
Write a fairy tale story about a lonely child who discovers an ancient tree that grows magical doors instead of fruit. Behind each door lies a different enchanted world, but only one can save their own.
''',
      length: 'Short',
      creativityLevel: 'Standard',
      ageGroup: 'Children (1–7)',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _promptController.addListener(_refreshGenerateButton);
  }

  void _refreshGenerateButton() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _promptController.removeListener(_refreshGenerateButton);
    _promptController.dispose();
    _titleController.dispose();
    _genreScrollController.dispose();
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
                padding: const EdgeInsets.only(bottom: 120),
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

  Widget _buildHeader() {
    return Container(
      color: const Color(0xFFF9F9F9),
      padding: const EdgeInsets.fromLTRB(16, 10, 20, 12),
      child: Row(
        children: [
          InkWell(
            onTap: () => Navigator.maybePop(context),
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
                  color: Colors.black.withValues(alpha: 0.06),
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

  Widget _buildPromptSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
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
              border: Border.all(color: const Color(0xFFE8E8E8)),
            ),
            child: Column(
              children: [
                _buildRewriteHeader(),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(15, 4, 15, 4),
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
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFFF0F0F0))),
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
      padding: const EdgeInsets.fromLTRB(14, 6, 10, 10),
      child: Row(
        children: [
          if (_promptController.text.trim().isNotEmpty)
            InkWell(
              onTap: _promptController.clear,
              borderRadius: BorderRadius.circular(12),
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 4, vertical: 5),
                child: Row(
                  children: [
                    Icon(Icons.close_rounded, size: 17, color: Color(0xFF777777)),
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
            onTap: _inspireMe,
            borderRadius: BorderRadius.circular(20),
            child: Container(
              height: 32,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF0EA),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Row(
                children: [
                  Icon(Icons.auto_awesome, size: 15, color: Color(0xFFFF6435)),
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

  void _inspireMe() {
    if (stories.isEmpty) return;

    final story = (List<StoryF>.from(stories)..shuffle()).first;

    setState(() {
      _titleController.text = story.title;
      _promptController.text = story.prompt.trim();
      selectedLength = story.length;
      selectedCreativity = story.creativityLevel;

      advancedSettings = StoryAdvancedSettings(
        language: advancedSettings.language,
        storyType: advancedSettings.storyType,
        ending: advancedSettings.ending,
        narrative: advancedSettings.narrative,
        pacing: advancedSettings.pacing,
        focus: advancedSettings.focus,
        dialogue: advancedSettings.dialogue,
        emotionalDepth: advancedSettings.emotionalDepth,
        ageGroup: story.ageGroup,
      );
    });

    _selectGenre(story.genre);

    _promptController.selection = TextSelection.fromPosition(
      TextPosition(offset: _promptController.text.length),
    );

    debugPrint('============================================================');
    debugPrint('✨ INSPIRE ME STORY SELECTED');
    debugPrint('============================================================');
    debugPrint('ID          : ${story.id}');
    debugPrint('Genre       : ${story.genre}');
    debugPrint('Title       : ${story.title}');
    debugPrint('Length      : ${story.length}');
    debugPrint('Creativity  : ${story.creativityLevel}');
    debugPrint('Age Group   : ${story.ageGroup}');
    debugPrint('Prompt      : ${story.prompt.trim()}');
    debugPrint('============================================================');
  }

  Widget _buildTitleSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
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
              border: Border.all(color: const Color(0xFFE8E8E8)),
            ),
            child: TextField(
              controller: _titleController,
              style: const TextStyle(fontSize: 14, color: Colors.black),
              decoration: const InputDecoration(
                hintText: 'Enter story title',
                hintStyle: TextStyle(fontSize: 14, color: Color(0xFFA0A0A0)),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(horizontal: 15, vertical: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGenreSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
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
            controller: _genreScrollController,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: genres.length,
            separatorBuilder: (_, __) => const SizedBox(width: 11),
            itemBuilder: (context, index) => _buildGenreItem(genres[index]),
          ),
        ),
      ],
    );
  }

  Widget _buildGenreItem(StoryGenre genre) {
    final selected = genre.name == selectedGenre;

    return GestureDetector(
      onTap: () => _selectGenre(genre.name),
      child: SizedBox(
        width: 82,
        child: Column(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              width: 78,
              height: 78,
              padding: EdgeInsets.all(selected ? 3 : 0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(17),
                border: selected
                    ? Border.all(color: const Color(0xFFFF6435), width: 2)
                    : null,
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(selected ? 13 : 16),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.asset(
                      genre.image,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        color: const Color(0xFFF1F1F1),
                        alignment: Alignment.center,
                        child: const Icon(
                          Icons.auto_stories_outlined,
                          color: Color(0xFF999999),
                        ),
                      ),
                    ),
                    if (selected)
                      const Positioned(
                        top: 5,
                        right: 5,
                        child: CircleAvatar(
                          radius: 9,
                          backgroundColor: Color(0xFFFF6435),
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
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
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

  void _selectGenre(String genreName) {
    final index = genres.indexWhere((genre) => genre.name == genreName);
    if (index == -1) return;

    setState(() => selectedGenre = genreName);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_genreScrollController.hasClients || !mounted) return;

      const itemWidth = 82.0;
      const spacing = 11.0;
      const itemExtent = itemWidth + spacing;
      final screenWidth = MediaQuery.sizeOf(context).width;

      double targetOffset =
          (index * itemExtent) - ((screenWidth - itemWidth) / 2);

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
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: SizedBox(
            height: MediaQuery.sizeOf(context).height * 0.72,
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
                  padding: EdgeInsets.fromLTRB(20, 20, 20, 15),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Select Genre',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
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
                      final selected = genre.name == selectedGenre;

                      return GestureDetector(
                        onTap: () {
                          Navigator.pop(sheetContext);
                          Future.delayed(
                            const Duration(milliseconds: 120),
                            () {
                              if (mounted) _selectGenre(genre.name);
                            },
                          );
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
                                          color: const Color(0xFFFF6435),
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
                                        errorBuilder: (_, __, ___) => Container(
                                          color: const Color(0xFFF1F1F1),
                                          alignment: Alignment.center,
                                          child: const Icon(
                                            Icons.auto_stories_outlined,
                                            color: Color(0xFF999999),
                                          ),
                                        ),
                                      ),
                                      if (selected)
                                        const Positioned(
                                          top: 6,
                                          right: 6,
                                          child: CircleAvatar(
                                            radius: 10,
                                            backgroundColor: Color(0xFFFF6435),
                                            child: Icon(
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
                                    ? const Color(0xFFFF6435)
                                    : const Color(0xFF333333),
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

  Widget _buildLengthSection() {
    const values = ['Short', 'Medium', 'Long'];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
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
                final selected = selectedLength == value;

                return Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => selectedLength = value),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: selected ? Colors.white : Colors.transparent,
                        borderRadius: BorderRadius.circular(11),
                        boxShadow: selected
                            ? [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.07),
                                  blurRadius: 6,
                                  offset: const Offset(0, 2),
                                ),
                              ]
                            : null,
                      ),
                      child: Text(
                        value,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight:
                              selected ? FontWeight.w700 : FontWeight.w500,
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

  Widget _buildBottomGenerateArea() {
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 12),
        decoration: BoxDecoration(
          color: const Color(0xFFF9F9F9),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
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
                  border: Border.all(color: const Color(0xFFE6E6E6)),
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
                duration: const Duration(milliseconds: 160),
                opacity: canGenerate ? 1 : 0.4,
                child: GestureDetector(
                  onTap: canGenerate ? _generatePressed : null,
                  child: Container(
                    height: 54,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFF6435),
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
                          'Generate',
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
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showAdvancedSettings() async {
    FocusScope.of(context).unfocus();

    final result = await Navigator.of(context).push<AdvancedStorySettingsResult>(
      MaterialPageRoute(
        builder: (_) => AdvancedStorySettingsScreen(
          initialSettings: advancedSettings,
          initialCharacters: characters,
        ),
      ),
    );

    if (!mounted || result == null) return;

    setState(() {
      advancedSettings = result.settings;
      characters
        ..clear()
        ..addAll(result.characters);
    });
  }

  void _generatePressed() {
    FocusScope.of(context).unfocus();

    final request = StoryGenerationRequest(
      title: _titleController.text.trim(),
      userPrompt: _promptController.text.trim(),
      genre: selectedGenre,
      length: selectedLength,
      creativityLevel: selectedCreativity,
      settings: advancedSettings,
      characters: List<StoryCharacter>.unmodifiable(characters),
    );

    final generatedPrompt = _buildStoryPrompt(request);

    debugPrint('\n');
    debugPrint('============================================================');
    debugPrint('✅ STORY GENERATE PRESSED');
    debugPrint('============================================================');
    debugPrint('Title       : ${request.title}');
    debugPrint('Genre       : ${request.genre}');
    debugPrint('Length      : ${request.length}');
    debugPrint('Creativity  : ${request.creativityLevel}');
    debugPrint('Language    : ${request.settings.language}');
    debugPrint('Story Type  : ${request.settings.storyType}');
    debugPrint('Ending      : ${request.settings.ending}');
    debugPrint('Narrative   : ${request.settings.narrative}');
    debugPrint('Pacing      : ${request.settings.pacing}');
    debugPrint('Story Focus : ${request.settings.focus}');
    debugPrint('Dialogue    : ${request.settings.dialogue}');
    debugPrint('Emotion     : ${request.settings.emotionalDepth}');
    debugPrint('============================================================');
    debugPrint('✅ GENERATED STORY PROMPT');
    debugPrint('============================================================');
    debugPrint(generatedPrompt);
    debugPrint('============================================================');

    // Later you can navigate to your generation/result screen from this callback.
    widget.onGenerate?.call(
      request.copyWith(generatedPrompt: generatedPrompt),
    );
  }

  String _buildStoryPrompt(StoryGenerationRequest request) {
    final settings = request.settings;
    final targetWordCount = _targetWordCount(request.length);
    final scriptName = _languageScriptName(settings.language);

    final titleLine = request.title.isEmpty
        ? ''
        : '''
STORY TITLE REFERENCE:
- Intended title: ${request.title}
- Do not print the title unless the product later requests it.
''';

    final additionalContext = request.userPrompt.isEmpty
        ? ''
        : '''
ADDITIONAL CONTEXT FROM THE USER:
- Naturally incorporate the following idea into the story.
- Treat it as creative direction, not as text that must be copied word-for-word.

${request.userPrompt}
''';

    final advancedPrompt = _advancedSettingsPrompt(settings);
    final characterPrompt = _characterPrompt(request.characters);

    if (settings.storyType == 'Social Media') {
      return '''
ABSOLUTE LANGUAGE REQUIREMENT:
- Write the ENTIRE story in ${settings.language} from beginning to end.
- Use ONLY $scriptName.
- Every sentence, paragraph, dialogue, narration, and description must remain in ${settings.language}.
- Do not switch language before the final line.

Create an engaging ${request.genre} story designed for social-media reading.

CRITICAL OUTPUT FORMAT:
- Start directly with the actual story.
- Do not explain the writing process.
- Do not ask for feedback.
- Output only the finished story.
- Keep paragraphs easy to read on a phone.

STORY PARAMETERS:
- Genre: ${request.genre}
- Target Length: ${request.length}
- Creativity Level: ${request.creativityLevel}
- Target Word Count: approximately $targetWordCount words
- Age Group: ${settings.ageGroup}
- Mandatory Language: ${settings.language}
- Mandatory Script: $scriptName
- Story Type: ${settings.storyType}

$titleLine
$advancedPrompt
$characterPrompt

NARRATIVE REQUIREMENTS:
- Open with a strong hook.
- Establish the central situation quickly.
- Keep the plot moving.
- Use natural dialogue where appropriate.
- Build toward a clear climax.
- Resolve the primary conflict.
- Give the story a genuine final ending.

WRITING QUALITY:
- Make the story coherent, immersive, emotionally believable, and appropriate for ${settings.ageGroup}.
- Avoid unnecessary repetition.
- Do not over-explain minor details.
- Preserve enough output space for the climax and ending.

$additionalContext

CRITICAL COMPLETION RULES:
- The story MUST finish.
- Never stop in the middle of a sentence, dialogue, scene, or confrontation.
- Never stop at the climax without resolution.
- Never leave the main conflict unresolved.
- Never write "To be continued".
- If output space becomes limited, compress secondary scenes and move directly toward the climax and resolution.
- Producing fewer than $targetWordCount words is preferable to leaving the story incomplete.

FINAL PRIORITY:
1. Complete the story with a real ending.
2. Keep the entire output in ${settings.language} using $scriptName.
3. Respect the selected genre, creativity level, and advanced settings.
4. Aim for approximately $targetWordCount words.

Output ONLY the complete finished story.
''';
    }

    return '''
ABSOLUTE LANGUAGE REQUIREMENT:
- Write the ENTIRE story in ${settings.language} from beginning to end.
- Use ONLY $scriptName.
- Do not mix English or any other language unless it is naturally required by a proper noun.
- Every sentence, paragraph, dialogue, narration, and description must be in ${settings.language}.
- Maintain ${settings.language} from the first word to the final word.

Write an engaging ${request.genre} fictional story.

CRITICAL OUTPUT FORMAT:
- Start directly with the actual story in ${settings.language}.
- Do not add a title at the beginning.
- Do not use labels such as Hook, Development, Climax, Resolution, or Conclusion.
- Do not explain the writing process.
- Do not add a moral after the story unless it naturally belongs to the selected ending.
- Do not ask for feedback.
- Output only the finished story.

STORY PARAMETERS:
- Genre: ${request.genre}
- Target Length: ${request.length}
- Creativity Level: ${request.creativityLevel}
- Target Word Count: approximately $targetWordCount words
- Age Group: ${settings.ageGroup}
- Mandatory Language: ${settings.language}
- Mandatory Script: $scriptName
- Story Type: ${settings.storyType}

$titleLine
$advancedPrompt
$characterPrompt

NARRATIVE STRUCTURE:
- Begin with an engaging opening that establishes the important setting and character.
- Introduce the central conflict without spending too much of the response on setup.
- Develop characters and relationships while advancing the plot.
- Build tension progressively.
- Create a meaningful turning point.
- Reach a clear climax.
- Resolve the main conflict.
- Provide a genuine final ending.
- Every major section must move the story toward completion.

WRITING QUALITY:
- Use rich but controlled descriptive language appropriate for ${settings.ageGroup}.
- Create believable dialogue.
- Maintain logical plot progression.
- Include emotional depth.
- Avoid unnecessary repetition.
- Avoid over-explaining minor details.
- Do not allow description to consume space needed for the conclusion.
- Use symbolism, metaphor, foreshadowing, or parallel structure only when they improve the story.

$additionalContext

LANGUAGE VERIFICATION:
- Every sentence must be in ${settings.language}.
- Use $scriptName consistently.
- All dialogue must be in ${settings.language}.
- All narration must be in ${settings.language}.
- All descriptions must be in ${settings.language}.

CRITICAL STORY COMPLETION RULES:
- Target approximately $targetWordCount words.
- The story MUST finish even if the exact word count cannot be reached.
- Internally plan the beginning, development, climax, resolution, and ending before writing.
- Reserve enough output capacity for every stage.
- By roughly the final 25 percent of the response, move decisively through the climax and resolution.

EMERGENCY COMPLETION RULE:
- If output space appears to be running low, stop expanding secondary scenes.
- Remove unnecessary description.
- Shorten dialogue.
- Compress secondary events.
- Move directly to the climax.
- Resolve the primary conflict.
- Deliver the selected ending.
- Write a final paragraph that clearly closes the story.

ABSOLUTE ENDING REQUIREMENTS:
- NEVER stop in the middle of a sentence.
- NEVER stop in the middle of dialogue.
- NEVER stop in the middle of a scene.
- NEVER stop during an unresolved confrontation.
- NEVER stop at the climax without resolution.
- NEVER leave the central conflict unresolved.
- NEVER write "To be continued".
- NEVER ask the user to continue.
- The final paragraph must unmistakably feel like the true end.

If necessary, produce fewer than $targetWordCount words rather than leaving the story incomplete.

FINAL PRIORITY ORDER:
1. COMPLETE THE STORY WITH A REAL ENDING.
2. Keep the entire output in ${settings.language} using $scriptName.
3. Respect the selected creativity level, ending, narrative, pacing, focus, dialogue level, emotional depth, age group, and story type.
4. Aim for approximately $targetWordCount words.

Output ONLY the complete finished story.
''';
  }

  String _characterPrompt(List<StoryCharacter> characters) {
    if (characters.isEmpty) return '';

    final buffer = StringBuffer('\nMAIN CHARACTERS:\n');

    for (int i = 0; i < characters.length; i++) {
      final character = characters[i];
      final role = i == 0
          ? 'Protagonist'
          : i == 1
              ? 'Supporting Character'
              : 'Additional Character';

      buffer.writeln('- $role: ${character.name}');
      if (character.description.trim().isNotEmpty) {
        buffer.writeln('  Description: ${character.description.trim()}');
      }
    }

    buffer.writeln(
      '- Keep these characters consistent and develop meaningful interactions between them.',
    );

    return buffer.toString();
  }

  String _advancedSettingsPrompt(StoryAdvancedSettings settings) {
    return '''
ADVANCED STORY SETTINGS:
- Ending Type: ${settings.ending}
  Direction: The conclusion must follow this ending choice naturally and be fully delivered before the response stops.
- Narrative: ${settings.narrative}
  Direction: Maintain this narrative perspective consistently throughout the complete story.
- Pacing: ${settings.pacing}
  Direction: Control the overall speed and rhythm of the story according to this value.
- Story Focus: ${settings.focus}
  Direction: Give the selected element the strongest emphasis throughout the story.
- Dialogue Level: ${settings.dialogue}
  Direction: Adjust the amount of character conversation according to this value.
- Emotional Depth: ${settings.emotionalDepth}
  Direction: Explore character emotions and emotional consequences according to this value.
- Apply every selected advanced setting consistently.
- Blend these settings naturally into the narrative.
- Do not mention the setting names or their values in the final story.
''';
  }

  int _targetWordCount(String length) {
    switch (length.toLowerCase()) {
      case 'medium':
        return 1600;
      case 'long':
        return 3600;
      case 'short':
      default:
        return 800;
    }
  }

  String _languageScriptName(String language) {
    final value = language.toLowerCase();

    if (value.contains('bengali') || value.contains('bangla')) {
      return 'বাংলা (Bengali script)';
    }
    if (value.contains('arabic')) {
      return 'العربية (Arabic script)';
    }
    if (value.contains('hindi')) {
      return 'हिन्दी (Hindi/Devanagari script)';
    }
    if (value.contains('urdu')) {
      return 'اردو (Urdu script)';
    }
    if (value.contains('chinese')) {
      return '中文 (Chinese characters)';
    }
    if (value.contains('japanese')) {
      return '日本語 (Japanese script)';
    }
    if (value.contains('korean')) {
      return '한국어 (Korean script)';
    }
    if (value.contains('thai')) {
      return 'ไทย (Thai script)';
    }

    return language;
  }
}

class AdvancedStorySettingsScreen extends StatefulWidget {
  const AdvancedStorySettingsScreen({
    super.key,
    required this.initialSettings,
    required this.initialCharacters,
  });

  final StoryAdvancedSettings initialSettings;
  final List<StoryCharacter> initialCharacters;

  @override
  State<AdvancedStorySettingsScreen> createState() =>
      _AdvancedStorySettingsScreenState();
}

class _AdvancedStorySettingsScreenState
    extends State<AdvancedStorySettingsScreen> {
  late String language;
  late String storyType;
  late String ending;
  late String narrative;
  late String pacing;
  late String focus;
  late String dialogue;
  late String emotionalDepth;
  late String ageGroup;
  late List<StoryCharacter> characters;

  @override
  void initState() {
    super.initState();
    language = widget.initialSettings.language;
    storyType = widget.initialSettings.storyType;
    ending = widget.initialSettings.ending;
    narrative = widget.initialSettings.narrative;
    pacing = widget.initialSettings.pacing;
    focus = widget.initialSettings.focus;
    dialogue = widget.initialSettings.dialogue;
    emotionalDepth = widget.initialSettings.emotionalDepth;
    ageGroup = widget.initialSettings.ageGroup;
    characters = List<StoryCharacter>.from(widget.initialCharacters);
  }

  StoryAdvancedSettings get _currentSettings => StoryAdvancedSettings(
        language: language,
        storyType: storyType,
        ending: ending,
        narrative: narrative,
        pacing: pacing,
        focus: focus,
        dialogue: dialogue,
        emotionalDepth: emotionalDepth,
        ageGroup: ageGroup,
      );

  void _closeWithSettings() {
    Navigator.pop(
      context,
      AdvancedStorySettingsResult(
        settings: _currentSettings,
        characters: List<StoryCharacter>.unmodifiable(characters),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) _closeWithSettings();
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF9F9F9),
        appBar: AppBar(
          backgroundColor: const Color(0xFFF9F9F9),
          surfaceTintColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
            onPressed: _closeWithSettings,
          ),
          title: const Text(
            'Advance Settings',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
          ),
        ),
        body: ListView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 30),
          children: [
            _settingTile('Language', language, Icons.language_rounded, () {
              _selectValue(
                title: 'Language',
                values: const [
                  'English',
                  'Bengali',
                  'Arabic',
                  'Catalan',
                  'Chinese Simplified',
                  'Chinese Traditional',
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
                  'Norwegian Bokmål',
                  'Polish',
                  'Portuguese',
                  'Portuguese (Brazil)',
                  'Romanian',
                  'Russian',
                  'Slovak',
                  'Spanish',
                  'Swedish',
                  'Thai',
                  'Turkish',
                  'Ukrainian',
                  'Vietnamese',
                ],
                current: language,
                onSelected: (value) => setState(() => language = value),
              );
            }),
            _settingTile(
              'Story Type',
              storyType,
              Icons.auto_stories_outlined,
              () {
                _selectValue(
                  title: 'Story Type',
                  values: const ['Fictional', 'Social Media'],
                  current: storyType,
                  onSelected: (value) => setState(() => storyType = value),
                );
              },
            ),
            _settingTile('Ending Type', ending, Icons.flag_outlined, () {
              _selectValue(
                title: 'Ending Type',
                values: const [
                  'Happy Ending',
                  'Sad Ending',
                  'Bittersweet Ending',
                  'Open Ending',
                  'Cliffhanger Ending',
                  'Twist Ending',
                  'Moral Ending',
                  'Full-Circle Ending',
                  'Ambiguous Ending',
                  'Redemption Ending',
                  'Poetic Ending',
                  'Cyclical Ending',
                ],
                current: ending,
                onSelected: (value) => setState(() => ending = value),
              );
            }),
            _settingTile(
              'Narrative',
              narrative,
              Icons.record_voice_over_outlined,
              () {
                _selectValue(
                  title: 'Narrative',
                  values: const [
                    'First-person',
                    'Second-person',
                    'Third-person Limited',
                    'Third-person Omniscient',
                    'Third-person Objective',
                    'Multiple POV',
                    'Stream of Consciousness',
                    'Unreliable Narrator',
                  ],
                  current: narrative,
                  onSelected: (value) => setState(() => narrative = value),
                );
              },
            ),
            _settingTile('Pacing', pacing, Icons.speed_rounded, () {
              _selectValue(
                title: 'Pacing',
                values: const ['Slow', 'Balanced', 'Fast', 'Very Fast'],
                current: pacing,
                onSelected: (value) => setState(() => pacing = value),
              );
            }),
            _settingTile(
              'Story Focus',
              focus,
              Icons.center_focus_strong_rounded,
              () {
                _selectValue(
                  title: 'Story Focus',
                  values: const [
                    'Balanced',
                    'Character Driven',
                    'Plot Driven',
                    'Dialogue Focused',
                    'World Building',
                    'Action Focused',
                    'Emotion Focused',
                  ],
                  current: focus,
                  onSelected: (value) => setState(() => focus = value),
                );
              },
            ),
            _settingTile(
              'Dialogue Level',
              dialogue,
              Icons.chat_bubble_outline_rounded,
              () {
                _selectValue(
                  title: 'Dialogue Level',
                  values: const [
                    'Minimal',
                    'Low',
                    'Balanced',
                    'High',
                    'Dialogue Heavy',
                  ],
                  current: dialogue,
                  onSelected: (value) => setState(() => dialogue = value),
                );
              },
            ),
            _settingTile(
              'Emotional Depth',
              emotionalDepth,
              Icons.favorite_border_rounded,
              () {
                _selectValue(
                  title: 'Emotional Depth',
                  values: const [
                    'Light',
                    'Moderate',
                    'Deep',
                    'Very Deep',
                    'Intense',
                  ],
                  current: emotionalDepth,
                  onSelected: (value) => setState(() => emotionalDepth = value),
                );
              },
            ),
            const SizedBox(height: 14),
            _buildCharactersSection(),
            const SizedBox(height: 24),
            _settingTile('Age Group', ageGroup, Icons.groups_2_outlined, () {
              _selectValue(
                title: 'Age Group',
                values: const [
                  'Adults (18+)',
                  'Teenagers (13–17)',
                  'Pre-teen (8–12)',
                  'Children (1–7)',
                ],
                current: ageGroup,
                onSelected: (value) => setState(() => ageGroup = value),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildCharactersSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Expanded(
              child: Text(
                'Main Characters',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            if (characters.isNotEmpty)
              Text(
                '${characters.length}',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFFFF6435),
                ),
              ),
          ],
        ),
        const SizedBox(height: 10),
        if (characters.isNotEmpty)
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: characters.asMap().entries.map((entry) {
              final index = entry.key;
              final character = entry.value;

              return Container(
                padding: const EdgeInsets.fromLTRB(12, 8, 7, 8),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF0EA),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: const Color(0xFFFFD8CB),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.person_outline_rounded,
                      size: 17,
                      color: Color(0xFFFF6435),
                    ),
                    const SizedBox(width: 6),
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 150),
                      child: Text(
                        character.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF333333),
                        ),
                      ),
                    ),
                    const SizedBox(width: 4),
                    InkWell(
                      onTap: () {
                        setState(() {
                          characters.removeAt(index);
                        });
                      },
                      borderRadius: BorderRadius.circular(20),
                      child: const Padding(
                        padding: EdgeInsets.all(3),
                        child: Icon(
                          Icons.close_rounded,
                          size: 16,
                          color: Color(0xFF777777),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        if (characters.isNotEmpty) const SizedBox(height: 10),
        InkWell(
          onTap: _showAddCharacterSheet,
          borderRadius: BorderRadius.circular(15),
          child: Container(
            height: 56,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: const Color(0xFFE7E7E7)),
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
                  'Add New Character',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
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
    final character = await showModalBottomSheet<StoryCharacter>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => const _AddCharacterSheet(),
    );

    if (!mounted || character == null) return;

    setState(() {
      characters.add(character);
    });
  }

  Widget _settingTile(
    String title,
    String value,
    IconData icon,
    VoidCallback onTap,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 11),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(15),
        child: Container(
          constraints: const BoxConstraints(minHeight: 62),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: const Color(0xFFE9E9E9)),
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
                child: Icon(icon, size: 19, color: const Color(0xFFFF6435)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
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
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) {
        const double itemHeight = 50.0;
        const double topSpace = 10.0;
        const double handleHeight = 5.0;
        const double titleTopSpace = 18.0;
        const double titleHeight = 28.0;
        const double titleBottomSpace = 8.0;
        const double bottomSpace = 8.0;

        final double naturalHeight =
            topSpace +
            handleHeight +
            titleTopSpace +
            titleHeight +
            titleBottomSpace +
            (values.length * itemHeight) +
            bottomSpace;

        final double maxHeight =
            MediaQuery.sizeOf(sheetContext).height * 0.50;

        final double sheetHeight =
            naturalHeight > maxHeight ? maxHeight : naturalHeight;

        final bool needsScrolling = naturalHeight > maxHeight;

        return SafeArea(
          child: SizedBox(
            height: sheetHeight,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: topSpace),

                Container(
                  width: 40,
                  height: handleHeight,
                  decoration: BoxDecoration(
                    color: const Color(0xFFDADADA),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),

                const SizedBox(height: titleTopSpace),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      title,
                      style: const TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF222222),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: titleBottomSpace),

                Flexible(
                  child: ListView.builder(
                    shrinkWrap: !needsScrolling,
                    physics: needsScrolling
                        ? const BouncingScrollPhysics()
                        : const NeverScrollableScrollPhysics(),
                    padding: const EdgeInsets.only(bottom: bottomSpace),
                    itemCount: values.length,
                    itemBuilder: (context, index) {
                      final value = values[index];
                      final isSelected = value == current;

                      return SizedBox(
                        height: itemHeight,
                        child: ListTile(
                          dense: true,
                          visualDensity: VisualDensity.compact,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                          ),
                          title: Text(
                            value,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: isSelected
                                  ? FontWeight.w600
                                  : FontWeight.w400,
                              color: const Color(0xFF222222),
                            ),
                          ),
                          trailing: isSelected
                              ? const Icon(
                                  Icons.check_circle_rounded,
                                  color: Color(0xFFFF6435),
                                  size: 21,
                                )
                              : null,
                          onTap: () {
                            onSelected(value);
                            Navigator.pop(sheetContext);
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
      },
    );
  }
}


class _AddCharacterSheet extends StatefulWidget {
  const _AddCharacterSheet();

  @override
  State<_AddCharacterSheet> createState() => _AddCharacterSheetState();
}

class _AddCharacterSheetState extends State<_AddCharacterSheet> {
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

    final character = StoryCharacter(
      name: _nameController.text.trim(),
      description: _descriptionController.text.trim(),
    );

    Navigator.of(context).pop(character);
  }

  @override
  Widget build(BuildContext context) {
    final keyboard = MediaQuery.viewInsetsOf(context).bottom;

    return AnimatedPadding(
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOut,
      padding: EdgeInsets.only(bottom: keyboard),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 18),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 5,
                decoration: BoxDecoration(
                  color: const Color(0xFFDADADA),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const SizedBox(height: 18),
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Add Main Character',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(height: 18),
              TextField(
                controller: _nameController,
                autofocus: true,
                textInputAction: TextInputAction.next,
                decoration: InputDecoration(
                  labelText: 'Character Name',
                  hintText: 'Enter character name',
                  filled: true,
                  fillColor: const Color(0xFFF8F8F8),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(
                      color: Color(0xFFE7E7E7),
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(
                      color: Color(0xFFE7E7E7),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(
                      color: Color(0xFFFF6435),
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
                decoration: InputDecoration(
                  labelText: 'Character Description',
                  hintText:
                      'Describe personality, role, goal, appearance, or important details',
                  alignLabelWithHint: true,
                  filled: true,
                  fillColor: const Color(0xFFF8F8F8),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(
                      color: Color(0xFFE7E7E7),
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(
                      color: Color(0xFFE7E7E7),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(
                      color: Color(0xFFFF6435),
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
                    backgroundColor: const Color(0xFFFF6435),
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: const Color(0xFFFFC7B5),
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
      ),
    );
  }
}

class StoryF {
  final int id;
  final String genre;
  final String title;
  final String prompt;
  final String length;
  final String creativityLevel;
  final String ageGroup;

  const StoryF({
    required this.id,
    required this.genre,
    required this.title,
    required this.prompt,
    required this.length,
    required this.creativityLevel,
    required this.ageGroup,
  });
}

class StoryGenre {
  final String name;
  final String image;

  const StoryGenre({
    required this.name,
    required this.image,
  });
}

class StoryAdvancedSettings {
  final String language;
  final String storyType;
  final String ending;
  final String narrative;
  final String pacing;
  final String focus;
  final String dialogue;
  final String emotionalDepth;
  final String ageGroup;

  const StoryAdvancedSettings({
    this.language = 'English',
    this.storyType = 'Fictional',
    this.ending = 'Happy Ending',
    this.narrative = 'First-person',
    this.pacing = 'Balanced',
    this.focus = 'Balanced',
    this.dialogue = 'Balanced',
    this.emotionalDepth = 'Moderate',
    this.ageGroup = 'Adults (18+)',
  });
}

class StoryCharacter {
  final String name;
  final String description;

  const StoryCharacter({
    required this.name,
    required this.description,
  });
}

class AdvancedStorySettingsResult {
  final StoryAdvancedSettings settings;
  final List<StoryCharacter> characters;

  const AdvancedStorySettingsResult({
    required this.settings,
    required this.characters,
  });
}

class StoryGenerationRequest {
  final String title;
  final String userPrompt;
  final String genre;
  final String length;
  final String creativityLevel;
  final StoryAdvancedSettings settings;
  final List<StoryCharacter> characters;
  final String generatedPrompt;

  const StoryGenerationRequest({
    required this.title,
    required this.userPrompt,
    required this.genre,
    required this.length,
    required this.creativityLevel,
    required this.settings,
    this.characters = const [],
    this.generatedPrompt = '',
  });

  StoryGenerationRequest copyWith({
    String? generatedPrompt,
  }) {
    return StoryGenerationRequest(
      title: title,
      userPrompt: userPrompt,
      genre: genre,
      length: length,
      creativityLevel: creativityLevel,
      settings: settings,
      characters: characters,
      generatedPrompt: generatedPrompt ?? this.generatedPrompt,
    );
  }
}
