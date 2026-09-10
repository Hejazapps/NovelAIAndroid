import 'package:flutter/material.dart';

class CreateCharacterScreen extends StatefulWidget {
  const CreateCharacterScreen({super.key});

  @override
  State<CreateCharacterScreen> createState() => _CreateCharacterScreenState();
}

class _CreateCharacterScreenState extends State<CreateCharacterScreen> {
  final _nameController = TextEditingController();
  final _detailController = TextEditingController();
  final _goalController = TextEditingController();
  final _strengthController = TextEditingController();
  final _weaknessController = TextEditingController();

  String _language = 'English';
  String _personality = 'Romantic';
  String _roleInStory = 'Hero';
  String _storyGenre = 'Adventure';
  int _credibilityIndex = 0;

  final List<String> _personalityOptions = const [
    'Romantic',
    'Funny',
    'Serious',
    'Cold',
    'Kind',
    'Smart',
    'Shy',
    'Confident',
    'Mysterious',
    'Carefree / Chill',
    'Teasing / Playful',
    'Childish / Naive',
    'Hyperactive / Energetic',
    'Stoic / Emotionless',
    'Apathetic / Indifferent',
    'Introverted / Hermit',
    'Strict / Disciplined',
    'Charismatic / Leader',
    'The Mentor / Wise',
    'The Chosen One',
    'Honorbound / Samurai',
    'Sarcastic / Witty',
    'Rebellious',
    'Arrogant',
    'Aggressive',
    'Flirtatious',
    'Loyal / Brave',
    'Melancholic / Gloomy',
    'Anxious / Overthinking',
    'Paranoid',
    'Bipolar / Unpredictable',
    'Cynical',
    'Nihilistic',
    'Gluttonous / Hedonistic',
    'Evil / Villainous',
    'Sadistic',
    'Obsessive / Yandere',
    'Manipulatory / Mastermind',
    'AI Suggest',
  ];

  final List<String> _roleOptions = const [
    'Hero',
    'Villain',
    'Anti-Hero',
    'Supporting Character',
    'Mentor',
    'Love Interest',
    'Rival',
    'Sidekick',
  ];

  final List<String> _genreOptions = const [
    'Adventure',
    'Fantasy',
    'Romance',
    'Mystery',
    'Thriller',
    'Horror',
    'Science Fiction',
    'Drama',
    'Comedy',
    'Historical',
    'Crime',
    'Superhero',
  ];

  final List<String> _languageOptions = const [
    'English',
    'Arabic',
    'Bengali',
    'Catalan',
    'Chinese (Simplified)',
    'Chinese (Traditional)',
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
    _nameController.dispose();
    _detailController.dispose();
    _goalController.dispose();
    _strengthController.dispose();
    _weaknessController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDark ? const Color(0xFF15131B) : const Color(0xFFF8F7FA),
      appBar: AppBar(
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        backgroundColor:
            isDark ? const Color(0xFF15131B) : const Color(0xFFF8F7FA),
        foregroundColor: theme.colorScheme.onSurface,
        title: const Text(
          'Create Character',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: ListView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          padding: const EdgeInsets.fromLTRB(16, 18, 16, 36),
          children: [
            _sectionTitle(context, 'Character Name'),
            const SizedBox(height: 10),
            _textField(
              context,
              controller: _nameController,
              hint: 'Enter Character Name',
            ),
            const SizedBox(height: 24),

            _sectionTitle(context, 'Character Detailed'),
            const SizedBox(height: 10),
            _textArea(
              context,
              controller: _detailController,
              hint:
                  'Describe their background, appearance, or mood. (e.g., A sarcastic cyber-hacker in neon-lit Tokyo, seeking revenge...)',
            ),
            const SizedBox(height: 24),

            _sectionTitle(context, 'Choose Language'),
            const SizedBox(height: 10),
            _dropdown(
              context,
              value: _language,
              items: _languageOptions,
              onChanged: (value) {
                if (value == null) return;
                setState(() => _language = value);
              },
            ),
            const SizedBox(height: 24),

            _sectionTitle(context, 'Choose Personality'),
            const SizedBox(height: 10),
            _dropdown(
              context,
              value: _personality,
              items: _personalityOptions,
              onChanged: (value) {
                if (value == null) return;
                setState(() => _personality = value);
              },
            ),
            const SizedBox(height: 24),

            _sectionTitle(context, 'Role in Story'),
            const SizedBox(height: 10),
            _dropdown(
              context,
              value: _roleInStory,
              items: _roleOptions,
              onChanged: (value) {
                if (value == null) return;
                setState(() => _roleInStory = value);
              },
            ),
            const SizedBox(height: 24),

            _sectionTitle(context, 'Character Goal'),
            const SizedBox(height: 10),
            _textField(
              context,
              controller: _goalController,
              hint: 'What does this character want to achieve?',
            ),
            const SizedBox(height: 24),

            _sectionTitle(context, 'Strength (Optional)'),
            const SizedBox(height: 10),
            _textField(
              context,
              controller: _strengthController,
              hint: 'Example: Brave, intelligent, loyal...',
            ),
            const SizedBox(height: 24),

            _sectionTitle(context, 'Weakness / Flaw (Optional)'),
            const SizedBox(height: 10),
            _textField(
              context,
              controller: _weaknessController,
              hint: 'Example: Impulsive, jealous, fearful...',
            ),
            const SizedBox(height: 24),

            _sectionTitle(context, 'Story Genre'),
            const SizedBox(height: 10),
            _dropdown(
              context,
              value: _storyGenre,
              items: _genreOptions,
              onChanged: (value) {
                if (value == null) return;
                setState(() => _storyGenre = value);
              },
            ),
            const SizedBox(height: 24),

            _sectionTitle(context, 'Choose Credibility'),
            const SizedBox(height: 10),
            _credibilitySelector(context),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(BuildContext context, String text) {
    return Text(
      text,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontSize: 17,
            fontWeight: FontWeight.w600,
          ),
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
  }) {
    return TextField(
      controller: controller,
      minLines: 5,
      maxLines: 7,
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
      menuMaxHeight: 380,
      icon: const Icon(
        Icons.keyboard_arrow_down_rounded,
        size: 24,
      ),
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

  InputDecoration _inputDecoration(
    BuildContext context,
    String hint,
  ) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return InputDecoration(
      hintText: hint.isEmpty ? null : hint,
      hintStyle: TextStyle(
        fontSize: 14,
        color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.72),
      ),
      filled: true,
      fillColor: isDark ? const Color(0xFF2B293A) : Colors.white,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 16,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color:
              isDark ? const Color(0xFF564A70) : const Color(0xFFE0DCE8),
        ),
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

  Widget _credibilitySelector(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final background =
        isDark ? const Color(0xFF2B293A) : Colors.white;

    final selectedColor =
        isDark ? const Color(0xFF4B3D64) : const Color(0xFFF1EDF5);

    const titles = ['Low', 'Medium', 'High'];

    return Container(
      height: 50,
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color:
              isDark ? const Color(0xFF564A70) : const Color(0xFFE0DCE8),
        ),
      ),
      child: Row(
        children: List.generate(
          titles.length,
          (index) => Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() => _credibilityIndex = index);
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeOut,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: _credibilityIndex == index
                      ? selectedColor
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  titles[index],
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
