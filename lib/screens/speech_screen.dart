import 'package:flutter/material.dart';

class SpeechScreen extends StatefulWidget {
  const SpeechScreen({super.key});

  @override
  State<SpeechScreen> createState() => _SpeechScreenState();
}

class _SpeechScreenState extends State<SpeechScreen> {
  final _topicController = TextEditingController();
  final _speakerController = TextEditingController();
  final _audienceController = TextEditingController();
  final _coreIdeaController = TextEditingController();
  final _responseController = TextEditingController();

  String _selectedEvent = 'Wedding';
  String _selectedTone = 'Inspirational';
  String _selectedInclude = 'Strong introduction and memorable ending';
  String _selectedLanguage = 'English';

  double _duration = 3;

  final List<String> _eventOptions = const [
    'Wedding',
    'Graduation',
    'Birthday',
    'Award Ceremony',
    'Business Meeting',
    'Conference',
    'Presentation',
    'Retirement',
    'Farewell',
    'Funeral',
    'Political Event',
    'Religious Event',
    'School Event',
    'Community Event',
    'Product Launch',
    'Charity Event',
    'Anniversary',
    'Other',
  ];

  final List<String> _toneOptions = const [
    'Inspirational',
    'Motivational',
    'Professional',
    'Formal',
    'Friendly',
    'Emotional',
    'Persuasive',
    'Humorous',
    'Confident',
    'Warm',
    'Celebratory',
    'Grateful',
    'Serious',
    'Educational',
    'Conversational',
  ];

  final List<String> _includeOptions = const [
    'Strong introduction and memorable ending',
    'Attention-grabbing introduction',
    'Memorable closing statement',
    'Short personal experience',
    'Meaningful quotation',
    'Light humor',
    'Supporting facts',
    'Question for the audience',
    'Emotional moment',
    'Practical takeaways',
    'No additional element',
  ];

  final List<String> _languageOptions = const [
    'English',
    'Arabic',
    'Bengali',
    'Chinese (Simplified)',
    'Chinese (Traditional)',
    'Dutch',
    'French',
    'German',
    'Greek',
    'Hindi',
    'Indonesian',
    'Italian',
    'Japanese',
    'Korean',
    'Malay',
    'Polish',
    'Portuguese',
    'Romanian',
    'Russian',
    'Spanish',
    'Swedish',
    'Thai',
    'Turkish',
    'Ukrainian',
    'Vietnamese',
  ];

  @override
  void dispose() {
    _topicController.dispose();
    _speakerController.dispose();
    _audienceController.dispose();
    _coreIdeaController.dispose();
    _responseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final background = isDark
        ? const Color(0xFF160D26)
        : const Color(0xFFF8F7FA);

    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: background,
        foregroundColor: theme.colorScheme.onSurface,
        leading: IconButton(
          onPressed: () => Navigator.maybePop(context),
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
        ),
        title: const Text(
          'Create Speech',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        top: false,
        child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: ListView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            padding: const EdgeInsets.fromLTRB(16, 18, 16, 36),
            children: [
              _section(
                context,
                title: 'Speech Topic',
                child: _textField(
                  context,
                  controller: _topicController,
                  hint: 'Give your speech a clear title',
                ),
              ),
              const SizedBox(height: 24),
              _section(
                context,
                title: 'Presented By',
                child: _textField(
                  context,
                  controller: _speakerController,
                  hint: 'Enter the speaker’s name or position',
                ),
              ),
              const SizedBox(height: 24),
              _section(
                context,
                title: 'Event Type',
                subtitle: 'Select where or why this speech will be delivered.',
                child: _dropdown(
                  context,
                  value: _selectedEvent,
                  items: _eventOptions,
                  onChanged: (value) {
                    if (value == null) return;
                    setState(() => _selectedEvent = value);
                  },
                ),
              ),
              const SizedBox(height: 24),
              _section(
                context,
                title: 'Listener Profile',
                subtitle:
                    'Tell us who will hear the speech so the content feels relevant.',
                child: _textArea(
                  context,
                  controller: _audienceController,
                  hint: 'Example: Students, colleagues, invited guests...',
                  minLines: 4,
                ),
              ),
              const SizedBox(height: 24),
              _section(
                context,
                title: 'Core Idea',
                subtitle:
                    'What is the most important thought listeners should remember?',
                child: _textArea(
                  context,
                  controller: _coreIdeaController,
                  hint: 'Describe the central idea you want to communicate',
                  minLines: 4,
                ),
              ),
              const SizedBox(height: 24),
              _durationSection(context),
              const SizedBox(height: 24),
              _section(
                context,
                title: 'Delivery Style',
                subtitle: 'Choose the overall mood and personality of the speech.',
                child: _dropdown(
                  context,
                  value: _selectedTone,
                  items: _toneOptions,
                  onChanged: (value) {
                    if (value == null) return;
                    setState(() => _selectedTone = value);
                  },
                ),
              ),
              const SizedBox(height: 24),
              _section(
                context,
                title: 'Desired Response',
                subtitle:
                    'Explain how you want the audience to respond after listening.',
                child: _textArea(
                  context,
                  controller: _responseController,
                  hint: 'Describe what listeners should think, feel, or do afterward',
                  minLines: 4,
                ),
              ),
              const SizedBox(height: 24),
              _section(
                context,
                title: 'Add to Speech',
                subtitle:
                    'Choose an additional element to make the speech more engaging.',
                child: _dropdown(
                  context,
                  value: _selectedInclude,
                  items: _includeOptions,
                  onChanged: (value) {
                    if (value == null) return;
                    setState(() => _selectedInclude = value);
                  },
                ),
              ),
              const SizedBox(height: 24),
              _section(
                context,
                title: 'Output Language',
                subtitle:
                    'Select the language in which the speech should be written.',
                child: _dropdown(
                  context,
                  value: _selectedLanguage,
                  items: _languageOptions,
                  onChanged: (value) {
                    if (value == null) return;
                    setState(() => _selectedLanguage = value);
                  },
                ),
              ),
              const SizedBox(height: 30),
              SizedBox(
                height: 56,
                child: FilledButton(
                  onPressed: _generateSpeech,
                  style: FilledButton.styleFrom(
                    backgroundColor: isDark
                        ? const Color(0xFF9146E8)
                        : const Color(0xFFFF9500),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    textStyle: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  child: const Text('Generate Speech'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }


  void _generateSpeech() {
    FocusScope.of(context).unfocus();

    final topic = _topicController.text.trim();
    final speaker = _speakerController.text.trim();
    final audience = _audienceController.text.trim();
    final coreIdea = _coreIdeaController.text.trim();
    final desiredResponse = _responseController.text.trim();
    final minutes = _duration.round();

    if (topic.isEmpty) {
      _showWarning('Please enter a title.');
      return;
    }

    if (coreIdea.isEmpty) {
      _showWarning('Please enter the core idea.');
      return;
    }

    final prompt = _buildSpeechPrompt(
      topic: topic,
      speaker: speaker,
      audience: audience,
      coreIdea: coreIdea,
      desiredResponse: desiredResponse,
      minutes: minutes,
    );

    debugPrint('========== SPEECH ==========');
    debugPrint('Topic: $topic');
    debugPrint('Speaker: $speaker');
    debugPrint('Event: $_selectedEvent');
    debugPrint('Audience: $audience');
    debugPrint('Core Idea: $coreIdea');
    debugPrint('Tone: $_selectedTone');
    debugPrint('Desired Response: $desiredResponse');
    debugPrint('Include: $_selectedInclude');
    debugPrint('Language: $_selectedLanguage');
    debugPrint('Duration: $minutes minutes');
    debugPrint('========== GENERATED PROMPT ==========');
    debugPrint(prompt);
    debugPrint('======================================');

    // API / generation screen connection can be added here later.
  }

  void _showWarning(String message) {
    showDialog(
      context: context,
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;

        return AlertDialog(
          backgroundColor:
              isDark ? const Color(0xFF21152F) : Colors.white,
          title: Text(
            'Missing Information',
            style: TextStyle(
              color: isDark ? Colors.white : const Color(0xFF1B1B1B),
            ),
          ),
          content: Text(
            message,
            style: TextStyle(
              color: isDark
                  ? const Color(0xFFB9AEC8)
                  : const Color(0xFF555555),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'OK',
                style: TextStyle(
                  color: isDark
                      ? const Color(0xFF9146E8)
                      : const Color(0xFFFF9500),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  String _promptValue(String value) {
    final trimmed = value.trim();
    return trimmed.isEmpty ? 'Not provided' : trimmed;
  }

  String _buildSpeechPrompt({
    required String topic,
    required String speaker,
    required String audience,
    required String coreIdea,
    required String desiredResponse,
    required int minutes,
  }) {
    final targetWords = minutes * 135;
    final minimumWords = (targetWords - 35).clamp(100, 100000);
    final maximumWords = targetWords + 35;

    final response = desiredResponse.trim().isEmpty
        ? 'No specific response provided'
        : desiredResponse.trim();

    return """
You are an exceptional professional speechwriter with outstanding emotional intelligence, rhetorical skill, cultural awareness, factual discipline, and an ear for natural spoken language.

Write one original, polished, stage-ready speech using the specifications below. It must sound genuinely written by a thoughtful human for this exact speaker, audience, and occasion—not like a generic AI template.

SPEECH BRIEF

Topic: ${_promptValue(topic)}
Speaker name or role: ${_promptValue(speaker)}
Occasion: $_selectedEvent
Audience: ${_promptValue(audience)}
Core idea: $coreIdea
Delivery style: $_selectedTone
Desired audience response: ${_promptValue(response)}
Requested element: $_selectedInclude
Language: $_selectedLanguage
Speaking time: $minutes minutes
Target length: $minimumWords–$maximumWords words (aim near $targetWords)

PRIMARY OBJECTIVE

Understand the speaker's real purpose before writing. Preserve every supplied fact and intention. Build the entire speech around one clear central message and make it meaningful for this specific audience and occasion.

AUDIENCE AND OCCASION

Adapt vocabulary, examples, emotional intensity, formality, humor, references, and call to action to the stated audience and occasion. Address the audience naturally when appropriate. Never assume demographic facts, shared experiences, beliefs, or relationships that were not provided.

OPENING

Begin immediately with a strong, relevant opening that earns attention. It may use a compelling observation, question, contrast, vivid but non-invented image, or direct statement. Avoid clichés such as “It is an honor to stand before you today” unless the context truly requires them. Do not introduce the output or explain what you are about to write.

STRUCTURE

Create a clear spoken progression:

- an engaging opening
- a natural connection to the occasion and audience
- development of the core idea through two or three coherent movements
- smooth transitions that are easy to follow aloud
- a purposeful emotional or intellectual peak
- a memorable conclusion

Do not print section headings or labels in the final speech. The structure must be felt, not announced.

DELIVERY STYLE

Make the writing genuinely ${_selectedTone.toLowerCase()}. Express the style through word choice, rhythm, pacing, sentence length, imagery, warmth, restraint, and directness. Do not merely insert adjectives associated with the tone.

REQUESTED ELEMENT

Naturally incorporate: $_selectedInclude.

If the requested element would require an unsupported fact, quotation, statistic, personal memory, or story, do not fabricate it. Instead, achieve the same rhetorical purpose honestly without pretending a fact is known.

DESIRED RESPONSE

Guide listeners naturally toward this response: $response.

If a call to action is appropriate, make it specific, credible, respectful, and memorable. Do not force one when the requested response is primarily emotional or reflective.

SPOKEN-LANGUAGE QUALITY

Write for the ear, not the page. Use natural breath-length phrasing, varied sentence lengths, intentional rhythm, clear transitions, selective repetition, and language that is comfortable to say aloud. Avoid dense paragraphs, awkward literal translation, excessive lists, corporate jargon, robotic phrasing, generic filler, melodrama, and repeated ideas.

LANGUAGE

Write the entire speech in $_selectedLanguage. It must read as if originally composed by a fluent native speaker. Use culturally appropriate vocabulary, honorifics, idioms, punctuation, and rhetorical conventions. Do not mix languages unless a supplied proper noun requires it.

FACTUAL INTEGRITY

Use only information supported by the brief. Never invent names, dates, places, achievements, relationships, personal memories, quotations, research, statistics, historical claims, promises, or events. If a detail is missing, write gracefully around it rather than using brackets, placeholders, or fabricated specifics.

LENGTH AND PACING

Produce approximately $targetWords words and remain within $minimumWords–$maximumWords words. The speech should take about $minutes minutes at a natural speaking pace. Do not pad the speech with repetition merely to reach the target.

CONCLUSION

End with language that feels earned by the speech. Reinforce the core idea without mechanically summarizing every point. Leave the audience with one clear final thought, feeling, image, or action. The last line should be concise and memorable without sounding like a slogan unless the context calls for one.

FINAL SILENT CHECK

Before responding, silently verify that the speech fits the speaker, audience, occasion, tone, language, requested element, desired response, and duration; contains no invented facts; flows naturally aloud; avoids generic AI expressions; and is immediately usable on stage.

STRICT OUTPUT RULES

Output only the finished speech.
Do not include a title unless it would naturally be spoken aloud.
Do not include explanations, analysis, notes, alternatives, word counts, stage directions, markdown headings, or commentary.
Do not say “Here is your speech,” “Generated Speech,” “Sure,” or anything before or after the speech.
""";
  }

  Widget _section(
    BuildContext context, {
    required String title,
    String? subtitle,
    required Widget child,
  }) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: theme.textTheme.titleMedium?.copyWith(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        if (subtitle != null) ...[
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: theme.textTheme.bodySmall?.copyWith(
              fontSize: 12,
              height: 1.45,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
        const SizedBox(height: 10),
        child,
      ],
    );
  }

  Widget _textField(
    BuildContext context, {
    required TextEditingController controller,
    required String hint,
  }) {
    return TextField(
      controller: controller,
      textInputAction: TextInputAction.done,
      decoration: _inputDecoration(context, hint),
    );
  }

  Widget _textArea(
    BuildContext context, {
    required TextEditingController controller,
    required String hint,
    int minLines = 4,
  }) {
    return TextField(
      controller: controller,
      minLines: minLines,
      maxLines: minLines + 2,
      textInputAction: TextInputAction.newline,
      decoration: _inputDecoration(context, hint),
    );
  }

  Widget _dropdown(
    BuildContext context, {
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return InkWell(
      onTap: () {
        _showTraditionalSelector(
          context,
          items: items,
          selectedValue: value,
          onSelected: (selected) {
            onChanged(selected);
          },
        );
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        height: 56,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF21152F) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isDark
                ? const Color(0xFF49305F)
                : const Color(0xFFE0DCE8),
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
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ),
            Icon(
              Icons.keyboard_arrow_down_rounded,
              size: 24,
              color: isDark
                  ? const Color(0xFFB9AEC8)
                  : const Color(0xFF666666),
            ),
          ],
        ),
      ),
    );
  }

  void _showTraditionalSelector(
    BuildContext context, {
    required List<String> items,
    required String selectedValue,
    required ValueChanged<String> onSelected,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return _SpeechSelectorSheet(
          items: items,
          selectedValue: selectedValue,
          onSelected: (value) {
            Navigator.pop(sheetContext);
            onSelected(value);
          },
        );
      },
    );
  }

  InputDecoration _inputDecoration(BuildContext context, String hint) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final fill = isDark ? const Color(0xFF21152F) : Colors.white;
    final border = isDark
        ? const Color(0xFF49305F)
        : const Color(0xFFE0DCE8);

    return InputDecoration(
      hintText: hint.isEmpty ? null : hint,
      hintStyle: TextStyle(
        fontSize: 14,
        color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.72),
      ),
      filled: true,
      fillColor: fill,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 17,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: theme.colorScheme.primary,
          width: 1.4,
        ),
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }

  Widget _durationSection(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final activeColor =
        isDark ? const Color(0xFF9146E8) : const Color(0xFFFF9500);

    final minutes = _duration.round();
    final words = minutes * 135;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'Speaking Time',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Text(
              '$minutes minutes',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: activeColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: 3),
        Text(
          'Estimated length: approximately $words words.',
          style: theme.textTheme.bodySmall?.copyWith(
            fontSize: 12,
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 8),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: activeColor,
            inactiveTrackColor: isDark
                ? const Color(0xFF2A1A3B)
                : const Color(0xFFD6D6DB),
            thumbColor: Colors.white,
            overlayColor: activeColor.withValues(alpha: 0.12),
            trackHeight: 4,
            thumbShape: const RoundSliderThumbShape(
              enabledThumbRadius: 12,
              elevation: 2,
            ),
          ),
          child: Slider(
            min: 1,
            max: 10,
            divisions: 9,
            value: _duration,
            onChanged: (value) {
              setState(() => _duration = value);
            },
          ),
        ),
        Row(
          children: List.generate(10, (index) {
            final number = index + 1;
            final selected = number == minutes;

            return Expanded(
              child: Text(
                '$number',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight:
                      selected ? FontWeight.w700 : FontWeight.w400,
                  color: selected
                      ? activeColor
                      : theme.colorScheme.onSurfaceVariant,
                ),
              ),
            );
          }),
        ),
      ],
    );
  }
}

class _SpeechSelectorSheet extends StatefulWidget {
  const _SpeechSelectorSheet({
    required this.items,
    required this.selectedValue,
    required this.onSelected,
  });

  final List<String> items;
  final String selectedValue;
  final ValueChanged<String> onSelected;

  @override
  State<_SpeechSelectorSheet> createState() => _SpeechSelectorSheetState();
}

class _SpeechSelectorSheetState extends State<_SpeechSelectorSheet> {
  final TextEditingController _searchController = TextEditingController();
  String _search = '';

  bool get _showSearch => widget.items.length > 20;

  List<String> get _filteredItems {
    final query = _search.trim().toLowerCase();
    if (query.isEmpty) return widget.items;

    return widget.items
        .where((item) => item.toLowerCase().contains(query))
        .toList();
  }

  double _sheetHeight(BuildContext context) {
    final screenHeight = MediaQuery.sizeOf(context).height;
    final maxHeight = screenHeight * 0.50;

    if (_showSearch) {
      return maxHeight;
    }

    const fixedContent = 76.0;
    const rowHeight = 56.0;
    final naturalHeight = fixedContent + (widget.items.length * rowHeight);

    return naturalHeight.clamp(190.0, maxHeight).toDouble();
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
    final items = _filteredItems;

    final background =
        isDark ? const Color(0xFF21152F) : Colors.white;
    final secondary =
        isDark ? const Color(0xFF2A1A3B) : const Color(0xFFF4F4F4);
    final border =
        isDark ? const Color(0xFF49305F) : const Color(0xFFE8E8E8);
    final accent =
        isDark ? const Color(0xFF9146E8) : const Color(0xFFFF9500);
    final muted =
        isDark ? const Color(0xFFB9AEC8) : const Color(0xFF777777);

    return SafeArea(
      top: false,
      child: Container(
        height: _sheetHeight(context),
        decoration: BoxDecoration(
          color: background,
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(24),
          ),
          border: isDark
              ? const Border(
                  top: BorderSide(color: Color(0xFF49305F)),
                )
              : null,
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
            if (_showSearch)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
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
                      setState(() => _search = value);
                    },
                    style: TextStyle(
                      fontSize: 14,
                      color: theme.colorScheme.onSurface,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Search',
                      hintStyle: TextStyle(
                        color: muted,
                      ),
                      prefixIcon: Icon(
                        Icons.search_rounded,
                        color: muted,
                      ),
                      suffixIcon: _search.isNotEmpty
                          ? IconButton(
                              onPressed: () {
                                _searchController.clear();
                                setState(() => _search = '');
                              },
                              icon: Icon(
                                Icons.close_rounded,
                                color: muted,
                              ),
                            )
                          : null,
                      border: InputBorder.none,
                    ),
                  ),
                ),
              )
            else
              const SizedBox(height: 10),
            Expanded(
              child: items.isEmpty
                  ? Center(
                      child: Text(
                        'No results found',
                        style: TextStyle(
                          fontSize: 14,
                          color: muted,
                        ),
                      ),
                    )
                  : ListView.separated(
                      physics: widget.items.length > 4
                          ? const BouncingScrollPhysics()
                          : const NeverScrollableScrollPhysics(),
                      padding: EdgeInsets.zero,
                      itemCount: items.length,
                      separatorBuilder: (_, __) => Divider(
                        height: 1,
                        indent: 18,
                        endIndent: 18,
                        color: border,
                      ),
                      itemBuilder: (context, index) {
                        final item = items[index];
                        final selected = item == widget.selectedValue;

                        return SizedBox(
                          height: 56,
                          child: ListTile(
                            contentPadding:
                                const EdgeInsets.symmetric(horizontal: 20),
                            title: Text(
                              item,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: selected
                                    ? FontWeight.w700
                                    : FontWeight.w500,
                                color: selected
                                    ? accent
                                    : theme.colorScheme.onSurface,
                              ),
                            ),
                            trailing: selected
                                ? Icon(
                                    Icons.check_circle_rounded,
                                    color: accent,
                                  )
                                : null,
                            onTap: () => widget.onSelected(item),
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

