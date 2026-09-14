Flutter Chat feature

Files:
- chat_screen.dart
- chat_view_model.dart
- chat_models.dart

Put all 3 in:
  lib/screens/

The implementation uses your existing:
  ../services/easy_seek_api_manager.dart

It does NOT modify the API manager.

Included:
- streaming AI response
- stop generation
- retry last answer
- conversation continuity using recent messages
- local conversation persistence
- automatic title generation using EasySeekApiManager.generateTitle
- chat history sheet
- delete conversation
- new conversation
- copy AI response
- auto-scroll
- dark/light mode
- no subscription/paywall logic

Storage:
  chatConversationsV1

Cost control:
- only the latest 12 messages are sent as context
- chat output maxTokens is 1200
- title generation occurs only for a new untitled conversation

To connect it to your existing Chat tab, make the tab page:
  const ChatScreen()

Important:
Your uploaded iOS ZIP contains ChatMessage.swift, ChatViewModel.swift,
CreateCharacterVc.swift and StoryChatViewController.swift.
It does NOT contain StoryChatViewModel.swift, so this package ports the
complete generic Chat tab behavior and the common streaming/persistence
behavior visible in those files. Story-specific memory/prompt behavior
cannot be reproduced exactly without StoryChatViewModel.swift.
