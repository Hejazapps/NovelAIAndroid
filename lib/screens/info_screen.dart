import 'package:flutter/material.dart';

class InfoScreen extends StatefulWidget {
  const InfoScreen({super.key});

  @override
  State<InfoScreen> createState() => _InfoScreenState();
}

enum WritingTipCategory {
  story,
  book,
  poem,
  lyrics,
  screenplay,
  letter,
  article,
  speech,
}

class _TipItem {
  const _TipItem({
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  final String title;
  final String subtitle;
  final IconData icon;
}

class _CategoryData {
  const _CategoryData({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.tips,
    required this.reminder,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final List<_TipItem> tips;
  final String reminder;
}

class _InfoScreenState extends State<InfoScreen> {
  WritingTipCategory _selectedCategory = WritingTipCategory.story;

  Color _accent(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? const Color(0xFFAB5CF2)
        : const Color(0xFFFF6333);
  }

  Color _surface(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark ? const Color(0xFF211F2A) : Colors.white;
  }

  Color _pageBackground(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark ? const Color(0xFF15131B) : const Color(0xFFF8F7FA);
  }

  String _categoryName(WritingTipCategory category) {
    switch (category) {
      case WritingTipCategory.story:
        return 'Story';
      case WritingTipCategory.book:
        return 'Book';
      case WritingTipCategory.poem:
        return 'Poem';
      case WritingTipCategory.lyrics:
        return 'Lyrics';
      case WritingTipCategory.screenplay:
        return 'Screenplay';
      case WritingTipCategory.letter:
        return 'Letter';
      case WritingTipCategory.article:
        return 'Article';
      case WritingTipCategory.speech:
        return 'Speech';
    }
  }

  IconData _categoryIcon(WritingTipCategory category) {
    switch (category) {
      case WritingTipCategory.story:
        return Icons.menu_book_rounded;
      case WritingTipCategory.book:
        return Icons.library_books_rounded;
      case WritingTipCategory.poem:
        return Icons.format_quote_rounded;
      case WritingTipCategory.lyrics:
        return Icons.music_note_rounded;
      case WritingTipCategory.screenplay:
        return Icons.movie_rounded;
      case WritingTipCategory.letter:
        return Icons.mail_rounded;
      case WritingTipCategory.article:
        return Icons.description_rounded;
      case WritingTipCategory.speech:
        return Icons.mic_rounded;
    }
  }

  _CategoryData _dataFor(WritingTipCategory category) {
    switch (category) {
      case WritingTipCategory.story:
        return const _CategoryData(
          title: 'Write Better Stories',
          subtitle:
              'Use these practical ideas to make your stories clearer, more engaging, and more memorable.',
          icon: Icons.menu_book_rounded,
          tips: [
            _TipItem(
              title: 'Start with a clear direction',
              subtitle:
                  'Know the central idea or goal of the story before you begin writing.',
              icon: Icons.gps_fixed_rounded,
            ),
            _TipItem(
              title: 'Build believable characters',
              subtitle:
                  'Give important characters clear goals, motivations, strengths, and flaws.',
              icon: Icons.person_rounded,
            ),
            _TipItem(
              title: 'Create meaningful conflict',
              subtitle:
                  'Give your characters obstacles that force them to make choices and change.',
              icon: Icons.bolt_rounded,
            ),
            _TipItem(
              title: 'Show the scene',
              subtitle:
                  'Use specific actions, sensory details, and reactions instead of only explaining.',
              icon: Icons.visibility_rounded,
            ),
            _TipItem(
              title: 'Control the pacing',
              subtitle:
                  'Slow down important emotional moments and move faster through less important ones.',
              icon: Icons.speed_rounded,
            ),
            _TipItem(
              title: 'Give the ending purpose',
              subtitle:
                  'Make sure the ending resolves the central conflict or leaves a deliberate final effect.',
              icon: Icons.flag_rounded,
            ),
          ],
          reminder:
              'A strong story does not need to be complicated. Clear characters, meaningful conflict, and a satisfying direction matter most.',
        );

      case WritingTipCategory.book:
        return const _CategoryData(
          title: 'Plan a Stronger Book',
          subtitle:
              'Keep a long-form project focused by thinking about structure, continuity, and character development.',
          icon: Icons.library_books_rounded,
          tips: [
            _TipItem(
              title: 'Define the main promise',
              subtitle:
                  'Be clear about what experience, idea, or journey the book will give the reader.',
              icon: Icons.gps_fixed_rounded,
            ),
            _TipItem(
              title: 'Develop the main cast',
              subtitle:
                  'Track goals, relationships, motivations, and changes across the full book.',
              icon: Icons.groups_rounded,
            ),
            _TipItem(
              title: 'Plan the structure',
              subtitle:
                  'Organize major events or ideas before expanding them into chapters.',
              icon: Icons.layers_rounded,
            ),
            _TipItem(
              title: 'Maintain continuity',
              subtitle:
                  'Keep names, facts, timelines, motivations, and world details consistent.',
              icon: Icons.link_rounded,
            ),
            _TipItem(
              title: 'Vary the pace',
              subtitle:
                  'Balance quieter development with stronger turning points and revelations.',
              icon: Icons.speed_rounded,
            ),
            _TipItem(
              title: 'Aim toward an ending',
              subtitle:
                  'Let each chapter move the reader closer to the book’s central resolution.',
              icon: Icons.flag_rounded,
            ),
            _TipItem(
              title: 'Revise the whole book',
              subtitle:
                  'After drafting, review the complete work for repetition, gaps, and uneven sections.',
              icon: Icons.edit_rounded,
            ),
          ],
          reminder:
              'A book becomes easier to finish when every chapter has a clear purpose within the larger structure.',
        );

      case WritingTipCategory.poem:
        return const _CategoryData(
          title: 'Write More Expressive Poems',
          subtitle:
              'Focus on feeling, imagery, rhythm, and precise language instead of trying to explain everything.',
          icon: Icons.format_quote_rounded,
          tips: [
            _TipItem(
              title: 'Begin with an emotion',
              subtitle:
                  'Decide what feeling or emotional tension the poem should carry.',
              icon: Icons.favorite_rounded,
            ),
            _TipItem(
              title: 'Use vivid imagery',
              subtitle:
                  'Give the reader something concrete to see, hear, touch, taste, or feel.',
              icon: Icons.image_rounded,
            ),
            _TipItem(
              title: 'Choose precise words',
              subtitle:
                  'Remove unnecessary language and keep words that create the strongest effect.',
              icon: Icons.text_fields_rounded,
            ),
            _TipItem(
              title: 'Listen to the rhythm',
              subtitle:
                  'Read the poem aloud and adjust line breaks, pauses, and repetition.',
              icon: Icons.graphic_eq_rounded,
            ),
            _TipItem(
              title: 'Use figurative language carefully',
              subtitle:
                  'Metaphor and symbolism are strongest when they deepen meaning rather than decorate it.',
              icon: Icons.auto_awesome_rounded,
            ),
            _TipItem(
              title: 'End on a strong image',
              subtitle:
                  'Leave the reader with a final line or image that continues to resonate.',
              icon: Icons.star_rounded,
            ),
          ],
          reminder:
              'Poetry often becomes stronger when it says less but makes the reader feel more.',
        );

      case WritingTipCategory.lyrics:
        return const _CategoryData(
          title: 'Write Stronger Lyrics',
          subtitle:
              'Combine a clear emotional idea with memorable phrasing, rhythm, and repetition.',
          icon: Icons.music_note_rounded,
          tips: [
            _TipItem(
              title: 'Choose the song’s main idea',
              subtitle:
                  'Keep the emotional message focused so the listener knows what the song is about.',
              icon: Icons.gps_fixed_rounded,
            ),
            _TipItem(
              title: 'Build a memorable hook',
              subtitle:
                  'Create a short phrase or idea that can anchor the chorus.',
              icon: Icons.queue_music_rounded,
            ),
            _TipItem(
              title: 'Write for the voice',
              subtitle:
                  'Use words and phrases that sound natural when sung aloud.',
              icon: Icons.mic_rounded,
            ),
            _TipItem(
              title: 'Repeat with purpose',
              subtitle:
                  'Use repetition to reinforce emotion without making every section feel identical.',
              icon: Icons.repeat_rounded,
            ),
            _TipItem(
              title: 'Pay attention to rhythm',
              subtitle:
                  'Match syllables and phrasing to the musical flow you imagine.',
              icon: Icons.graphic_eq_rounded,
            ),
            _TipItem(
              title: 'Make the perspective consistent',
              subtitle:
                  'Keep the singer’s voice, relationships, and point of view clear throughout the song.',
              icon: Icons.groups_rounded,
            ),
          ],
          reminder:
              'A strong lyric usually has one central feeling that the verse develops and the chorus makes unforgettable.',
        );

      case WritingTipCategory.screenplay:
        return const _CategoryData(
          title: 'Write Better Screenplays',
          subtitle:
              'Think visually, keep scenes purposeful, and let character actions and dialogue carry the story.',
          icon: Icons.movie_rounded,
          tips: [
            _TipItem(
              title: 'Write what can be seen',
              subtitle:
                  'Focus on actions, expressions, locations, sounds, and visual behavior.',
              icon: Icons.visibility_rounded,
            ),
            _TipItem(
              title: 'Give every scene a purpose',
              subtitle:
                  'Each scene should reveal something, create conflict, or move the story forward.',
              icon: Icons.view_agenda_rounded,
            ),
            _TipItem(
              title: 'Keep action active',
              subtitle:
                  'Use clear, immediate descriptions rather than long explanations.',
              icon: Icons.directions_run_rounded,
            ),
            _TipItem(
              title: 'Make dialogue playable',
              subtitle:
                  'Give characters distinct voices and let subtext do some of the work.',
              icon: Icons.forum_rounded,
            ),
            _TipItem(
              title: 'Enter late and leave early',
              subtitle:
                  'Start scenes close to the important moment and exit once the dramatic purpose is complete.',
              icon: Icons.arrow_circle_right_rounded,
            ),
            _TipItem(
              title: 'Use strong turning points',
              subtitle:
                  'Let key scenes change the situation, raise the stakes, or force a decision.',
              icon: Icons.bolt_rounded,
            ),
          ],
          reminder:
              'Screenplays are visual. If an idea cannot be seen, heard, or performed, find a way to dramatize it.',
        );

      case WritingTipCategory.letter:
        return const _CategoryData(
          title: 'Write More Effective Letters',
          subtitle:
              'Use a clear purpose, suitable tone, and thoughtful structure for the person receiving the letter.',
          icon: Icons.mail_rounded,
          tips: [
            _TipItem(
              title: 'Know the purpose',
              subtitle:
                  'Decide exactly what the letter needs to communicate or achieve.',
              icon: Icons.gps_fixed_rounded,
            ),
            _TipItem(
              title: 'Write for the recipient',
              subtitle:
                  'Match the language and level of formality to your relationship with the reader.',
              icon: Icons.person_rounded,
            ),
            _TipItem(
              title: 'Open naturally',
              subtitle:
                  'Start with a greeting and opening that fits the situation and tone.',
              icon: Icons.waving_hand_rounded,
            ),
            _TipItem(
              title: 'Keep the structure clear',
              subtitle:
                  'Organize the message so the reader can easily follow the main point.',
              icon: Icons.format_align_left_rounded,
            ),
            _TipItem(
              title: 'Be sincere',
              subtitle:
                  'Use direct, honest language when the letter is personal or emotional.',
              icon: Icons.favorite_rounded,
            ),
            _TipItem(
              title: 'End appropriately',
              subtitle:
                  'Close with a clear final thought and a sign-off that suits the relationship.',
              icon: Icons.verified_rounded,
            ),
          ],
          reminder:
              'A good letter feels written for one specific person, not for a generic audience.',
        );

      case WritingTipCategory.article:
        return const _CategoryData(
          title: 'Write Clearer Articles',
          subtitle:
              'Make the topic easy to understand with a strong focus, useful structure, and clean language.',
          icon: Icons.description_rounded,
          tips: [
            _TipItem(
              title: 'Define the main point',
              subtitle:
                  'Know what the reader should understand before you begin drafting.',
              icon: Icons.gps_fixed_rounded,
            ),
            _TipItem(
              title: 'Create a useful opening',
              subtitle:
                  'Give the reader a reason to continue and explain what the article will cover.',
              icon: Icons.text_snippet_rounded,
            ),
            _TipItem(
              title: 'Organize the sections',
              subtitle:
                  'Break the content into a logical order using clear headings and transitions.',
              icon: Icons.list_alt_rounded,
            ),
            _TipItem(
              title: 'Use simple language',
              subtitle:
                  'Prefer clear sentences and specific wording over unnecessary complexity.',
              icon: Icons.text_format_rounded,
            ),
            _TipItem(
              title: 'Support the important points',
              subtitle:
                  'Use examples, explanations, or evidence where the reader needs more confidence.',
              icon: Icons.check_circle_rounded,
            ),
            _TipItem(
              title: 'Finish with direction',
              subtitle:
                  'End by reinforcing the main idea or giving the reader a useful next step.',
              icon: Icons.flag_rounded,
            ),
          ],
          reminder:
              'Good articles respect the reader’s time: clear purpose, clear structure, and no unnecessary filler.',
        );

      case WritingTipCategory.speech:
        return const _CategoryData(
          title: 'Write More Powerful Speeches',
          subtitle:
              'Write for listeners rather than readers by using clarity, rhythm, emotion, and memorable phrasing.',
          icon: Icons.mic_rounded,
          tips: [
            _TipItem(
              title: 'Know your audience',
              subtitle:
                  'Adjust examples, language, and tone to the people who will hear the speech.',
              icon: Icons.groups_rounded,
            ),
            _TipItem(
              title: 'Open with energy',
              subtitle:
                  'Start with a clear idea, question, image, or story that earns attention.',
              icon: Icons.auto_awesome_rounded,
            ),
            _TipItem(
              title: 'Keep one core message',
              subtitle:
                  'Make sure the audience can remember the main point after the speech ends.',
              icon: Icons.gps_fixed_rounded,
            ),
            _TipItem(
              title: 'Write for speaking',
              subtitle:
                  'Use natural sentences, pauses, repetition, and phrasing that sound good aloud.',
              icon: Icons.format_quote_rounded,
            ),
            _TipItem(
              title: 'Use examples and stories',
              subtitle:
                  'Concrete moments help listeners understand and remember abstract ideas.',
              icon: Icons.book_rounded,
            ),
            _TipItem(
              title: 'End memorably',
              subtitle:
                  'Close with a final thought, call to action, or line that reinforces your message.',
              icon: Icons.star_rounded,
            ),
          ],
          reminder:
              'A speech should sound natural when spoken. Read it aloud before you consider it finished.',
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final data = _dataFor(_selectedCategory);
    final accent = _accent(context);
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: _pageBackground(context),
      appBar: AppBar(
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: _pageBackground(context),
        foregroundColor: theme.colorScheme.onSurface,
        centerTitle: true,
        leadingWidth: 64,
        leading: Padding(
          padding: const EdgeInsets.only(left: 16, top: 8, bottom: 8),
          child: Material(
            color: _surface(context),
            borderRadius: BorderRadius.circular(20),
            child: InkWell(
              borderRadius: BorderRadius.circular(20),
              onTap: () => Navigator.maybePop(context),
              child: const Icon(Icons.chevron_left_rounded, size: 26),
            ),
          ),
        ),
        title: const Text(
          'Writing Tips',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: ListView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(0, 12, 0, 30),
        children: [
          SizedBox(
            height: 92,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: WritingTipCategory.values.length,
              separatorBuilder: (_, __) => const SizedBox(width: 10),
              itemBuilder: (context, index) {
                final category = WritingTipCategory.values[index];
                final selected = category == _selectedCategory;

                return _CategoryChip(
                  title: _categoryName(category),
                  icon: _categoryIcon(category),
                  selected: selected,
                  accent: accent,
                  surface: _surface(context),
                  onTap: () {
                    if (_selectedCategory == category) return;
                    setState(() => _selectedCategory = category);
                  },
                );
              },
            ),
          ),
          const SizedBox(height: 18),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: _HeaderCard(
              title: data.title,
              subtitle: data.subtitle,
              icon: data.icon,
              accent: accent,
              surface: _surface(context),
            ),
          ),
          const SizedBox(height: 18),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: List.generate(
                data.tips.length,
                (index) => Padding(
                  padding: EdgeInsets.only(
                    bottom: index == data.tips.length - 1 ? 0 : 12,
                  ),
                  child: _TipCard(
                    number: index + 1,
                    tip: data.tips[index],
                    accent: accent,
                    surface: _surface(context),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: _ReminderCard(
              text: data.reminder,
              accent: accent,
              surface: _surface(context),
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  const _CategoryChip({
    required this.title,
    required this.icon,
    required this.selected,
    required this.accent,
    required this.surface,
    required this.onTap,
  });

  final String title;
  final IconData icon;
  final bool selected;
  final Color accent;
  final Color surface;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final borderColor = selected
        ? accent
        : Theme.of(context).dividerColor.withValues(alpha: 0.18);

    return Material(
      color: selected ? accent.withValues(alpha: 0.12) : surface,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          constraints: const BoxConstraints(minWidth: 76),
          padding: const EdgeInsets.fromLTRB(12, 10, 12, 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: borderColor),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 40,
                height: 40,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: selected
                      ? accent.withValues(alpha: 0.15)
                      : Theme.of(context)
                          .colorScheme
                          .surfaceContainerHighest
                          .withValues(alpha: 0.72),
                  borderRadius: BorderRadius.circular(17),
                ),
                child: Icon(
                  icon,
                  size: 22,
                  color: selected
                      ? accent
                      : Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 7),
              Text(
                title,
                maxLines: 1,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: selected
                      ? accent
                      : Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HeaderCard extends StatelessWidget {
  const _HeaderCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.accent,
    required this.surface,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Color accent;
  final Color surface;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Theme.of(context).dividerColor.withValues(alpha: 0.18),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 56,
            height: 56,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(28),
            ),
            child: Icon(icon, size: 28, color: accent),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    height: 1.1,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 15,
                    height: 1.45,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TipCard extends StatelessWidget {
  const _TipCard({
    required this.number,
    required this.tip,
    required this.accent,
    required this.surface,
  });

  final int number;
  final _TipItem tip;
  final Color accent;
  final Color surface;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 88),
      padding: const EdgeInsets.fromLTRB(14, 15, 14, 15),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(17),
        border: Border.all(
          color: Theme.of(context).dividerColor.withValues(alpha: 0.18),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 50,
            height: 50,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(tip.icon, size: 24, color: accent),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tip.title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    height: 1.25,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  tip.subtitle,
                  style: TextStyle(
                    fontSize: 14,
                    height: 1.4,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Container(
            width: 36,
            height: 29,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(9),
            ),
            child: Text(
              number.toString().padLeft(2, '0'),
              style: TextStyle(
                color: accent,
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ReminderCard extends StatelessWidget {
  const _ReminderCard({
    required this.text,
    required this.accent,
    required this.surface,
  });

  final String text;
  final Color accent;
  final Color surface;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: accent.withValues(alpha: 0.28),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 48,
            height: 48,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Colors.amber.withValues(alpha: 0.13),
              borderRadius: BorderRadius.circular(24),
            ),
            child: const Icon(
              Icons.lightbulb_rounded,
              size: 24,
              color: Colors.amber,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Remember',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  text,
                  style: TextStyle(
                    fontSize: 14,
                    height: 1.45,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
