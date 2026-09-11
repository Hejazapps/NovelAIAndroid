import 'package:flutter/material.dart';

class ArticleScreen extends StatefulWidget {
  const ArticleScreen({super.key});

  @override
  State<ArticleScreen> createState() => _ArticleScreenState();
}

class _ArticleScreenState extends State<ArticleScreen> {
  bool _isDark(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark;

  Color _pageBg(BuildContext context) =>
      _isDark(context) ? const Color(0xFF160D26) : const Color(0xFFF9F9F9);

  Color _surface(BuildContext context) =>
      _isDark(context) ? const Color(0xFF21152F) : Colors.white;

  Color _surfaceAlt(BuildContext context) =>
      _isDark(context) ? const Color(0xFF2A1A3B) : const Color(0xFFF4F4F4);

  Color _border(BuildContext context) =>
      _isDark(context) ? const Color(0xFF49305F) : const Color(0xFFE0DCE8);

  Color _text(BuildContext context) =>
      _isDark(context) ? Colors.white : const Color(0xFF1B1B1B);

  Color _bodyText(BuildContext context) =>
      _isDark(context) ? const Color(0xFFE9E2F3) : const Color(0xFF222222);

  Color _muted(BuildContext context) =>
      _isDark(context) ? const Color(0xFFB9AEC8) : const Color(0xFF777777);

  Color _hint(BuildContext context) =>
      _isDark(context) ? const Color(0xFF81758F) : const Color(0xFFA0A0A0);

  Color _accent(BuildContext context) =>
      _isDark(context) ? const Color(0xFF9146E8) : const Color(0xFFFF9500);

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
    'Afrikaans',
    'Albanian',
    'Amharic',
    'Arabic',
    'Armenian',
    'Assamese',
    'Aymara',
    'Azerbaijani',
    'Bambara',
    'Basque',
    'Belarusian',
    'Bengali',
    'Bhojpuri',
    'Bosnian',
    'Bulgarian',
    'Burmese',
    'Catalan',
    'Cebuano',
    'Chichewa',
    'Chinese Simplified',
    'Chinese Traditional',
    'Corsican',
    'Croatian',
    'Czech',
    'Danish',
    'Dhivehi',
    'Dogri',
    'Dutch',
    'Esperanto',
    'Estonian',
    'Ewe',
    'Filipino',
    'Finnish',
    'French',
    'Frisian',
    'Galician',
    'Georgian',
    'German',
    'Greek',
    'Guarani',
    'Gujarati',
    'Haitian Creole',
    'Hausa',
    'Hawaiian',
    'Hebrew',
    'Hindi',
    'Hmong',
    'Hungarian',
    'Icelandic',
    'Igbo',
    'Ilocano',
    'Indonesian',
    'Irish',
    'Italian',
    'Japanese',
    'Javanese',
    'Kannada',
    'Kazakh',
    'Khmer',
    'Kinyarwanda',
    'Konkani',
    'Korean',
    'Kurdish',
    'Kurdish (Sorani)',
    'Kyrgyz',
    'Lao',
    'Latin',
    'Latvian',
    'Lingala',
    'Lithuanian',
    'Luganda',
    'Luxembourgish',
    'Macedonian',
    'Maithili',
    'Malagasy',
    'Malay',
    'Malayalam',
    'Maltese',
    'Maori',
    'Marathi',
    'Meiteilon (Manipuri)',
    'Mizo',
    'Mongolian',
    'Nepali',
    'Norwegian',
    'Norwegian Bokmål',
    'Odia (Oriya)',
    'Oromo',
    'Pashto',
    'Persian',
    'Polish',
    'Portuguese',
    'Portuguese (Brazil)',
    'Portuguese (Portugal)',
    'Punjabi',
    'Quechua',
    'Romanian',
    'Russian',
    'Samoan',
    'Sanskrit',
    'Scots Gaelic',
    'Sepedi',
    'Serbian',
    'Sesotho',
    'Shona',
    'Sindhi',
    'Sinhala',
    'Slovak',
    'Slovenian',
    'Somali',
    'Spanish',
    'Sundanese',
    'Swahili',
    'Swedish',
    'Tagalog',
    'Tajik',
    'Tamil',
    'Tatar',
    'Telugu',
    'Thai',
    'Tigrinya',
    'Tsonga',
    'Turkish',
    'Turkmen',
    'Twi',
    'Ukrainian',
    'Urdu',
    'Uyghur',
    'Uzbek',
    'Vietnamese',
    'Welsh',
    'Xhosa',
    'Yiddish',
    'Yoruba',
    'Zulu',
    'Acehnese',
    'Acholi',
    'Afar',
    'Alur',
    'Awadhi',
    'Balinese',
    'Baluchi',
    'Batak Karo',
    'Batak Simalungun',
    'Batak Toba',
    'Bemba',
    'Betawi',
    'Bikol',
    'Breton',
    'Buryat',
    'Cantonese',
    'Chamorro',
    'Chechen',
    'Chuukese',
    'Chuvash',
    'Crimean Tatar',
    'Dari',
    'Dinka',
    'Dombe',
    'Dzongkha',
    'Faroese',
    'Fijian',
    'Fon',
    'Friulian',
    'Ga',
    'Greenlandic',
    'Hakha Chin',
    'Herero',
    'Hiligaynon',
    'Iban',
    'Jingpo',
    'Kalaallisut',
    'Kanuri',
    'Kapampangan',
    'Khasi',
    'Kituba',
    'Kokborok',
    'Komering',
    'Krio',
    'Limburgish',
    'Lombard',
    'Madurese',
    'Makassar',
    'Marshallese',
    'Minangkabau',
    'Ndebele (South)',
    'NKo',
    'Occitan',
    'Ossetian',
    'Pangasinan',
    'Papiamento',
    'Romani',
    'Rundi',
    'Sango',
    'Santali',
    'Seychellois Creole',
    'Sicilian',
    'Silesian',
    'Swati',
    'Tahitian',
    'Tiv',
    'Tok Pisin',
    'Tshiluba',
    'Tswana',
    'Tulu',
    'Venda',
    'Waray',
    'Wolof',
    'Yakut',
    'Zapotec',
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
      backgroundColor: _pageBg(context),

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
    final isDark = _isDark(context);

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
              'Create Article',
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
              border: isDark
                  ? Border.all(color: const Color(0xFF49305F))
                  : null,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(
                    alpha: isDark ? 0.16 : 0.06,
                  ),
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
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: _text(context),
          ),
        ),

        const SizedBox(height: 4),

        Text(
          subtitle,
          style: TextStyle(
            fontSize: 12,
            height: 1.4,
            color: _muted(context),
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
        color: _surface(context),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _border(context),
        ),
      ),
      child: TextField(
        controller: controller,
        maxLines: null,
        expands: true,
        textAlignVertical: TextAlignVertical.top,
        style: TextStyle(
          fontSize: 14,
          height: 1.45,
          color: _bodyText(context),
        ),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(
            fontSize: 14,
            height: 1.4,
            color: _hint(context),
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
          color: _surface(context),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: _border(context),
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
                  fontWeight: FontWeight.w500,
                  color: _bodyText(context),
                ),
              ),
            ),

            Icon(
              Icons.keyboard_arrow_down_rounded,
              size: 22,
              color: _muted(context),
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
            Expanded(
              child: Text(
                'Sections',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: _text(context),
                ),
              ),
            ),

            Text(
              '$sectionValue',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: _accent(context),
              ),
            ),
          ],
        ),

        const SizedBox(height: 2),

        Text(
          'Choose how many main sections the article should contain.',
          style: TextStyle(
            fontSize: 12,
            height: 1.4,
            color: _muted(context),
          ),
        ),

        const SizedBox(height: 8),

        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            trackHeight: 4,
            activeTrackColor: _accent(context),
            inactiveTrackColor: _isDark(context) ? const Color(0xFF49305F) : const Color(0xFFD1D1D6),
            thumbColor: _isDark(context) ? const Color(0xFFEDE7F6) : Colors.white,
            overlayColor: _accent(context).withValues(
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
                        ? _accent(context)
                        : (_isDark(context)
                            ? const Color(0xFF9B90A8)
                            : const Color(0xFF8E8E93)),
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
          color: _pageBg(context),
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

  void _createArticle() {
    final articleIdea = _articleIdeaController.text.trim();
    final targetReader = _targetReaderController.text.trim();
    final keywords = _keywordsController.text.trim();

    if (articleIdea.isEmpty) {
      _showAlert(
        title: 'Missing Information',
        message: 'Please describe your article idea.',
      );
      return;
    }

    final prompt = _buildArticlePrompt(
      idea: articleIdea,
      targetReader: targetReader,
      keywords: keywords,
      sections: sectionValue,
    );

    debugPrint('========== ARTICLE ==========');
    debugPrint('Idea: $articleIdea');
    debugPrint('Target Reader: $targetReader');
    debugPrint('Sections: $sectionValue');
    debugPrint('Depth: $selectedDepth');
    debugPrint('Tone: $selectedTone');
    debugPrint('Point of View: $selectedPointOfView');
    debugPrint('Keywords: $keywords');
    debugPrint('Language: $selectedLanguage');
    debugPrint('========== GENERATED PROMPT ==========');
    debugPrint(prompt);
    debugPrint('======================================');

    // API / generation logic later.
    // Send `prompt` to your generation screen/API when connected.
  }

  String _buildArticlePrompt({
    required String idea,
    required String targetReader,
    required String keywords,
    required int sections,
  }) {
    final audience = targetReader.isEmpty
        ? 'Intelligent general readers'
        : targetReader;

    final keywordValue = keywords.isEmpty
        ? 'No required keywords'
        : keywords;

    late final String depthInstruction;

    switch (selectedDepth) {
      case 'Short':
        depthInstruction = """
Keep the article concise, focused, and useful.
Cover only the essential information.
Avoid padding, repetition, unnecessary background, and over-explanation.
""";
        break;
      case 'In-Depth':
        depthInstruction = """
Make the article genuinely comprehensive and substantial.
Develop important concepts with context, explanation, nuance, implications, and useful examples where appropriate.
Depth must come from meaningful substance, never repetition or filler.
""";
        break;
      default:
        depthInstruction = """
Use a balanced level of detail.
Explain important concepts clearly and thoroughly while keeping the article focused, readable, and efficient.
""";
    }

    return """
You are an elite professional article writer and editor with exceptional skill in clarity, structure, factual discipline, audience awareness, natural language, and publication-quality prose.

Write one original, polished, publication-ready article based on the brief below.

The article must feel deliberately written by a skilled human writer for this exact subject and audience. It must not sound like a generic AI template.

ARTICLE BRIEF

Topic or idea: $idea
Target reader: $audience
Main sections requested: $sections
Depth: $selectedDepth
Tone: $selectedTone
Point of view: $selectedPointOfView
Keywords: $keywordValue
Language: $selectedLanguage

PRIMARY OBJECTIVE

Identify the article's real central idea and purpose before writing.
Build the entire article around that central idea.
Every paragraph must contribute useful information, reasoning, context, explanation, or insight.
Remove filler, repetition, generic commentary, and sentences that do not advance the article.

AUDIENCE

Write specifically for $audience.
Adapt vocabulary, terminology, assumed knowledge, explanation depth, examples, pacing, and formality to this audience.
Never invent demographic traits, beliefs, experiences, education, profession, age, or background not provided by the user.

DEPTH

$depthInstruction

STRUCTURE

Organize the article into approximately $sections meaningful main sections.
Quality is more important than mechanically forcing the exact section count.
Every section must have a distinct purpose.
Arrange sections in a natural logical progression.
Do not repeat the same idea under different headings.
Do not divide one simple point into multiple artificial sections.

TITLE

Begin directly with one clear, natural, specific, publication-ready title.
Avoid formulaic AI titles, exaggerated claims, and generic clickbait.

INTRODUCTION

Write a concise and engaging introduction.
Establish the subject, context, or importance quickly.
Never begin with generic AI phrases such as:
"In today's fast-paced world"
"In the ever-evolving landscape"
"In this comprehensive guide"
"It is important to note"
"Nowadays, more than ever"

HEADINGS

Use short, informative headings when they improve readability.
Headings must be plain text.
Do not use #, ##, ###, #### or any Markdown heading symbols.
Do not use horizontal rules.
Do not use code blocks.

PARAGRAPH FORMATTING

Keep the visual layout compact and professional.
Write substantial, coherent paragraphs rather than many tiny paragraphs.
Keep closely related sentences together.
Do not place every sentence on a new line.
Do not add unnecessary blank lines.
Use one normal paragraph break only when the idea genuinely changes.
Never insert multiple consecutive blank lines.

LISTS

Prefer natural prose when prose is clearer.
Use bullet lists only when the information is naturally list-like and a list materially improves readability.

TABLES

Do not output Markdown tables.
Never output raw vertical-bar table syntax.
If information would normally be shown in a table, present it as clear prose or a concise list instead.

TONE

Write in a genuinely $selectedTone tone.
Express the tone through vocabulary, rhythm, pacing, directness, formality, warmth, restraint, and sentence structure.

POINT OF VIEW

Write primarily in $selectedPointOfView.
Maintain the selected perspective consistently.

KEYWORDS

Requested keywords: $keywordValue
If keywords were supplied, integrate them naturally and only where relevant.
Never keyword-stuff or damage readability merely to include them.

FACTUAL INTEGRITY

Never fabricate facts.
Do not invent statistics, percentages, prevalence rates, quotations, studies, research findings, experts, organizations, dates, historical claims, medical claims, scientific claims, URLs, references, or citations.
If a precise claim cannot be confidently supported, express it cautiously without false precision or omit it.
For medical, scientific, legal, financial, technical, or historical subjects, prioritize accuracy over sounding authoritative.
Never invent references merely to make the article appear researched.

LANGUAGE

Write the complete article in $selectedLanguage.
It must read as though originally composed by a fluent native writer in $selectedLanguage, not mechanically translated from English.
Use natural grammar, punctuation, vocabulary, idioms, sentence rhythm, honorifics, and culturally appropriate conventions.
Do not mix languages unnecessarily.
Preserve proper nouns and established technical terms only where appropriate.

NATURAL HUMAN WRITING

Vary sentence length naturally.
Use smooth transitions without overusing transition phrases.
Avoid repetitive sentence openings.
Avoid excessive rhetorical questions.
Avoid excessive em dashes.
Avoid repeated three-part lists.
Avoid robotic mini-conclusions after every section.
Avoid generic motivational filler and corporate language.
Avoid cliché AI expressions such as "delve into", "navigate the landscape", "unlock the power", "game-changer", and "a testament to" unless genuinely natural and necessary.

CONCLUSION

End with a purposeful final paragraph or section.
Reinforce the central idea without mechanically repeating every previous section.
Leave the reader with a useful final understanding, implication, recommendation, or perspective appropriate to the topic.

FINAL SILENT CHECK

Before responding, silently verify:
- the article directly addresses the user's topic
- it is appropriate for $audience
- depth matches $selectedDepth
- tone matches $selectedTone
- point of view matches $selectedPointOfView
- there are approximately $sections useful sections
- no section unnecessarily repeats another
- keywords are natural
- no unsupported facts or fake citations were invented
- paragraphs are compact and properly developed
- there are no excessive blank lines
- there are no Markdown heading symbols
- there are no Markdown tables
- the entire article is in $selectedLanguage
- the result feels natural, useful, polished, and publication-ready

STRICT OUTPUT RULES

Output only the finished article.
Start directly with the article title.
Do not say "Here is your article".
Do not say "Generated Article".
Do not say "Sure".
Do not explain your process.
Do not include notes, analysis, alternatives, or word counts.
Do not use Markdown heading symbols.
Do not use Markdown tables.
Do not add anything before or after the finished article.
""";
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

  void _showSelector({
    required String title,
    required List<String> values,
    required String selectedValue,
    required ValueChanged<String> onSelected,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: _surface(context),
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
  final ValueChanged<String> onSelected;

  const _ArticleSelectorSheet({
    required this.title,
    required this.values,
    required this.selectedValue,
    required this.onSelected,
  });

  @override
  State<_ArticleSelectorSheet> createState() => _ArticleSelectorSheetState();
}

class _ArticleSelectorSheetState extends State<_ArticleSelectorSheet> {
  bool _isDark(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark;

  Color _surface(BuildContext context) =>
      _isDark(context) ? const Color(0xFF21152F) : Colors.white;

  Color _surfaceAlt(BuildContext context) =>
      _isDark(context) ? const Color(0xFF2A1A3B) : const Color(0xFFF4F4F4);

  Color _text(BuildContext context) =>
      _isDark(context) ? Colors.white : const Color(0xFF222222);

  Color _muted(BuildContext context) =>
      _isDark(context) ? const Color(0xFFB9AEC8) : const Color(0xFF888888);

  Color _accent(BuildContext context) =>
      _isDark(context) ? const Color(0xFF9146E8) : const Color(0xFFFF9500);

  final TextEditingController _searchController = TextEditingController();
  String search = '';

  bool get _showSearch => widget.values.length > 20;

  List<String> get filtered {
    if (search.trim().isEmpty) return widget.values;
    final query = search.trim().toLowerCase();
    return widget.values
        .where((value) => value.toLowerCase().contains(query))
        .toList();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  double _sheetHeight(BuildContext context) {
    final screenHeight = MediaQuery.sizeOf(context).height;
    final maxHeight = screenHeight * 0.50;

    // Large searchable lists (such as Language) use at most half the screen.
    if (_showSearch) {
      return maxHeight;
    }

    // Small lists stay compact, but can never exceed half the screen.
    const fixedContent = 95.0;
    const rowHeight = 56.0;
    final naturalHeight = fixedContent + (widget.values.length * rowHeight);

    return naturalHeight.clamp(190.0, maxHeight).toDouble();
  }

  @override
  Widget build(BuildContext context) {
    final values = filtered;

    return SafeArea(
      child: SizedBox(
        height: _sheetHeight(context),
        child: Column(
          children: [
            const SizedBox(height: 10),
            Container(
              width: 42,
              height: 5,
              decoration: BoxDecoration(
                color: _isDark(context) ? const Color(0xFF6F5A80) : const Color(0xFFDADADA),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 14, 12, 10),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      widget.title,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: _text(context),
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close_rounded),
                  ),
                ],
              ),
            ),
            if (_showSearch)
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                child: Container(
                  height: 46,
                  decoration: BoxDecoration(
                    color: _surfaceAlt(context),
                    borderRadius: BorderRadius.circular(13),
                  ),
                  child: TextField(
                    controller: _searchController,
                    onChanged: (value) => setState(() => search = value),
                    decoration: InputDecoration(
                      hintText: 'Search ${widget.title}',
                      prefixIcon: const Icon(Icons.search_rounded),
                      suffixIcon: search.isNotEmpty
                          ? IconButton(
                              onPressed: () {
                                _searchController.clear();
                                setState(() => search = '');
                              },
                              icon: const Icon(Icons.close_rounded),
                            )
                          : null,
                      border: InputBorder.none,
                    ),
                  ),
                ),
              ),
            Expanded(
              child: values.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.search_off_rounded,
                            size: 34,
                            color: _muted(context),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'No results found',
                            style: TextStyle(
                              fontSize: 14,
                              color: _muted(context),
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.separated(
                      physics: widget.values.length > 4
                          ? const BouncingScrollPhysics()
                          : const NeverScrollableScrollPhysics(),
                      itemCount: values.length,
                      separatorBuilder: (_, __) => Divider(
                        height: 1,
                        indent: 20,
                        endIndent: 20,
                        color: _isDark(context)
                            ? const Color(0xFF49305F)
                            : const Color(0xFFE5E5E5),
                      ),
                      itemBuilder: (context, index) {
                        final value = values[index];
                        final selected = value == widget.selectedValue;

                        return SizedBox(
                          height: 56,
                          child: ListTile(
                            contentPadding:
                                const EdgeInsets.symmetric(horizontal: 20),
                            title: Text(
                              value,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: selected
                                    ? FontWeight.w700
                                    : FontWeight.w500,
                                color: selected
                                    ? _accent(context)
                                    : _text(context),
                              ),
                            ),
                            trailing: selected
                                ? Icon(
                                    Icons.check_circle_rounded,
                                    color: _accent(context),
                                  )
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
