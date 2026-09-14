Shared Book + Screenplay generation lock

Copy these 3 files to lib/screens/:
- generation_coordinator.dart   (new)
- book_screen.dart              (replace current Book screen)
- screenplay_screen.dart        (replace current Screenplay screen)

Behavior:
- While a Book is generating, Create Screenplay/Create Book shows an alert.
- While a Screenplay is generating, Create Book/Create Screenplay shows an alert.
- Lock stays active during the entire sequential chapter/episode generation.
- Lock releases when generation completes or fails.
- No API request is made by the blocked Create action, so it also prevents accidental duplicate cost.

Alert:
Generation in Progress
A book/screenplay is currently being created. Please wait until it finishes
before starting another book or screenplay.
