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
      backgroundColor: const Color(0xFFF9F9F9),
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
              'Create Letter',
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

  Widget _buildMessageSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Message',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1B1B1B),
          ),
        ),
        const SizedBox(height: 10),
        Container(
          height: 160,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: const Color(0xFFE7E7E7),
            ),
          ),
          child: TextField(
            controller: _messageController,
            maxLines: null,
            expands: true,
            textAlignVertical: TextAlignVertical.top,
            style: const TextStyle(
              fontSize: 14,
              height: 1.45,
              color: Color(0xFF222222),
            ),
            decoration: const InputDecoration(
              hintText: 'Write Message',
              hintStyle: TextStyle(
                color: Color(0xFFA0A0A0),
              ),
              border: InputBorder.none,
              contentPadding: EdgeInsets.all(15),
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
          style: const TextStyle(
            fontSize: 15,
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
            controller: controller,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.black,
            ),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: const TextStyle(
                fontSize: 14,
                color: Color(0xFFA0A0A0),
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
                  borderRadius: BorderRadius.circular(11),
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

  Widget _buildLengthSection() {
    const values = [
      'Short',
      'Medium',
      'Long',
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Length',
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
                          ? Colors.white
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(11),
                      boxShadow: selected
                          ? [
                        BoxShadow(
                          color: Colors.black.withValues(
                            alpha: 0.07,
                          ),
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
          color: const Color(0xFFF9F9F9),
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
              child: const Text('OK'),
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
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(24),
        ),
      ),
      builder: (context) {
        return SafeArea(
          child: SizedBox(
            height: MediaQuery.sizeOf(context).height * 0.65,
            child: Column(
              children: [
                const SizedBox(height: 10),
                Container(
                  width: 40,
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
                    10,
                  ),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      title,
                      style: const TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.w700,
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
                        title: Text(value),
                        trailing: value == selectedValue
                            ? const Icon(
                          Icons.check_circle_rounded,
                          color: Color(0xFFFF6435),
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
          title: Text(title),
          content: TextField(
            controller: controller,
            autofocus: true,
            decoration: InputDecoration(
              hintText: hint,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
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
              child: const Text('Done'),
            ),
          ],
        );
      },
    );
  }
}