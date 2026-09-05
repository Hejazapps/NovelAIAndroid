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
        ? const Color(0xFF15131B)
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
                  onPressed: () {
                    // UI only for now.
                  },
                  style: FilledButton.styleFrom(
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
    return DropdownButtonFormField<String>(
      initialValue: value,
      isExpanded: true,
      icon: const Icon(Icons.keyboard_arrow_down_rounded, size: 24),
      menuMaxHeight: 360,
      decoration: _inputDecoration(context, ''),
      style: TextStyle(
        fontSize: 14,
        color: Theme.of(context).colorScheme.onSurface,
      ),
      items: items
          .map(
            (item) => DropdownMenuItem<String>(
              value: item,
              child: Text(
                item,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          )
          .toList(),
      onChanged: onChanged,
    );
  }

  InputDecoration _inputDecoration(BuildContext context, String hint) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final fill = isDark ? const Color(0xFF2B293A) : Colors.white;
    final border = isDark
        ? const Color(0xFF564A70)
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
        isDark ? const Color(0xFF9F49F5) : const Color(0xFFFF9500);

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
                ? const Color(0xFF373149)
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
