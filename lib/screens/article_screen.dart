import 'package:flutter/material.dart';

class ArticleScreen extends StatefulWidget {
  const ArticleScreen({super.key});

  @override
  State<ArticleScreen> createState() => _ArticleScreenState();
}

class _ArticleScreenState extends State<ArticleScreen> {
  final TextEditingController _articleIdeaController =
  TextEditingController();

  final TextEditingController _targetReaderController =
  TextEditingController();

  final TextEditingController _keywordsController =
  TextEditingController();

  String selectedDepth = 'Standard';
  String selectedTone = 'Professional';
  String selectedPointOfView = 'Third Person';
  String selectedLanguage = 'English';

  int sectionValue = 3;

  final List<String> depthOptions = const [
    'Short',
    'Standard',
    'In-Depth',
  ];

  final List<String> toneOptions = const [
    'Professional',
    'Informative',
    'Conversational',
    'Friendly',
    'Formal',
    'Educational',
    'Persuasive',
    'Inspirational',
    'Analytical',
    'Authoritative',
    'Casual',
    'Humorous',
    'Empathetic',
    'Critical',
    'Objective',
  ];

  final List<String> pointOfViewOptions = const [
    'First Person',
    'Second Person',
    'Third Person',
  ];

  final List<String> languageOptions = const [
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
    _articleIdeaController.dispose();
    _targetReaderController.dispose();
    _keywordsController.dispose();
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
                  16,
                  6,
                  16,
                  120,
                ),
                children: [
                  _buildSection(
                    title: 'Article Idea',
                    subtitle:
                    'Describe what you want the article to be about. You can include the main topic, angle, or important points.',
                    child: _buildLargeTextField(
                      controller: _articleIdeaController,
                      hint:
                      'Describe the topic, idea, or key points you want the article to cover.',
                      height: 110,
                    ),
                  ),

                  const SizedBox(height: 24),

                  _buildSection(
                    title: 'Target Reader',
                    subtitle:
                    'Tell us who the article is written for so the language and examples feel relevant.',
                    child: _buildLargeTextField(
                      controller: _targetReaderController,
                      hint:
                      'Example: Students, startup founders, parents, developers...',
                      height: 90,
                    ),
                  ),

                  const SizedBox(height: 24),

                  _buildSectionsSlider(),

                  const SizedBox(height: 24),

                  _buildSection(
                    title: 'Depth',
                    subtitle:
                    'Choose how detailed and comprehensive the article should be.',
                    child: _buildDropdown(
                      value: selectedDepth,
                      onTap: () {
                        _showSelector(
                          title: 'Depth',
                          values: depthOptions,
                          selectedValue: selectedDepth,
                          onSelected: (value) {
                            setState(() {
                              selectedDepth = value;
                            });
                          },
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 24),

                  _buildSection(
                    title: 'Tone',
                    subtitle:
                    'Choose the overall writing style and personality of the article.',
                    child: _buildDropdown(
                      value: selectedTone,
                      onTap: () {
                        _showSelector(
                          title: 'Tone',
                          values: toneOptions,
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
                  ),

                  const SizedBox(height: 24),

                  _buildSection(
                    title: 'Point of View',
                    subtitle:
                    'Choose the perspective from which the article should be written.',
                    child: _buildDropdown(
                      value: selectedPointOfView,
                      onTap: () {
                        _showSelector(
                          title: 'Point of View',
                          values: pointOfViewOptions,
                          selectedValue: selectedPointOfView,
                          onSelected: (value) {
                            setState(() {
                              selectedPointOfView = value;
                            });
                          },
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 24),

                  _buildSection(
                    title: 'Keywords',
                    subtitle:
                    'Add important words or phrases you want naturally included in the article.',
                    child: _buildLargeTextField(
                      controller: _keywordsController,
                      hint:
                      'Example: artificial intelligence, productivity, future technology',
                      height: 90,
                    ),
                  ),

                  const SizedBox(height: 24),

                  _buildSection(
                    title: 'Output Language',
                    subtitle:
                    'Select the language in which the article should be written.',
                    child: _buildDropdown(
                      value: selectedLanguage,
                      onTap: () {
                        _showSelector(
                          title: 'Output Language',
                          values: languageOptions,
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
                  ),
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
              'Create Article',
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
              color: Color(0xFFFF9500),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required String subtitle,
    required Widget child,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1B1B1B),
          ),
        ),

        const SizedBox(height: 4),

        Text(
          subtitle,
          style: const TextStyle(
            fontSize: 12,
            height: 1.4,
            color: Color(0xFF777777),
          ),
        ),

        const SizedBox(height: 10),

        child,
      ],
    );
  }

  Widget _buildLargeTextField({
    required TextEditingController controller,
    required String hint,
    required double height,
  }) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFE0DCE8),
        ),
      ),
      child: TextField(
        controller: controller,
        maxLines: null,
        expands: true,
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
          contentPadding: const EdgeInsets.fromLTRB(
            16,
            15,
            16,
            15,
          ),
        ),
      ),
    );
  }

  Widget _buildDropdown({
    required String value,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        height: 56,
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: const Color(0xFFE0DCE8),
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF222222),
                ),
              ),
            ),

            const Icon(
              Icons.keyboard_arrow_down_rounded,
              size: 22,
              color: Color(0xFF555555),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionsSlider() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Expanded(
              child: Text(
                'Sections',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1B1B1B),
                ),
              ),
            ),

            Text(
              '$sectionValue',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFFFF9500),
              ),
            ),
          ],
        ),

        const SizedBox(height: 2),

        const Text(
          'Choose how many main sections the article should contain.',
          style: TextStyle(
            fontSize: 12,
            height: 1.4,
            color: Color(0xFF777777),
          ),
        ),

        const SizedBox(height: 8),

        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            trackHeight: 4,
            activeTrackColor: const Color(0xFFFF9500),
            inactiveTrackColor: const Color(0xFFD1D1D6),
            thumbColor: Colors.white,
            overlayColor: const Color(0xFFFF9500).withValues(
              alpha: 0.12,
            ),
            thumbShape: const RoundSliderThumbShape(
              enabledThumbRadius: 12,
            ),
          ),
          child: Slider(
            value: sectionValue.toDouble(),
            min: 1,
            max: 10,
            divisions: 9,
            onChanged: (value) {
              setState(() {
                sectionValue = value.round();
              });

              // Free user limit > 3 will be connected later.
            },
          ),
        ),

        Row(
          children: List.generate(
            10,
                (index) {
              final number = index + 1;
              final selected = number == sectionValue;

              return Expanded(
                child: Text(
                  '$number',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: selected
                        ? FontWeight.w600
                        : FontWeight.w400,
                    color: selected
                        ? const Color(0xFFFF9500)
                        : const Color(0xFF8E8E93),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

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
        child: GestureDetector(
          onTap: _createArticle,
          child: Container(
            height: 54,
            decoration: BoxDecoration(
              color: const Color(0xFFFF9500),
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

  void _createArticle() {
    final articleIdea =
    _articleIdeaController.text.trim();

    final targetReader =
    _targetReaderController.text.trim();

    final keywords =
    _keywordsController.text.trim();

    if (articleIdea.isEmpty) {
      _showAlert(
        title: 'Missing Information',
        message: 'Please describe your article idea.',
      );
      return;
    }

    debugPrint('========== ARTICLE ==========');
    debugPrint('Idea: $articleIdea');
    debugPrint('Target Reader: $targetReader');
    debugPrint('Sections: $sectionValue');
    debugPrint('Depth: $selectedDepth');
    debugPrint('Tone: $selectedTone');
    debugPrint('Point of View: $selectedPointOfView');
    debugPrint('Keywords: $keywords');
    debugPrint('Language: $selectedLanguage');
    debugPrint('=============================');

    // API / generation logic later.
  }

  void _showAlert({
    required String title,
    required String message,
  }) {
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
                  color: Color(0xFFFF9500),
                ),
              ),
            ),
          ],
        );
      },
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
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(25),
        ),
      ),
      builder: (context) {
        return _ArticleSelectorSheet(
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

class _ArticleSelectorSheet extends StatefulWidget {
  final String title;
  final List<String> values;
  final String selectedValue;
  final bool searchable;
  final ValueChanged<String> onSelected;

  const _ArticleSelectorSheet({
    required this.title,
    required this.values,
    required this.selectedValue,
    required this.searchable,
    required this.onSelected,
  });

  @override
  State<_ArticleSelectorSheet> createState() =>
      _ArticleSelectorSheetState();
}

class _ArticleSelectorSheetState
    extends State<_ArticleSelectorSheet> {
  final TextEditingController _searchController =
  TextEditingController();

  String search = '';

  List<String> get filtered {
    if (search.trim().isEmpty) {
      return widget.values;
    }

    final query = search.trim().toLowerCase();

    return widget.values.where((value) {
      return value.toLowerCase().contains(query);
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
        height: MediaQuery.sizeOf(context).height * 0.70,
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

            Padding(
              padding: const EdgeInsets.fromLTRB(
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
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),

                  IconButton(
                    onPressed: () {
                      Navigator.pop(context);
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
                padding: const EdgeInsets.fromLTRB(
                  20,
                  0,
                  20,
                  12,
                ),
                child: Container(
                  height: 46,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF4F4F4),
                    borderRadius: BorderRadius.circular(13),
                  ),
                  child: TextField(
                    controller: _searchController,
                    onChanged: (value) {
                      setState(() {
                        search = value;
                      });
                    },
                    decoration: const InputDecoration(
                      hintText: 'Search',
                      prefixIcon: Icon(
                        Icons.search_rounded,
                      ),
                      border: InputBorder.none,
                    ),
                  ),
                ),
              ),

            Expanded(
              child: ListView.separated(
                physics: const BouncingScrollPhysics(),
                itemCount: filtered.length,
                separatorBuilder: (_, __) {
                  return const Divider(
                    height: 1,
                    indent: 20,
                    endIndent: 20,
                  );
                },
                itemBuilder: (context, index) {
                  final value = filtered[index];
                  final selected =
                      value == widget.selectedValue;

                  return ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 20,
                    ),
                    title: Text(
                      value,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: selected
                            ? FontWeight.w700
                            : FontWeight.w500,
                        color: selected
                            ? const Color(0xFFFF9500)
                            : const Color(0xFF222222),
                      ),
                    ),
                    trailing: selected
                        ? const Icon(
                      Icons.check_circle_rounded,
                      color: Color(0xFFFF9500),
                    )
                        : null,
                    onTap: () {
                      widget.onSelected(value);
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