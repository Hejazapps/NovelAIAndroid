Copy these files into lib/screens/:
- chat_screen.dart (replace current file)
- story_chat_screen.dart (new)
- story_chat_history_screen.dart (new)

Your existing ChatScreen UI is preserved. Only behavior was wired.

Working features:
- Existing history clock icon opens Chat History
- Start arrow opens actual Story Chat
- Initial prompt automatically starts the conversation
- Language, genre, length, storyteller name and storyteller prompt are sent in AI context
- Uses existing EasySeekApiManager
- Streaming response
- Stop generation
- Conversation continuity
- Local history persistence: storyChatHistoryV1
- Open old chat and continue it
- Delete history item
- Copy AI response
- Auto title generation
- No subscription/paywall changes
- No new packages required
