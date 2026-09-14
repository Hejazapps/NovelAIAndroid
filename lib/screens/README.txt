Put all Dart files in lib/screens/

REPLACE:
- book_screen.dart
- save_vc.dart
- history_screen.dart

ADD:
- book_models.dart
- book_generation_manager.dart
- book_detail_screen.dart

Keep:
- lib/services/easy_seek_api_manager.dart

Included:
- Book saved immediately after outline generation
- Saved after every chapter/status change
- One Book record appears in History while still generating
- Retry failed chapter
- Resume incomplete book
- Back warning while generating
- Per-chapter words + estimated read time
- Total words + full read time
- Completed chapter opens in SaveVc
- Previous / Next chapter buttons in SaveVc like iOS
- 1 / N chapter indicator
- First chapter Previous disabled, last chapter Next disabled
- Chapter text edits save only that chapter
- Font/font size/text styling/background/theme design is shared across every chapter of the same book
- Shared book design persists by bookId
- Book deletion removes generated book data
- History sort support preserved

Local persistent database keys:
generatedBooksV1
textDateEntries
bookDesignV1_<bookId>

Generation continues after leaving Book Detail while the app process remains alive.
If the OS terminates the app, the incomplete book remains saved and can be resumed.

NEW:
- Read Full Book button after chapters become available
- While still generating, it opens all completed chapters together
- Full Book opens inside SaveVc
- Full Book view is read-only so combined text cannot accidentally overwrite one chapter
- Full Book uses the same saved per-book font/theme/background design
- Previous/Next buttons stay available only in individual-chapter reading mode

ADD CHAPTER:
- Add Chapter button appears below Read Full Book
- Chapter title is optional
- "What should happen in this chapter?" is required
- New chapter is appended to the existing book
- Existing chapters are not regenerated
- New chapter is saved immediately as pending
- Status becomes generating, then completed or failed
- Retry still works if the new chapter fails
- History progress and chapter counts update automatically
- No subscription/paywall logic included

CONSISTENCY UPGRADE
- Add Chapter now uses two API stages.
- Stage 1 builds a strict JSON chapter plan from the saved premise, throughline,
  arc, characters, all existing outline beats, and recent actual prose.
- Stage 2 writes the new chapter from that plan.
- Existing chapters are canon and are never regenerated.
- The new planned chapter is saved before prose generation begins.
- Later-added chapters respect the original ending/climax rather than resetting it.
- Normal chapter generation also receives a completed-chapter ledger plus the
  most recent actual prose for stronger continuity.

ADD CHAPTER AVAILABILITY
- Add Chapter is always visible below Read Full Book.
- It is enabled only when every existing chapter is completed.
- If any chapter is pending, generating, or failed, the button stays disabled.
- Failed chapters must be retried/completed before another chapter can be added.
