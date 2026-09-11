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
              'Create Poem',
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
  // PROMPT
  // ============================================================

  Widget _buildPrompt() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Describe Your Poem',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: _text(context),
          ),
        ),

        const SizedBox(height: 11),

        Container(
          height: 175,
          decoration: BoxDecoration(
            color: _surface(context),
            borderRadius: BorderRadius.circular(17),
            border: Border.all(
              color: _border(context),
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
                style: TextStyle(
                  fontSize: 14,
                  height: 1.45,
                  color: _bodyText(context),
                ),
                decoration: InputDecoration(
                  hintText: 'Describe your prompt here…',
                  hintStyle: TextStyle(
                    fontSize: 14,
                    color: _hint(context),
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.fromLTRB(
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
                      decoration: BoxDecoration(
                        color: _surfaceAlt(context),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.close_rounded,
                        size: 17,
                        color: _muted(context),
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
        Text(
          'Enter Syllables',
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
            controller: _syllableController,
            keyboardType: TextInputType.number,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: _bodyText(context),
            ),
            decoration: InputDecoration(
              hintText: '2',
              hintStyle: TextStyle(color: _hint(context)),
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
                  borderRadius:
                  BorderRadius.circular(11),
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
                  crossAxisAlignment:
                  CrossAxisAlignment.start,
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
  // SECTION TITLE
  // ============================================================

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w700,
        color: _text(context),
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
          final selected = value == selectedValue;

          return Expanded(
            child: GestureDetector(
              onTap: () {
                onSelected(value);
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
          color: _pageBackground(context),
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
              color: _accent(context),
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

  String get _lineCount {
    switch (selectedLength) {
      case 'Short':
        return '8–12';
      case 'Medium':
        return '16–24';
      case 'Long':
        return '32–48';
      default:
        return '8–12';
    }
  }

  void _createPoem() {
    final prompt = _promptController.text.trim();

    if (prompt.isEmpty) {
      _showAlert(
        title: 'Missing Poem',
        message: 'Please describe the poem you want to create.',
      );
      return;
    }

    final syllable = _syllableController.text.trim().isEmpty
        ? '2'
        : _syllableController.text.trim();

    final generatedPrompt = _buildPoemPrompt(
      poemText: prompt,
      syllable: syllable,
    );

    debugPrint('================ POEM ================');
    debugPrint('Prompt: $prompt');
    debugPrint('Syllables: $syllable');
    debugPrint('Language: $selectedLanguage');
    debugPrint('Tone: $selectedTone');
    debugPrint('Type: $selectedPoemType');
    debugPrint('Length: $selectedLength');
    debugPrint('Creativity: $selectedCreativity');
    debugPrint('========== GENERATED PROMPT ==========');
    debugPrint(generatedPrompt);
    debugPrint('======================================');

    // API / poem generation connection can be added here later.
  }

  String _buildPoemPrompt({
    required String poemText,
    required String syllable,
  }) {
    return """
You are an elite, award-winning poet with exceptional emotional intelligence,
artistic discipline, cultural sensitivity, musical instinct, and linguistic precision.

Write one original poem based on the user's specifications.

The poem must feel intentionally crafted by a gifted human poet,
not like generic AI poetry.

POEM SPECIFICATIONS

Topic / Prompt:
$poemText

Language:
$selectedLanguage

Mood / Emotional Tone:
$selectedTone

Poem Type:
$selectedPoemType

Creativity Level:
$selectedCreativity

Language Sophistication:
$syllable/10

Required Length:
$_lineCount lines

PRIMARY GOAL

Understand the emotional center of the user's prompt before writing.

Do not merely restate the topic.

Find a specific perspective, image, tension, memory, question,
observation, or emotional movement that gives the poem a reason to exist.

Make the poem feel discovered rather than assembled.

FORM

Strictly respect the selected poem type:
$selectedPoemType

If the type has formal conventions, follow them accurately.

This includes, where applicable:
- stanza structure
- rhyme scheme
- meter
- syllable count
- repetition pattern
- refrain
- line length
- narrative expectations
- traditional structural rules

If Poem Type is "Default", write modern free verse unless another form
is clearly more suitable to the user's topic and mood.

Do not force rhyme when the selected form does not require it.
Do not sacrifice natural language merely to satisfy rhyme.

EMOTIONAL ARC

The poem should move.

Even a short poem should not remain emotionally static from first line
to last line.

The emotional progression may deepen, turn, reveal, question, resist,
accept, remember, contrast, or transform.

Avoid repeating the same feeling in slightly different words.

IMAGERY

Favor concrete, sensory, specific imagery.

Use details that can be seen, heard, touched, smelled, tasted,
remembered, or physically felt.

Avoid relying on vague abstractions such as:
"pain"
"love"
"sadness"
"destiny"
"broken heart"
"darkness"
unless they are made specific through fresh imagery.

SHOW, DO NOT OVER-EXPLAIN

Let emotion emerge through:
- images
- gestures
- objects
- physical sensations
- remembered scenes
- silence
- contrast
- action
- precise observation

Do not explain an emotion after the image has already communicated it.

METAPHOR QUALITY

Use metaphor only when it adds insight.

Avoid decorative metaphors that exist only to sound poetic.

When possible, develop a small number of strong images rather than
introducing a new metaphor in every line.

Keep extended metaphors internally consistent.
Avoid mixed metaphors.

ORIGINALITY

Avoid stock poetic language and overused images.

Especially avoid automatically using:
- shattered glass
- storms inside the heart
- oceans of tears
- endless darkness
- scars that never heal
- flames of love
- wings of freedom
- stars as destiny
- moonlight as generic romance
- silence screaming
- heart as a battlefield

These images are allowed only if transformed into something specific,
surprising, and necessary to the poem.

Do not use cliché phrases simply because they sound poetic.

OPENING

Begin with a line that creates immediate presence.

Prefer:
- a vivid image
- a physical action
- a surprising observation
- a sensory detail
- a precise emotional situation
- a fresh statement

Avoid generic openings such as:
"In the depths of..."
"In a world where..."
"Under the moonlight..."
"My heart..."
unless uniquely justified by the poem.

LINE QUALITY

Every line must earn its place.

Avoid filler lines.

Avoid repeating the same idea only to satisfy the requested line count.

Break lines intentionally.

A line break should create rhythm, emphasis, tension, contrast,
double meaning, breath, or movement.

Do not break prose into arbitrary short lines and call it poetry.

RHYTHM AND SOUND

Pay attention to:
- cadence
- internal rhythm
- consonance
- assonance
- repetition
- pause
- breath
- sonic texture

Sound should support meaning.

Do not overuse alliteration or rhyme.

VOICE

If the poem contains a speaker, give that speaker a distinctive voice.

Avoid vague universal statements when a more specific human voice
would be stronger.

The voice may be intimate, restrained, raw, playful, formal,
conversational, lyrical, bitter, spiritual, reflective, or dramatic,
depending on the selected mood and type.

CREATIVITY CONTROL

Creativity Level:
$selectedCreativity

Low:
Use clear, direct, emotionally sincere language.
Keep imagery accessible.
Use minimal abstraction and limited metaphor.

Medium:
Use expressive imagery, layered meaning, subtle symbolism,
and creative but natural phrasing.

High:
Use bold imagery, surprising associations, original symbolism,
tonal risk, structural inventiveness, and deeper ambiguity where appropriate.

High creativity must still remain coherent and emotionally meaningful.

Do not become random, obscure, or difficult merely to appear artistic.

LANGUAGE SOPHISTICATION

Sophistication Level:
$syllable/10

Lower values:
- simple vocabulary
- direct syntax
- shorter phrases
- immediate emotional clarity

Middle values:
- richer but accessible vocabulary
- varied sentence structure
- stronger imagery
- nuanced emotional language

Higher values:
- precise vocabulary
- sophisticated rhythm
- layered syntax
- subtle imagery
- nuanced metaphor
- greater tonal complexity

Sophisticated does NOT mean unnecessarily difficult.

LANGUAGE QUALITY

Write the complete poem in:
$selectedLanguage

The poem should sound as though it was originally written in that language.

Avoid literal translation from English.

Use culturally and linguistically natural:
- imagery
- syntax
- rhythm
- idiom
- emotional expression
- punctuation

If writing in Bangla or another non-English language,
prioritize native poetic fluency over English-style phrasing.

REPETITION CONTROL

Avoid repeating:
- the same metaphor
- the same adjective
- the same emotional statement
- the same sentence opening
- the same image with slightly different words
- the same ending word unnecessarily
- generic poetic filler

Repetition is allowed when it is structurally or emotionally intentional.

SENTIMENTALITY CONTROL

Earn emotional intensity.

Do not tell the reader what to feel.

Avoid melodrama, emotional overstatement, and excessive exclamation.

Restraint is often more powerful than exaggeration.

ENDING

The final line should feel earned.

It may:
- reveal
- turn
- deepen
- echo an earlier image
- leave a resonant ambiguity
- create emotional closure
- create a quiet aftershock

Avoid generic endings such as:
"and I will never be the same"
"forever in my heart"
"this is the end"
"I finally understand"
unless the specific poem genuinely earns them.

Do not explain the poem's meaning at the end.

LENGTH

The final poem must contain between $_lineCount lines.

Respect the requested line range.

Do not pad the poem to reach the target.

If the form naturally requires a specific count, prioritize the formal rule.

FINAL SILENT QUALITY CHECK

Before responding, silently verify:
- the poem has a clear emotional center
- the selected poem type is respected
- the mood is genuinely present
- the imagery is specific rather than generic
- no major cliché dominates the poem
- metaphors are coherent
- every line contributes
- repetition is intentional
- the ending is stronger than a generic summary
- the language sounds native in $selectedLanguage
- the requested line count is respected

Do not reveal this check.

STRICT OUTPUT RULES

Output ONLY the poem itself.

Never output:
- a title
- headings
- labels
- explanations
- notes
- analysis
- markdown
- bullet points
- numbering
- commentary before the poem
- commentary after the poem

Do not write:
"Here is your poem"
"Generated Poem"
"Sure, here you go"

Produce exactly one polished final poem.
""";
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
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final maxHeight = MediaQuery.sizeOf(context).height * 0.50;
    final showSearch = widget.searchable && widget.values.length > 10;
    final items = filteredValues;

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
                        searchText = value;
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
                        size: 20,
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
                                    size: 21,
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