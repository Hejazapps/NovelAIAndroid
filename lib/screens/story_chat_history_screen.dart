import 'package:flutter/material.dart';

import 'story_chat_screen.dart';

class StoryChatHistoryScreen extends StatefulWidget {
  const StoryChatHistoryScreen({super.key});

  @override
  State<StoryChatHistoryScreen> createState() => _StoryChatHistoryScreenState();
}

class _StoryChatHistoryScreenState extends State<StoryChatHistoryScreen> {
  static const Color _lightAccent = Color(0xFFFF6435);
  static const Color _darkAccent = Color(0xFF9146E8);

  List<StoryChatSession> _sessions = const [];
  bool _loading = true;

  bool get _isDark => Theme.of(context).brightness == Brightness.dark;
  Color get _accent => _isDark ? _darkAccent : _lightAccent;
  Color get _page => _isDark ? const Color(0xFF140D20) : const Color(0xFFF9F9F9);
  Color get _surface => _isDark ? const Color(0xFF21182E) : Colors.white;
  Color get _text => _isDark ? Colors.white : const Color(0xFF111111);
  Color get _muted => _isDark ? const Color(0xFFB9AEC8) : const Color(0xFF666166);
  Color get _border => _isDark ? const Color(0xFF49305F) : const Color(0xFFE9E6EA);

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final sessions = await StoryChatStore.load();
    if (!mounted) return;
    setState(() {
      _sessions = sessions;
      _loading = false;
    });
  }

  Future<void> _delete(StoryChatSession session) async {
    await StoryChatStore.deleteSession(session.id);
    await _load();
  }

  String _subtitle(StoryChatSession session) {
    for (var i = session.messages.length - 1; i >= 0; i--) {
      final value = session.messages[i].text.trim();
      if (value.isNotEmpty) return value.replaceAll('\n', ' ');
    }
    return session.initialPrompt;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _page,
      appBar: AppBar(
        backgroundColor: _page,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: _text, size: 20),
        ),
        title: Text(
          'Chat History',
          style: TextStyle(color: _text, fontSize: 20, fontWeight: FontWeight.w700),
        ),
        centerTitle: true,
      ),
      body: _loading
          ? Center(child: CircularProgressIndicator(color: _accent))
          : _sessions.isEmpty
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.access_time_rounded, size: 44, color: _muted),
                      const SizedBox(height: 12),
                      Text('No chat history yet', style: TextStyle(color: _text, fontSize: 17, fontWeight: FontWeight.w700)),
                      const SizedBox(height: 5),
                      Text('Your story conversations will appear here.', style: TextStyle(color: _muted, fontSize: 13)),
                    ],
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 30),
                  itemCount: _sessions.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (_, index) {
                    final session = _sessions[index];
                    return Material(
                      color: _surface,
                      borderRadius: BorderRadius.circular(16),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(16),
                        onTap: () async {
                          await Navigator.of(context).push(
                            MaterialPageRoute<void>(
                              builder: (_) => StoryChatScreen(session: session),
                            ),
                          );
                          await _load();
                        },
                        child: Container(
                          padding: const EdgeInsets.fromLTRB(16, 14, 7, 14),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: _border),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 42,
                                height: 42,
                                decoration: BoxDecoration(
                                  color: _accent.withValues(alpha: .12),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(Icons.auto_stories_rounded, color: _accent, size: 21),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      session.title,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(color: _text, fontSize: 15, fontWeight: FontWeight.w700),
                                    ),
                                    const SizedBox(height: 5),
                                    Text(
                                      _subtitle(session),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(color: _muted, fontSize: 12.5, height: 1.3),
                                    ),
                                    const SizedBox(height: 7),
                                    Text(
                                      '${session.genre} • ${session.language}',
                                      style: TextStyle(color: _accent, fontSize: 11, fontWeight: FontWeight.w600),
                                    ),
                                  ],
                                ),
                              ),
                              PopupMenuButton<String>(
                                iconColor: _muted,
                                onSelected: (value) {
                                  if (value == 'delete') _delete(session);
                                },
                                itemBuilder: (_) => const [
                                  PopupMenuItem(value: 'delete', child: Text('Delete')),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
