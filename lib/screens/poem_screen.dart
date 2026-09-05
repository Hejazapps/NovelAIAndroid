import 'package:flutter/material.dart';

class PoemScreen extends StatefulWidget {
  const PoemScreen({super.key});

  @override
  State<PoemScreen> createState() => _PoemScreenState();
}

class _PoemScreenState extends State<PoemScreen> {
  final TextEditingController _promptController = TextEditingController();
  final TextEditingController _syllableController =
  TextEditingController(text: '2');

  String selectedPoemType = 'Default';
  String selectedTone = 'Funny';
  String selectedLanguage = 'English';
  String selectedLength = 'Short';
  String selectedCreativity = 'Low';

  // ============================================================
  // EXACT POEM TYPES FROM YOUR iOS PoemCell.swift
  // ============================================================

  final List<String> poemTypes = const [
    'Default',
    'Sonnet (Shakespearean)',
    'Sonnet (Petrarchan)',
    'Simple Poem',
    'Epic',
    'Blank Verse',
    'Narrative',
    'Inspirational',
    'Love Poem',
    'Tanka',
    'Seasonal',
    'Epic Long',
    'Villanelle',
    'Sestina',
    'Epitaph',
    'Couplet',
    'Rhymed Poetry',
    'Pantoum',
    'Prose Poem',
    'Abecedarian',
    'Spoken Word/Slam',
    'Rhymed Quatrains',
    'Rap Verse',
    'Didactic Cinquain',
    'Haiku',
    'Limerick',
    'Free Verse',
    'Acrostic',
    'Ballad',
    'Elegy',
    'Ode',
  ];

  // ============================================================
  // EXACT TONES FROM YOUR iOS PoemCell.swift
  // ============================================================

  final List<String> tones = const [
    'Funny',
    'Friendship',
    'Sad',
    'Romantic',
    'Inspirational',
    'Nostalgic',
    'Hopeful',
    'Dramatic',
    'Philosophical',
    'Melancholic',
    'Spiritual',
    'Confessional',
    'Classical',
    'Modernist',
    'Minimalist',
    'Surrealist',
    'Dark',
    'Whimsical',
    'Serious',
    'Wistful',
    'Joyful',
    'Playful',
    'Thoughtful',
    'Adventurous',
    'Uplifting',
    'Calm',
    'Contemporary',
    'Pastoral',
    'Beat',
    'Spoken-word',
  ];

  // English-only UI for now.
  // These are poem output languages.
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

  @override
  void dispose() {
    _promptController.dispose();
    _syllableController.dispose();
    super.dispose();
  }

  // ============================================================
  // MAIN UI
  // ============================================================

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
                  5,
                  20,
                  120,
                ),
                children: [
                  _buildPrompt(),

                  const SizedBox(height: 20),

                  _buildSyllables(),

                  const SizedBox(height: 18),

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

                  _buildDropdownTile(
                    title: 'Poem Type',
                    value: selectedPoemType,
                    icon: Icons.auto_stories_outlined,
                    onTap: () {
                      _showSelector(
                        title: 'Poem Type',
                        values: poemTypes,
                        selectedValue: selectedPoemType,
                        searchable: true,
                        onSelected: (value) {
                          setState(() {
                            selectedPoemType = value;
                          });
                        },
                      );
                    },
                  ),

                  const SizedBox(height: 12),

                  _buildSectionTitle('Poem Length'),

                  const SizedBox(height: 11),

                  _buildSegmentedControl(
                    values: const [
                      'Short',
                      'Medium',
                      'Long',
                    ],
                    selectedValue: selectedLength,
                    onSelected: (value) {
                      setState(() {
                        selectedLength = value;
                      });
                    },
                  ),

                  const SizedBox(height: 24),

                  _buildSectionTitle('Creativity'),

                  const SizedBox(height: 11),

                  _buildSegmentedControl(
                    values: const [
                      'Low',
                      'Medium',
                      'High',
                    ],
                    selectedValue: selectedCreativity,
                    onSelected: (value) {
                      setState(() {
                        selectedCreativity = value;
                      });
                    },
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
              'Create Poem',
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

  Widget _buildPrompt() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Describe Your Poem',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1B1B1B),
          ),
        ),

        const SizedBox(height: 11),

        Container(
          height: 175,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(17),
            border: Border.all(
              color: const Color(0xFFE7E7E7),
            ),
          ),
          child: Stack(
            children: [
              TextField(
                controller: _promptController,
                maxLines: null,
                expands: true,
                textAlignVertical: TextAlignVertical.top,
                onChanged: (_) {
                  setState(() {});
                },
                style: const TextStyle(
                  fontSize: 14,
                  height: 1.45,
                  color: Color(0xFF222222),
                ),
                decoration: const InputDecoration(
                  hintText: 'Describe your prompt here…',
                  hintStyle: TextStyle(
                    fontSize: 14,
                    color: Color(0xFFA0A0A0),
                  ),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.fromLTRB(
                    15,
                    15,
                    45,
                    15,
                  ),
                ),
              ),

              if (_promptController.text
                  .trim()
                  .isNotEmpty)
                Positioned(
                  top: 10,
                  right: 10,
                  child: InkWell(
                    onTap: () {
                      _promptController.clear();
                      setState(() {});
                    },
                    borderRadius:
                    BorderRadius.circular(20),
                    child: Container(
                      width: 30,
                      height: 30,
                      decoration: const BoxDecoration(
                        color: Color(0xFFF2F2F2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.close_rounded,
                        size: 17,
                        color: Color(0xFF777777),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  // ============================================================
  // SYLLABLES
  // ============================================================

  Widget _buildSyllables() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Enter Syllables',
          style: TextStyle(
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
            controller: _syllableController,
            keyboardType: TextInputType.number,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF222222),
            ),
            decoration: const InputDecoration(
              hintText: '2',
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(
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
  // DROPDOWN
  // ============================================================

  Widget _buildDropdownTile({
    required String title,
    required String value,
    required IconData icon,
    required VoidCallback onTap,
  }) {
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
                  borderRadius:
                  BorderRadius.circular(11),
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

  // ============================================================
  // SECTION TITLE
  // ============================================================

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w700,
        color: Color(0xFF1B1B1B),
      ),
    );
  }

  // ============================================================
  // SEGMENTED CONTROL
  // ============================================================

  Widget _buildSegmentedControl({
    required List<String> values,
    required String selectedValue,
    required ValueChanged<String> onSelected,
  }) {
    return Container(
      height: 48,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F1F1),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: values.map((value) {
          final selected =
              value == selectedValue;

          return Expanded(
            child: GestureDetector(
              onTap: () {
                onSelected(value);
              },
              child: AnimatedContainer(
                duration:
                const Duration(milliseconds: 180),
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
    );
  }

  // ============================================================
  // CREATE BUTTON
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
          onTap: _createPoem,
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

  // ============================================================
  // CREATE
  // ============================================================

  void _createPoem() {
    final prompt =
    _promptController.text.trim();

    if (prompt.isEmpty) {
      _showAlert(
        title: 'Missing Poem',
        message:
        'Please describe the poem you want to create.',
      );
      return;
    }

    final syllable =
    _syllableController.text.trim().isEmpty
        ? '2'
        : _syllableController.text.trim();

    debugPrint('================ POEM ================');
    debugPrint('Prompt: $prompt');
    debugPrint('Syllables: $syllable');
    debugPrint('Language: $selectedLanguage');
    debugPrint('Tone: $selectedTone');
    debugPrint('Type: $selectedPoemType');
    debugPrint('Length: $selectedLength');
    debugPrint('Creativity: $selectedCreativity');
    debugPrint('======================================');

    // API / poem generation will be added later.
  }

  // ============================================================
  // ALERT
  // ============================================================

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
                  color: Color(0xFFFF6435),
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
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(25),
        ),
      ),
      builder: (context) {
        return _PoemSelectorSheet(
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
// SELECTOR BOTTOM SHEET
// ============================================================

class _PoemSelectorSheet extends StatefulWidget {
  final String title;
  final List<String> values;
  final String selectedValue;
  final bool searchable;
  final ValueChanged<String> onSelected;

  const _PoemSelectorSheet({
    required this.title,
    required this.values,
    required this.selectedValue,
    required this.searchable,
    required this.onSelected,
  });

  @override
  State<_PoemSelectorSheet> createState() =>
      _PoemSelectorSheetState();
}

class _PoemSelectorSheetState
    extends State<_PoemSelectorSheet> {
  final TextEditingController _searchController =
  TextEditingController();

  String searchText = '';

  List<String> get filteredValues {
    if (searchText.trim().isEmpty) {
      return widget.values;
    }

    final search =
    searchText.trim().toLowerCase();

    return widget.values.where((value) {
      return value.toLowerCase().contains(search);
    }).toList();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final height =
        MediaQuery.sizeOf(context).height * 0.70;

    return SafeArea(
      child: SizedBox(
        height: height,
        child: Column(
          children: [
            const SizedBox(height: 10),

            Container(
              width: 42,
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
                12,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      widget.title,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight:
                        FontWeight.w700,
                        color: Color(0xFF1B1B1B),
                      ),
                    ),
                  ),

                  InkWell(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    borderRadius:
                    BorderRadius.circular(20),
                    child: const SizedBox(
                      width: 34,
                      height: 34,
                      child: Icon(
                        Icons.close_rounded,
                        size: 21,
                      ),
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
                    BorderRadius.circular(13),
                  ),
                  child: TextField(
                    controller: _searchController,
                    onChanged: (value) {
                      setState(() {
                        searchText = value;
                      });
                    },
                    decoration:
                    const InputDecoration(
                      hintText: 'Search',
                      prefixIcon: Icon(
                        Icons.search_rounded,
                        size: 20,
                      ),
                      border: InputBorder.none,
                    ),
                  ),
                ),
              ),

            Expanded(
              child: ListView.separated(
                physics:
                const BouncingScrollPhysics(),
                itemCount: filteredValues.length,
                separatorBuilder: (_, __) {
                  return const Divider(
                    height: 1,
                    indent: 20,
                    endIndent: 20,
                    color: Color(0xFFF0F0F0),
                  );
                },
                itemBuilder: (
                    context,
                    index,
                    ) {
                  final value =
                  filteredValues[index];

                  final selected =
                      value ==
                          widget.selectedValue;

                  return ListTile(
                    contentPadding:
                    const EdgeInsets.symmetric(
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
                      size: 21,
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