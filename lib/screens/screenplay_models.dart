enum ScreenplayEpisodeStatus { pending, generating, completed, failed }

class ScreenplayCharacterSpec {
  final String name;
  final String description;
  const ScreenplayCharacterSpec({required this.name, required this.description});

  Map<String, dynamic> toJson() => {'name': name, 'description': description};

  factory ScreenplayCharacterSpec.fromJson(Map<String, dynamic> json) =>
      ScreenplayCharacterSpec(
        name: (json['name'] ?? '').toString(),
        description: (json['description'] ?? '').toString(),
      );
}

class ScreenplayGenerationSpec {
  final String title;
  final String storyLogline;
  final String synopsis;
  final String writtenBy;
  final String language;
  final String tone;
  final String genre;
  final String sceneLength;
  final String scriptFormat;
  final String includedElements;
  final String contentRating;
  final String settingAndEra;
  final int sceneCount;
  
  final List<ScreenplayCharacterSpec> characters;

  const ScreenplayGenerationSpec({
    required this.title,
    required this.storyLogline,
    required this.synopsis,
    required this.writtenBy,
    required this.language,
    required this.tone,
    required this.genre,
    required this.sceneLength,
    required this.scriptFormat,
    required this.includedElements,
    required this.contentRating,
    required this.settingAndEra,
    required this.sceneCount,
    
    required this.characters,
  });

  Map<String, dynamic> toJson() => {
        'title': title,
        'storyLogline': storyLogline,
        'synopsis': synopsis,
        'writtenBy': writtenBy,
        'language': language,
        'tone': tone,
        'genre': genre,
        'sceneLength': sceneLength,
        'scriptFormat': scriptFormat,
        'includedElements': includedElements,
        'contentRating': contentRating,
        'settingAndEra': settingAndEra,
        'sceneCount': sceneCount,
        
        'characters': characters.map((e) => e.toJson()).toList(),
      };

  factory ScreenplayGenerationSpec.fromJson(Map<String, dynamic> json) =>
      ScreenplayGenerationSpec(
        title: (json['title'] ?? '').toString(),
        storyLogline: (json['storyLogline'] ?? '').toString(),
        synopsis: (json['synopsis'] ?? '').toString(),
        writtenBy: (json['writtenBy'] ?? '').toString(),
        language: (json['language'] ?? 'English').toString(),
        tone: (json['tone'] ?? 'Standard').toString(),
        genre: (json['genre'] ?? '').toString(),
        sceneLength: (json['sceneLength'] ?? 'Medium').toString(),
        scriptFormat: (json['scriptFormat'] ?? 'Standard Screenplay').toString(),
        includedElements: (json['includedElements'] ?? 'Everything').toString(),
        contentRating: (json['contentRating'] ?? 'PG-13 – Ages 13+').toString(),
        settingAndEra: (json['settingAndEra'] ?? 'Present Day').toString(),
        sceneCount: _intValue(json['sceneCount'], 1),
        
        characters: (json['characters'] as List? ?? const [])
            .whereType<Map>()
            .map((e) => ScreenplayCharacterSpec.fromJson(Map<String, dynamic>.from(e)))
            .toList(),
      );
}


extension ScreenplayGenerationSpecTargets on ScreenplayGenerationSpec {
  int get resolvedSceneCount => sceneCount > 0 ? sceneCount : 10;

  String get wordTargetText {
    final value = sceneLength.toLowerCase();
    if (value.contains('short')) return '200-300 words';
    if (value.contains('long')) return '700-900 words';
    return '400-600 words';
  }

  int get maxTokens {
    final value = sceneLength.toLowerCase();
    if (value.contains('short')) return 1800;
    if (value.contains('long')) return 4200;
    return 3000;
  }

  int get characterCap {
    final value = sceneLength.toLowerCase();
    if (value.contains('short')) return 2600;
    if (value.contains('long')) return 7000;
    return 4800;
  }
}

class ScreenplayOutlineEpisode {
  final String title;
  final String mode;
  final String setting;
  final String timeframe;
  final List<String> focusCharacters;
  final String beat;
  final String advances;

  const ScreenplayOutlineEpisode({
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

  factory ScreenplayOutlineEpisode.fromJson(Map<String, dynamic> json) =>
      ScreenplayOutlineEpisode(
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

class ScreenplayOutline {
  final String title;
  final String premise;
  final String throughline;
  final String arc;
  final String cost;
  final int climaxEpisode;
  final List<ScreenplayOutlineEpisode> episodes;

  const ScreenplayOutline({
    required this.title,
    required this.premise,
    required this.throughline,
    required this.arc,
    required this.cost,
    required this.climaxEpisode,
    required this.episodes,
  });

  Map<String, dynamic> toJson() => {
        'title': title,
        'premise': premise,
        'throughline': throughline,
        'arc': arc,
        'cost': cost,
        'climaxEpisode': climaxEpisode,
        'episodes': episodes.map((e) => e.toJson()).toList(),
      };

  factory ScreenplayOutline.fromJson(Map<String, dynamic> json) => ScreenplayOutline(
        title: (json['title'] ?? '').toString(),
        premise: (json['premise'] ?? '').toString(),
        throughline: (json['throughline'] ?? '').toString(),
        arc: (json['arc'] ?? '').toString(),
        cost: (json['cost'] ?? '').toString(),
        climaxEpisode: _intValue(json['climaxEpisode'], 1),
        episodes: (json['episodes'] as List? ?? const [])
            .whereType<Map>()
            .map((e) => ScreenplayOutlineEpisode.fromJson(Map<String, dynamic>.from(e)))
            .toList(),
      );
}

class GeneratedScreenplayEpisode {
  final int number;
  final String title;
  final String content;
  final ScreenplayEpisodeStatus status;
  final String errorMessage;

  const GeneratedScreenplayEpisode({
    required this.number,
    required this.title,
    this.content = '',
    this.status = ScreenplayEpisodeStatus.pending,
    this.errorMessage = '',
  });

  int get wordCount {
    final text = content.trim();
    if (text.isEmpty) return 0;
    return text.split(RegExp(r'\s+')).length;
  }

  int get estimatedReadMinutes {
    if (wordCount == 0) return 0;
    return (wordCount / 200).ceil();
  }

  GeneratedScreenplayEpisode copyWith({
    String? content,
    ScreenplayEpisodeStatus? status,
    String? errorMessage,
  }) =>
      GeneratedScreenplayEpisode(
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

  factory GeneratedScreenplayEpisode.fromJson(Map<String, dynamic> json) {
    final statusName = (json['status'] ?? 'pending').toString();
    return GeneratedScreenplayEpisode(
      number: _intValue(json['number'], 1),
      title: (json['title'] ?? '').toString(),
      content: (json['content'] ?? '').toString(),
      status: ScreenplayEpisodeStatus.values.firstWhere(
        (e) => e.name == statusName,
        orElse: () => ScreenplayEpisodeStatus.pending,
      ),
      errorMessage: (json['errorMessage'] ?? '').toString(),
    );
  }
}

class GeneratedScreenplay {
  final String id;
  final ScreenplayGenerationSpec spec;
  final ScreenplayOutline outline;
  final List<GeneratedScreenplayEpisode> episodes;
  final bool isGenerating;
  final bool isCompleted;
  final DateTime createdAt;
  final DateTime updatedAt;

  const GeneratedScreenplay({
    required this.id,
    required this.spec,
    required this.outline,
    required this.episodes,
    required this.isGenerating,
    required this.isCompleted,
    required this.createdAt,
    required this.updatedAt,
  });

  int get completedEpisodeCount =>
      episodes.where((e) => e.status == ScreenplayEpisodeStatus.completed).length;


  int get totalWordCount => episodes
      .where((e) => e.status == ScreenplayEpisodeStatus.completed)
      .fold<int>(0, (total, episode) => total + episode.wordCount);

  int get estimatedReadMinutes {
    if (totalWordCount == 0) return 0;
    return (totalWordCount / 200).ceil();
  }

  GeneratedScreenplay copyWith({
    List<GeneratedScreenplayEpisode>? episodes,
    bool? isGenerating,
    bool? isCompleted,
    DateTime? updatedAt,
  }) =>
      GeneratedScreenplay(
        id: id,
        spec: spec,
        outline: outline,
        episodes: episodes ?? this.episodes,
        isGenerating: isGenerating ?? this.isGenerating,
        isCompleted: isCompleted ?? this.isCompleted,
        createdAt: createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'spec': spec.toJson(),
        'outline': outline.toJson(),
        'episodes': episodes.map((e) => e.toJson()).toList(),
        'isGenerating': isGenerating,
        'isCompleted': isCompleted,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
      };

  factory GeneratedScreenplay.fromJson(Map<String, dynamic> json) => GeneratedScreenplay(
        id: (json['id'] ?? '').toString(),
        spec: ScreenplayGenerationSpec.fromJson(
          Map<String, dynamic>.from(json['spec'] as Map? ?? const {}),
        ),
        outline: ScreenplayOutline.fromJson(
          Map<String, dynamic>.from(json['outline'] as Map? ?? const {}),
        ),
        episodes: (json['episodes'] as List? ?? const [])
            .whereType<Map>()
            .map((e) => GeneratedScreenplayEpisode.fromJson(Map<String, dynamic>.from(e)))
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
