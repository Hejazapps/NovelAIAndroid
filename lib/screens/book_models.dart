enum BookChapterStatus { pending, generating, completed, failed }

class BookCharacterSpec {
  final String name;
  final String description;
  const BookCharacterSpec({required this.name, required this.description});

  Map<String, dynamic> toJson() => {'name': name, 'description': description};

  factory BookCharacterSpec.fromJson(Map<String, dynamic> json) =>
      BookCharacterSpec(
        name: (json['name'] ?? '').toString(),
        description: (json['description'] ?? '').toString(),
      );
}

class BookGenerationSpec {
  final String title;
  final String bookDescription;
  final String author;
  final String language;
  final String tone;
  final String category;
  final String length;
  final int chapterCount;
  final String ageGroup;
  final List<BookCharacterSpec> characters;

  const BookGenerationSpec({
    required this.title,
    required this.bookDescription,
    required this.author,
    required this.language,
    required this.tone,
    required this.category,
    required this.length,
    required this.chapterCount,
    required this.ageGroup,
    required this.characters,
  });

  Map<String, dynamic> toJson() => {
        'title': title,
        'bookDescription': bookDescription,
        'author': author,
        'language': language,
        'tone': tone,
        'category': category,
        'length': length,
        'chapterCount': chapterCount,
        'ageGroup': ageGroup,
        'characters': characters.map((e) => e.toJson()).toList(),
      };

  factory BookGenerationSpec.fromJson(Map<String, dynamic> json) =>
      BookGenerationSpec(
        title: (json['title'] ?? '').toString(),
        bookDescription: (json['bookDescription'] ?? '').toString(),
        author: (json['author'] ?? '').toString(),
        language: (json['language'] ?? 'English').toString(),
        tone: (json['tone'] ?? 'Standard').toString(),
        category: (json['category'] ?? '').toString(),
        length: (json['length'] ?? 'Short').toString(),
        chapterCount: _intValue(json['chapterCount'], 1),
        ageGroup: (json['ageGroup'] ?? 'Adults (18+)').toString(),
        characters: (json['characters'] as List? ?? const [])
            .whereType<Map>()
            .map((e) => BookCharacterSpec.fromJson(Map<String, dynamic>.from(e)))
            .toList(),
      );
}

class BookOutlineChapter {
  final String title;
  final String mode;
  final String setting;
  final String timeframe;
  final List<String> focusCharacters;
  final String beat;
  final String advances;

  const BookOutlineChapter({
    required this.title,
    required this.mode,
    required this.setting,
    required this.timeframe,
    required this.focusCharacters,
    required this.beat,
    required this.advances,
  });

  Map<String, dynamic> toJson() => {
        'title': title,
        'mode': mode,
        'setting': setting,
        'timeframe': timeframe,
        'focusCharacters': focusCharacters,
        'beat': beat,
        'advances': advances,
      };

  factory BookOutlineChapter.fromJson(Map<String, dynamic> json) =>
      BookOutlineChapter(
        title: (json['title'] ?? '').toString(),
        mode: (json['mode'] ?? '').toString(),
        setting: (json['setting'] ?? '').toString(),
        timeframe: (json['timeframe'] ?? '').toString(),
        focusCharacters: (json['focusCharacters'] as List? ?? const [])
            .map((e) => e.toString())
            .toList(),
        beat: (json['beat'] ?? '').toString(),
        advances: (json['advances'] ?? '').toString(),
      );
}

class BookOutline {
  final String title;
  final String premise;
  final String throughline;
  final String arc;
  final String cost;
  final int climaxChapter;
  final List<BookOutlineChapter> chapters;

  const BookOutline({
    required this.title,
    required this.premise,
    required this.throughline,
    required this.arc,
    required this.cost,
    required this.climaxChapter,
    required this.chapters,
  });

  Map<String, dynamic> toJson() => {
        'title': title,
        'premise': premise,
        'throughline': throughline,
        'arc': arc,
        'cost': cost,
        'climaxChapter': climaxChapter,
        'chapters': chapters.map((e) => e.toJson()).toList(),
      };

  factory BookOutline.fromJson(Map<String, dynamic> json) => BookOutline(
        title: (json['title'] ?? '').toString(),
        premise: (json['premise'] ?? '').toString(),
        throughline: (json['throughline'] ?? '').toString(),
        arc: (json['arc'] ?? '').toString(),
        cost: (json['cost'] ?? '').toString(),
        climaxChapter: _intValue(json['climaxChapter'], 1),
        chapters: (json['chapters'] as List? ?? const [])
            .whereType<Map>()
            .map((e) => BookOutlineChapter.fromJson(Map<String, dynamic>.from(e)))
            .toList(),
      );
}

class GeneratedBookChapter {
  final int number;
  final String title;
  final String content;
  final BookChapterStatus status;
  final String errorMessage;

  const GeneratedBookChapter({
    required this.number,
    required this.title,
    this.content = '',
    this.status = BookChapterStatus.pending,
    this.errorMessage = '',
  });

  int get wordCount {
    final value = content.trim();
    if (value.isEmpty) return 0;
    return value
        .split(RegExp(r'\s+'))
        .where((word) => word.trim().isNotEmpty)
        .length;
  }

  int get estimatedReadMinutes {
    if (wordCount == 0) return 0;
    return (wordCount / 200).ceil();
  }

  GeneratedBookChapter copyWith({
    String? content,
    BookChapterStatus? status,
    String? errorMessage,
  }) =>
      GeneratedBookChapter(
        number: number,
        title: title,
        content: content ?? this.content,
        status: status ?? this.status,
        errorMessage: errorMessage ?? this.errorMessage,
      );

  Map<String, dynamic> toJson() => {
        'number': number,
        'title': title,
        'content': content,
        'status': status.name,
        'errorMessage': errorMessage,
      };

  factory GeneratedBookChapter.fromJson(Map<String, dynamic> json) {
    final statusName = (json['status'] ?? 'pending').toString();
    return GeneratedBookChapter(
      number: _intValue(json['number'], 1),
      title: (json['title'] ?? '').toString(),
      content: (json['content'] ?? '').toString(),
      status: BookChapterStatus.values.firstWhere(
        (e) => e.name == statusName,
        orElse: () => BookChapterStatus.pending,
      ),
      errorMessage: (json['errorMessage'] ?? '').toString(),
    );
  }
}

class GeneratedBook {
  final String id;
  final BookGenerationSpec spec;
  final BookOutline outline;
  final List<GeneratedBookChapter> chapters;
  final bool isGenerating;
  final bool isCompleted;
  final DateTime createdAt;
  final DateTime updatedAt;

  const GeneratedBook({
    required this.id,
    required this.spec,
    required this.outline,
    required this.chapters,
    required this.isGenerating,
    required this.isCompleted,
    required this.createdAt,
    required this.updatedAt,
  });

  int get completedChapterCount =>
      chapters.where((e) => e.status == BookChapterStatus.completed).length;

  int get totalWordCount =>
      chapters.fold(0, (sum, chapter) => sum + chapter.wordCount);

  int get estimatedReadMinutes {
    if (totalWordCount == 0) return 0;
    return (totalWordCount / 200).ceil();
  }

  GeneratedBook copyWith({
    List<GeneratedBookChapter>? chapters,
    bool? isGenerating,
    bool? isCompleted,
    DateTime? updatedAt,
  }) =>
      GeneratedBook(
        id: id,
        spec: spec,
        outline: outline,
        chapters: chapters ?? this.chapters,
        isGenerating: isGenerating ?? this.isGenerating,
        isCompleted: isCompleted ?? this.isCompleted,
        createdAt: createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'spec': spec.toJson(),
        'outline': outline.toJson(),
        'chapters': chapters.map((e) => e.toJson()).toList(),
        'isGenerating': isGenerating,
        'isCompleted': isCompleted,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
      };

  factory GeneratedBook.fromJson(Map<String, dynamic> json) => GeneratedBook(
        id: (json['id'] ?? '').toString(),
        spec: BookGenerationSpec.fromJson(
          Map<String, dynamic>.from(json['spec'] as Map? ?? const {}),
        ),
        outline: BookOutline.fromJson(
          Map<String, dynamic>.from(json['outline'] as Map? ?? const {}),
        ),
        chapters: (json['chapters'] as List? ?? const [])
            .whereType<Map>()
            .map((e) => GeneratedBookChapter.fromJson(Map<String, dynamic>.from(e)))
            .toList(),
        isGenerating: json['isGenerating'] == true,
        isCompleted: json['isCompleted'] == true,
        createdAt: DateTime.tryParse((json['createdAt'] ?? '').toString()) ?? DateTime.now(),
        updatedAt: DateTime.tryParse((json['updatedAt'] ?? '').toString()) ?? DateTime.now(),
      );
}

int _intValue(dynamic value, int fallback) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value?.toString() ?? '') ?? fallback;
}
