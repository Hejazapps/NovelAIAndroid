import 'package:flutter/material.dart';

class LetterScreen extends StatefulWidget {
  const LetterScreen({super.key});

  @override
  State<LetterScreen> createState() => _LetterScreenState();
}

class _LetterScreenState extends State<LetterScreen> {
  final TextEditingController _messageController = TextEditingController();
  final TextEditingController _subjectController = TextEditingController();
  final TextEditingController _senderController = TextEditingController();
  final TextEditingController _recipientController = TextEditingController();

  String selectedLetterType = 'Personal Letter';
  String selectedTone = 'Formal';
  String selectedLanguage = 'English';
  String selectedDelivery = 'Email';
  String selectedRelationship = 'Friend';
  String selectedInclude = 'Personal Message';
  String selectedClosing = 'Sincerely';
  String selectedLength = 'Short';

  final List<String> letterTypes = const [
    'Personal Letter',
    'Business Letter',
    'Formal Letter',
    'Informal Letter',
    'Love Letter',
    'Apology Letter',
    'Thank You Letter',
    'Congratulations Letter',
    'Invitation Letter',
    'Recommendation Letter',
    'Cover Letter',
    'Resignation Letter',
    'Complaint Letter',
    'Request Letter',
    'Condolence Letter',
    'Farewell Letter',
    'Open Letter',
    'Other',
  ];

  final List<String> letterTones = const [
    'Formal',
    'Friendly',
    'Professional',
    'Casual',
    'Polite',
    'Warm',
    'Romantic',
    'Emotional',
    'Apologetic',
    'Grateful',
    'Persuasive',
    'Encouraging',
    'Sympathetic',
    'Humorous',
    'Serious',
  ];

  final List<String> deliveryMethods = const [
    'Email',
    'Printed Letter',
    'Handwritten Letter',
    'Text Message',
    'Greeting Card',
    'Social Media Message',
    'Official Document',
    'Open Letter',
  ];

  final List<String> relationships = const [
    'Friend',
    'Best Friend',
    'Partner',
    'Spouse',
    'Parent',
    'Child',
    'Sibling',
    'Relative',
    'Teacher',
    'Student',
    'Colleague',
    'Manager',
    'Employee',
    'Client',
    'Neighbor',
    'Other',
  ];

  final List<String> includeOptions = const [
    'Personal Message',
    'Shared Memory',
    'Appreciation',
    'Apology',
    'Congratulations',
    'Good Wishes',
    'Important Information',
    'Request',
    'Invitation',
    'Advice',
    'Contact Information',
    'Call to Action',
    'Future Plans',
    'Closing Message',
    'Other',
  ];

  final List<String> closingTypes = const [
    'Sincerely',
    'Yours Sincerely',
    'Yours Faithfully',
    'Best Regards',
    'Kind Regards',
    'Warm Regards',
    'With Appreciation',
    'With Gratitude',
    'Respectfully',
    'Thank You',
    'Best Wishes',
    'Take Care',
    'With Love',
    'Love Always',
    'Yours Truly',
    'Warmly',
    'Cheers',
    'See You Soon',
    'Looking Forward to Hearing from You',
    'Other',
  ];

  final List<String> languages = const [
    'English',
    'Bengali',
    'Arabic',
    'Spanish',
    'French',
    'German',
    'Hindi',
    'Italian',
    'Japanese',
    'Korean',
    'Portuguese',
    'Russian',
    'Turkish',
    'Chinese Simplified',
    'Chinese Traditional',
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
    _messageController.dispose();
    _subjectController.dispose();
    _senderController.dispose();
    _recipientController.dispose();
    super.dispose();
  }

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
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 120),
                children: [
                  _buildMessageSection(),
                  const SizedBox(height: 20),
                  _buildTextField(
                    title: 'Subject',
                    hint: 'Enter subject',
                    controller: _subjectController,
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    title: 'Sender Name',
                    hint: 'Enter sender name',
                    controller: _senderController,
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    title: 'Recipient Name',
                    hint: 'Enter recipient name',
                    controller: _recipientController,
                  ),
                  const SizedBox(height: 22),
                  _buildDropdownTile(
                    title: 'Letter Type',
                    value: selectedLetterType,
                    icon: Icons.mail_outline_rounded,
                    onTap: () {
                      _showSelector(
                        title: 'Letter Type',
                        values: letterTypes,
                        selectedValue: selectedLetterType,
                        allowOther: true,
                        otherTitle: 'Other Letter Type',
                        otherHint: 'Enter letter type',
                        onSelected: (value) {
                          setState(() {
                            selectedLetterType = value;
                          });
                        },
                      );
                    },
                  ),
                  _buildDropdownTile(
                    title: 'Tone',
                    value: selectedTone,
                    icon: Icons.graphic_eq_rounded,
                    onTap: () {
                      _showSelector(
                        title: 'Tone',
                        values: letterTones,
                        selectedValue: selectedTone,
                        onSelected: (value) {
                          setState(() {
                            selectedTone = value;
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
                        title: 'Language',
                        values: languages,
                        selectedValue: selectedLanguage,
                        onSelected: (value) {
                          setState(() {
                            selectedLanguage = value;
                          });
                        },
                      );
                    },
                  ),
                  _buildDropdownTile(
                    title: 'Delivery Method',
                    value: selectedDelivery,
                    icon: Icons.send_outlined,
                    onTap: () {
                      _showSelector(
                        title: 'Delivery Method',
                        values: deliveryMethods,
                        selectedValue: selectedDelivery,
                        onSelected: (value) {
                          setState(() {
                            selectedDelivery = value;
                          });
                        },
                      );
                    },
                  ),
                  _buildDropdownTile(
                    title: 'Relationship',
                    value: selectedRelationship,
                    icon: Icons.people_outline_rounded,
                    onTap: () {
                      _showSelector(
                        title: 'Relationship',
                        values: relationships,
                        selectedValue: selectedRelationship,
                        allowOther: true,
                        otherTitle: 'Other Relationship',
                        otherHint: 'Enter relationship',
                        onSelected: (value) {
                          setState(() {
                            selectedRelationship = value;
                          });
                        },
                      );
                    },
                  ),
                  _buildDropdownTile(
                    title: 'Include',
                    value: selectedInclude,
                    icon: Icons.add_circle_outline_rounded,
                    onTap: () {
                      _showSelector(
                        title: 'Include',
                        values: includeOptions,
                        selectedValue: selectedInclude,
                        allowOther: true,
                        otherTitle: 'Other',
                        otherHint: 'Enter what you want to include',
                        onSelected: (value) {
                          setState(() {
                            selectedInclude = value;
                          });
                        },
                      );
                    },
                  ),
                  _buildDropdownTile(
                    title: 'Closing',
                    value: selectedClosing,
                    icon: Icons.edit_note_rounded,
                    onTap: () {
                      _showSelector(
                        title: 'Closing',
                        values: closingTypes,
                        selectedValue: selectedClosing,
                        allowOther: true,
                        otherTitle: 'Other Closing',
                        otherHint: 'Enter closing',
                        onSelected: (value) {
                          setState(() {
                            selectedClosing = value;
                          });
                        },
                      );
                    },
                  ),
                  const SizedBox(height: 10),
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
              'Create Letter',
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

  Widget _buildMessageSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Message',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: _text(context),
          ),
        ),
        const SizedBox(height: 10),
        Container(
          height: 160,
          decoration: BoxDecoration(
            color: _surface(context),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: _border(context),
            ),
          ),
          child: TextField(
            controller: _messageController,
            maxLines: null,
            expands: true,
            textAlignVertical: TextAlignVertical.top,
            style: TextStyle(
              fontSize: 14,
              height: 1.45,
              color: _bodyText(context),
            ),
            decoration: InputDecoration(
              hintText: 'Write Message',
              hintStyle: TextStyle(
                color: _hint(context),
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.all(15),
            ),
          ),
        ),
      ],
    );
  }

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
          style: TextStyle(
            fontSize: 15,
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
            controller: controller,
            style: TextStyle(
              fontSize: 14,
              color: _bodyText(context),
            ),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(
                fontSize: 14,
                color: _hint(context),
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

  Widget _buildDropdownTile({
    required String title,
    required String value,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 11),
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
                  borderRadius: BorderRadius.circular(11),
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
                  crossAxisAlignment: CrossAxisAlignment.start,
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

  Widget _buildLengthSection() {
    const values = [
      'Short',
      'Medium',
      'Long',
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Length',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: _text(context),
          ),
        ),
        const SizedBox(height: 12),
        Container(
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
              final selected = selectedLength == value;

              return Expanded(
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedLength = value;
                    });
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
                        fontWeight: selected
                            ? FontWeight.w700
                            : FontWeight.w500,
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
        ),
      ],
    );
  }

  Widget _buildBottomBar() {
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 12),
        decoration: BoxDecoration(
          color: _pageBackground(context),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, -3),
            ),
          ],
        ),
        child: GestureDetector(
          onTap: _createPressed,
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

  void _createPressed() {
    final message = _messageController.text.trim();
    final subject = _subjectController.text.trim();

    if (message.isEmpty) {
      _showAlert(
        title: 'Missing Message',
        message: 'Please enter a message before creating.',
      );
      return;
    }

    if (subject.isEmpty) {
      _showAlert(
        title: 'Missing Subject',
        message: 'Please enter a subject before creating.',
      );
      return;
    }

    debugPrint('message: $message');
    debugPrint('subject: $subject');
    debugPrint('sender: ${_senderController.text.trim()}');
    debugPrint('recipient: ${_recipientController.text.trim()}');
    debugPrint('letterType: $selectedLetterType');
    debugPrint('tone: $selectedTone');
    debugPrint('language: $selectedLanguage');
    debugPrint('delivery: $selectedDelivery');
    debugPrint('relationship: $selectedRelationship');
    debugPrint('include: $selectedInclude');
    debugPrint('closing: $selectedClosing');
    debugPrint('length: $selectedLength');

    final prompt = _buildLetterPrompt();

    debugPrint('========== LETTER PROMPT ==========');
    debugPrint(prompt);
    debugPrint('===================================');

    // API / generation logic later.
    // Send `prompt` to your generation flow when ready.
  }

  String _optionalPromptValue(String value) {
    final trimmed = value.trim();
    return trimmed.isEmpty ? 'Not provided' : trimmed;
  }

  String get _letterLengthRequirement {
    switch (selectedLength) {
      case 'Short':
        switch (selectedDelivery) {
          case 'Text Message':
          case 'Greeting Card':
          case 'Social Media Message':
            return '50–120 words';
          default:
            return '120–200 words';
        }

      case 'Medium':
        switch (selectedDelivery) {
          case 'Text Message':
          case 'Greeting Card':
          case 'Social Media Message':
            return '120–220 words';
          default:
            return '250–400 words';
        }

      case 'Long':
        switch (selectedDelivery) {
          case 'Text Message':
          case 'Greeting Card':
          case 'Social Media Message':
            return '220–350 words';
          default:
            return '500–700 words';
        }

      default:
        return '120–200 words';
    }
  }

  String _buildLetterPrompt() {
    final message = _messageController.text.trim();
    final subject = _subjectController.text.trim();
    final sender = _senderController.text.trim();
    final recipient = _recipientController.text.trim();

    return '''
You are an exceptional professional letter writer with excellent emotional intelligence, empathy, cultural awareness, and linguistic precision.

Create one polished, natural, highly effective letter based on the user's specifications.

The final result must feel genuinely written by a thoughtful human and should never feel like a generic AI template.

LETTER DETAILS

Main Message / Intent:
$message

Letter Type:
$selectedLetterType

Tone:
$selectedTone

Language:
$selectedLanguage

Recipient Relationship:
$selectedRelationship

Delivery Method:
$selectedDelivery

Content to Include:
$selectedInclude

Closing Style:
$selectedClosing

Length:
$selectedLength

Target Length:
$_letterLengthRequirement

Subject:
${_optionalPromptValue(subject)}

Recipient Name:
${_optionalPromptValue(recipient)}

Sender Name:
${_optionalPromptValue(sender)}

PRIMARY OBJECTIVE

First understand what the user genuinely wants to communicate.

Preserve the user's meaning, facts, emotional intent, requests, concerns, and priorities.

Improve clarity, structure, wording, emotional impact, professionalism, and natural flow without changing the user's actual intent.

Do not simply paraphrase the user's input sentence by sentence.

Create a complete and coherent letter suitable for the requested situation.

LETTER TYPE ADAPTATION

Follow the real-world conventions of $selectedLetterType.

Formal, business, recommendation, cover, resignation, complaint, and request letters should be structured, credible, clear, and professionally appropriate.

Personal and informal letters should sound warm, natural, and conversational.

Love letters should feel intimate, sincere, emotionally believable, and not overly dramatic.

Apology letters should acknowledge the situation sincerely, show understanding, and avoid manipulative language.

Thank-you letters should express believable and meaningful gratitude.

Condolence letters should be gentle, compassionate, respectful, and restrained.

Congratulations letters should feel warm and genuinely celebratory.

Invitation letters should clearly communicate the invitation while matching the relationship and tone.

Complaint letters should explain the issue clearly and respectfully.

Request letters should communicate the request clearly without sounding demanding.

RELATIONSHIP AWARENESS

The recipient relationship is $selectedRelationship.

Adapt vocabulary, emotional closeness, formality, warmth, politeness, boundaries, and style naturally to this relationship.

A letter to a spouse should not sound like a letter to a manager.

A message to a close friend should not sound like corporate correspondence.

TONE

Maintain a genuinely ${selectedTone.toLowerCase()} tone throughout.

Express the tone through vocabulary, sentence structure, pacing, warmth, directness, and emotional intensity.

Do not merely insert words associated with the selected tone.

CONTENT TO INCLUDE

Naturally incorporate:
$selectedInclude

Do not create an artificial separate section for it.

Never invent a memory, event, achievement, apology reason, future plan, contact information, or other factual detail that the user did not provide.

DELIVERY METHOD

Adapt the structure and style to $selectedDelivery.

Email:
Use natural email conventions.

Printed Letter:
Use an appropriate polished letter structure.

Handwritten Letter:
Favor warmth and personal flow.

Text Message:
Keep it natural, concise, and appropriate for messaging.

Greeting Card:
Keep it emotionally meaningful and concise.

Social Media Message:
Use conversational direct-message style.

Official Document:
Use clear, formal, precise wording.

LANGUAGE

Write the entire result in $selectedLanguage.

Make it sound as though it was originally written by a fluent native speaker.

Avoid awkward literal translation.

Use culturally appropriate greetings, honorifics, vocabulary, punctuation, and sentence structure.

HUMAN WRITING QUALITY

Use natural sentence-length variation, smooth transitions, clear paragraph progression, and believable emotional restraint.

Avoid:
- generic filler
- robotic phrasing
- repeated ideas
- clichés
- exaggerated sentimentality
- unnecessary flowery wording
- unnecessary formality
- generic AI-style phrases

Every paragraph should serve a clear purpose.

FACTUAL INTEGRITY

Use only information supported by the user's input.

Never invent names, dates, addresses, places, companies, job titles, memories, conversations, incidents, promises, achievements, contact information, or relationship history.

If information is missing, write naturally around it rather than fabricating details.

OPENING

Use a greeting appropriate to the letter type, relationship, tone, language, and delivery method.

If the recipient name is provided, use it naturally.

Do not invent a recipient name.

BODY

Establish the purpose reasonably early.

Preserve all important details supplied by the user.

Organize the message logically.

Maintain smooth transitions and believable emotional progression.

ENDING

End naturally and meaningfully without repeating the entire message.

Use the selected closing style where appropriate:
$selectedClosing

If a sender name was provided, use it naturally after the closing when appropriate.

Never invent a sender name.

SUBJECT

If a subject was provided and the delivery format normally uses one, include it naturally.

If no subject was provided, do not invent one unless clearly needed by the selected format.

LENGTH

Target:
$_letterLengthRequirement

Respect the requested length as closely as practical.

Do not add meaningless filler just to reach the word count.

FINAL QUALITY CHECK

Before responding, silently verify that:
- the user's true intent is preserved
- the letter matches $selectedLetterType
- the relationship $selectedRelationship is reflected naturally
- the tone genuinely feels ${selectedTone.toLowerCase()}
- the writing fits $selectedDelivery
- $selectedInclude is incorporated naturally where appropriate
- no unsupported facts were invented
- the language sounds fluent in $selectedLanguage
- the result does not sound generic
- the result is immediately usable

Do not reveal this quality check.

STRICT OUTPUT RULES

Output only the finished letter or message.

Do not provide explanations, analysis, alternatives, writing advice, notes, or commentary.

Do not write phrases such as:
"Here is your letter"
"Generated Letter"
"Sure, here you go"

Do not include commentary before or after the letter.

Produce exactly one polished final version ready to send.
''';
  }

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
                style: TextStyle(color: _accent(context)),
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
    bool allowOther = false,
    String otherTitle = 'Other',
    String otherHint = 'Enter value',
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: _surface(context),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(24),
        ),
      ),
      builder: (context) {
        return SafeArea(
          child: SizedBox(
            height: MediaQuery.sizeOf(context).height * 0.50,
            child: Column(
              children: [
                const SizedBox(height: 10),
                Container(
                  width: 40,
                  height: 5,
                  decoration: BoxDecoration(
                    color: _isDark(context) ? const Color(0xFF6F5A80) : const Color(0xFFDADADA),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    20,
                    18,
                    20,
                    10,
                  ),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      title,
                      style: TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.w700,
                        color: _text(context),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: values.length,
                    itemBuilder: (context, index) {
                      final value = values[index];

                      return ListTile(
                        title: Text(value, style: TextStyle(color: _bodyText(context))),
                        trailing: value == selectedValue
                            ? Icon(
                          Icons.check_circle_rounded,
                          color: _accent(context),
                        )
                            : null,
                        onTap: () {
                          Navigator.pop(context);

                          if (allowOther && value == 'Other') {
                            _showOtherInput(
                              title: otherTitle,
                              hint: otherHint,
                              onDone: onSelected,
                            );
                          } else {
                            onSelected(value);
                          }
                        },
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

  void _showOtherInput({
    required String title,
    required String hint,
    required ValueChanged<String> onDone,
  }) {
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: _surface(context),
          title: Text(
            title,
            style: TextStyle(color: _text(context)),
          ),
          content: TextField(
            controller: controller,
            autofocus: true,
            style: TextStyle(color: _bodyText(context)),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(color: _hint(context)),
              filled: true,
              fillColor: _surfaceAlt(context),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: _border(context)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: _accent(context)),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text(
                'Cancel',
                style: TextStyle(color: _muted(context)),
              ),
            ),
            TextButton(
              onPressed: () {
                final value = controller.text.trim();

                if (value.isEmpty) {
                  return;
                }

                Navigator.pop(context);
                onDone(value);
              },
              child: Text(
                'Done',
                style: TextStyle(color: _accent(context)),
              ),
            ),
          ],
        );
      },
    );
  }
}