import 'dart:async';

import 'package:firebase_database/firebase_database.dart';

abstract class RealtimeDBManagerDelegate {
  void didStartLoading();
  void didStopLoading();

  void didFetchStoryteller(List<StoryTellerItem> items);
  void didFetchItems(List<CustomizeItem> items);
  void didFetchThemes(List<ThemeItem> items);
  void didFetchWriterItems(List<WriterItem> items);
  void didFetchCollections(List<StoryCollection> collections);

  void didFailWithError(Object error);
}

class RealtimeDBManager {
  RealtimeDBManager({
    FirebaseDatabase? database,
    this.delegate,
  }) : _database = database ?? FirebaseDatabase.instance {
    _customizeRef = _database.ref('Customize');
    _writerRef = _database.ref('Writer');
    _collectionsRef = _database.ref('collections');
    _themeWriteRef = _database.ref('PromptList');
    _storyTellerRef = _database.ref('Storyteller');
    _togetherAIModelsRef = _database.ref('togetherAIModels');
  }

  final FirebaseDatabase _database;
  RealtimeDBManagerDelegate? delegate;

  late final DatabaseReference _customizeRef;
  late final DatabaseReference _collectionsRef;
  late final DatabaseReference _writerRef;
  late final DatabaseReference _storyTellerRef;
  late final DatabaseReference _themeWriteRef;
  late final DatabaseReference _togetherAIModelsRef;

  final List<StoryTellerItem> _storyTellerItems = [];
  final List<CustomizeItem> _items = [];
  final List<WriterItem> _itemsWriter = [];
  final List<StoryCollection> _collections = [];
  final List<ThemeItem> _themeWriter = [];
  final List<TogetherAIModelItem> _togetherAIModels = [];

  StreamSubscription<DatabaseEvent>? _themeSubscription;
  StreamSubscription<DatabaseEvent>? _customizeSubscription;
  StreamSubscription<DatabaseEvent>? _writerSubscription;
  StreamSubscription<DatabaseEvent>? _collectionsSubscription;
  StreamSubscription<DatabaseEvent>? _storyTellerSubscription;
  StreamSubscription<DatabaseEvent>? _togetherAIModelsSubscription;

  // ======================================================
  // TOGETHER AI MODELS
  // ======================================================

  Future<List<TogetherAIModelItem>> fetchTogetherAIModels() async {
    try {
      final snapshot = await _togetherAIModelsRef.get();

      if (!snapshot.exists) {
        _togetherAIModels.clear();
        return [];
      }

      final models = <TogetherAIModelItem>[];

      for (final child in snapshot.children) {
        final map = _asStringDynamicMap(child.value);
        if (map == null) continue;

        final model = TogetherAIModelItem.fromMap(map);
        if (model != null) {
          models.add(model);
        }
      }

      _togetherAIModels
        ..clear()
        ..addAll(models);

      return List.unmodifiable(_togetherAIModels);
    } catch (error) {
      delegate?.didFailWithError(error);
      rethrow;
    }
  }

  Future<void> loadTogetherAIModels() async {
    try {
      final models = await fetchTogetherAIModels();

      for (final model in models) {
        // ignore: avoid_print
        print('🤖 ${model.key} → ${model.modelID}');
      }
    } catch (error) {
      // ignore: avoid_print
      print('❌ Together AI models failed: $error');
    }
  }

  void startTogetherAIModelsRealtimeListener() {
    _togetherAIModelsSubscription?.cancel();

    _togetherAIModelsSubscription =
        _togetherAIModelsRef.onValue.listen((event) {
      final models = <TogetherAIModelItem>[];

      for (final child in event.snapshot.children) {
        final map = _asStringDynamicMap(child.value);
        if (map == null) continue;

        final model = TogetherAIModelItem.fromMap(map);
        if (model != null) models.add(model);
      }

      _togetherAIModels
        ..clear()
        ..addAll(models);
    }, onError: (Object error) {
      delegate?.didFailWithError(error);
    });
  }

  // ======================================================
  // THEMES / PromptList
  // ======================================================

  Future<List<ThemeItem>> fetchAllThemes() async {
    delegate?.didStartLoading();

    try {
      final snapshot = await _themeWriteRef.get();

      if (!snapshot.exists) {
        _themeWriter.clear();
        delegate?.didFetchThemes(const []);
        return [];
      }

      final items = _parseThemes(snapshot);

      _themeWriter
        ..clear()
        ..addAll(items);

      delegate?.didFetchThemes(List.unmodifiable(_themeWriter));
      return List.unmodifiable(_themeWriter);
    } catch (error) {
      delegate?.didFailWithError(error);
      rethrow;
    } finally {
      delegate?.didStopLoading();
    }
  }

  void startThemeRealtimeListener() {
    _themeSubscription?.cancel();

    _themeSubscription = _themeWriteRef.onValue.listen((event) {
      final items = _parseThemes(event.snapshot);

      _themeWriter
        ..clear()
        ..addAll(items);

      delegate?.didFetchThemes(List.unmodifiable(_themeWriter));
    }, onError: (Object error) {
      delegate?.didFailWithError(error);
    });
  }

  List<ThemeItem> _parseThemes(DataSnapshot snapshot) {
    final parsedItems = <ThemeItem>[];

    for (final child in snapshot.children) {
      final map = _asStringDynamicMap(child.value);
      if (map == null) continue;

      parsedItems.add(ThemeItem.fromMap(map));
    }

    parsedItems.sort(
      (a, b) => _sortableId(a.id).compareTo(_sortableId(b.id)),
    );

    return parsedItems;
  }

  // ======================================================
  // CUSTOMIZE
  // ======================================================

  Future<List<CustomizeItem>> fetchAllCustomizeItems() async {
    delegate?.didStartLoading();

    try {
      final snapshot = await _customizeRef.get();

      if (!snapshot.exists) {
        _items.clear();
        delegate?.didFetchItems(const []);
        return [];
      }

      final items = _parseCustomizeSnapshot(snapshot);

      _items
        ..clear()
        ..addAll(items);

      delegate?.didFetchItems(List.unmodifiable(_items));
      return List.unmodifiable(_items);
    } catch (error) {
      delegate?.didFailWithError(error);
      rethrow;
    } finally {
      delegate?.didStopLoading();
    }
  }

  void startCustomizeRealtimeListener() {
    _customizeSubscription?.cancel();

    _customizeSubscription = _customizeRef.onValue.listen((event) {
      final items = _parseCustomizeSnapshot(event.snapshot);

      _items
        ..clear()
        ..addAll(items);

      delegate?.didFetchItems(List.unmodifiable(_items));
    }, onError: (Object error) {
      delegate?.didFailWithError(error);
    });
  }

  List<CustomizeItem> _parseCustomizeSnapshot(DataSnapshot snapshot) {
    final parsedItems = <CustomizeItem>[];

    for (final child in snapshot.children) {
      final map = _asStringDynamicMap(child.value);
      if (map == null) continue;

      parsedItems.add(CustomizeItem.fromMap(map));
    }

    parsedItems.sort(
      (a, b) => _sortableId(a.id).compareTo(_sortableId(b.id)),
    );

    return parsedItems;
  }

  Future<CustomizeItem?> fetchCustomizeItemById(String itemId) async {
    try {
      final snapshot = await _customizeRef.child(itemId).get();

      if (!snapshot.exists) return null;

      final map = _asStringDynamicMap(snapshot.value);
      if (map == null) return null;

      return CustomizeItem.fromMap(map);
    } catch (error) {
      delegate?.didFailWithError(error);
      rethrow;
    }
  }

  // ======================================================
  // STORYTELLER
  // ======================================================

  Future<List<StoryTellerItem>> fetchAllStoryTeller() async {
    delegate?.didStartLoading();

    try {
      final snapshot = await _storyTellerRef.get();

      if (!snapshot.exists) {
        _storyTellerItems.clear();
        delegate?.didFetchStoryteller(const []);
        return [];
      }

      final items = _parseStoryTeller(snapshot);

      _storyTellerItems
        ..clear()
        ..addAll(items);

      delegate?.didFetchStoryteller(List.unmodifiable(_storyTellerItems));
      return List.unmodifiable(_storyTellerItems);
    } catch (error) {
      delegate?.didFailWithError(error);
      rethrow;
    } finally {
      delegate?.didStopLoading();
    }
  }

  void startStoryTellerRealtimeListener() {
    _storyTellerSubscription?.cancel();

    _storyTellerSubscription = _storyTellerRef.onValue.listen((event) {
      final items = _parseStoryTeller(event.snapshot);

      _storyTellerItems
        ..clear()
        ..addAll(items);

      delegate?.didFetchStoryteller(List.unmodifiable(_storyTellerItems));
    }, onError: (Object error) {
      delegate?.didFailWithError(error);
    });
  }

  List<StoryTellerItem> _parseStoryTeller(DataSnapshot snapshot) {
    final parsedItems = <StoryTellerItem>[];

    for (final child in snapshot.children) {
      final map = _asStringDynamicMap(child.value);
      if (map == null) continue;

      parsedItems.add(StoryTellerItem.fromMap(map));
    }

    // Same ordering as the Swift version: highest numeric ID first.
    parsedItems.sort(
      (a, b) => _sortableId(b.id).compareTo(_sortableId(a.id)),
    );

    return parsedItems;
  }

  // ======================================================
  // WRITER
  // ======================================================

  Future<List<WriterItem>> fetchAllCustomizeItemsWriter() async {
    delegate?.didStartLoading();

    try {
      final snapshot = await _writerRef.get();

      if (!snapshot.exists) {
        _itemsWriter.clear();
        delegate?.didFetchWriterItems(const []);
        return [];
      }

      final items = _parseWriterSnapshot(snapshot);

      _itemsWriter
        ..clear()
        ..addAll(items);

      delegate?.didFetchWriterItems(List.unmodifiable(_itemsWriter));
      return List.unmodifiable(_itemsWriter);
    } catch (error) {
      delegate?.didFailWithError(error);
      rethrow;
    } finally {
      delegate?.didStopLoading();
    }
  }

  void startWriterRealtimeListener() {
    _writerSubscription?.cancel();

    _writerSubscription = _writerRef.onValue.listen((event) {
      final items = _parseWriterSnapshot(event.snapshot);

      _itemsWriter
        ..clear()
        ..addAll(items);

      delegate?.didFetchWriterItems(List.unmodifiable(_itemsWriter));
    }, onError: (Object error) {
      delegate?.didFailWithError(error);
    });
  }

  List<WriterItem> _parseWriterSnapshot(DataSnapshot snapshot) {
    final parsedItems = <WriterItem>[];

    for (final child in snapshot.children) {
      final map = _asStringDynamicMap(child.value);
      if (map == null) continue;

      parsedItems.add(WriterItem.fromMap(map));
    }

    parsedItems.sort(
      (a, b) => _sortableId(a.id).compareTo(_sortableId(b.id)),
    );

    return parsedItems;
  }

  // ======================================================
  // COLLECTIONS
  // ======================================================

  Future<List<StoryCollection>> fetchAllCollections() async {
    delegate?.didStartLoading();

    // ignore: avoid_print
    print('🔥 COLLECTIONS DEBUG =====================================');
    // ignore: avoid_print
    print('🔥 fetchAllCollections() START');
    // ignore: avoid_print
    print('🔥 Database URL: ${_database.databaseURL}');
    // ignore: avoid_print
    print('🔥 Reading Firebase node: collections');

    try {
      final snapshot = await _collectionsRef.get();

      // ignore: avoid_print
      print('🔥 Firebase request completed');
      // ignore: avoid_print
      print('🔥 snapshot.exists: ${snapshot.exists}');
      // ignore: avoid_print
      print('🔥 snapshot.key: ${snapshot.key}');
      // ignore: avoid_print
      print('🔥 snapshot.value type: ${snapshot.value.runtimeType}');
      // ignore: avoid_print
      print('🔥 direct child count: ${snapshot.children.length}');

      if (!snapshot.exists || snapshot.value == null) {
        // ignore: avoid_print
        print('❌ collections node is EMPTY / DOES NOT EXIST');

        _collections.clear();
        delegate?.didFetchCollections(const []);
        return [];
      }

      // Do not print the entire database payload because story data can be large.
      // Instead print every collection key and parsing result.
      final collections = _parseCollectionsSnapshot(snapshot);

      // ignore: avoid_print
      print('✅ Parsed collection count: ${collections.length}');

      for (var i = 0; i < collections.length; i++) {
        final collection = collections[i];

        // ignore: avoid_print
        print(
          '✅ Collection[$i] name="${collection.name}" '
          'stories=${collection.stories.length}',
        );

        for (var j = 0; j < collection.stories.length && j < 3; j++) {
          final story = collection.stories[j];

          // ignore: avoid_print
          print(
            '   📖 Story[$j] title="${story.title}" '
            'thumb="${story.thumbUrl}" '
            'original="${story.originalUrl}"',
          );
        }

        if (collection.stories.length > 3) {
          // ignore: avoid_print
          print('   ... ${collection.stories.length - 3} more stories');
        }
      }

      _collections
        ..clear()
        ..addAll(collections);

      delegate?.didFetchCollections(List.unmodifiable(_collections));

      // ignore: avoid_print
      print('🔥 fetchAllCollections() SUCCESS');
      // ignore: avoid_print
      print('🔥 COLLECTIONS DEBUG END =================================');

      return List.unmodifiable(_collections);
    } catch (error, stackTrace) {
      // ignore: avoid_print
      print('❌ COLLECTIONS FIREBASE/PARSING ERROR');
      // ignore: avoid_print
      print('❌ Error: $error');
      // ignore: avoid_print
      print('❌ Error type: ${error.runtimeType}');
      // ignore: avoid_print
      print('❌ StackTrace: $stackTrace');
      // ignore: avoid_print
      print('🔥 COLLECTIONS DEBUG END =================================');

      delegate?.didFailWithError(error);
      rethrow;
    } finally {
      delegate?.didStopLoading();
    }
  }

  void startCollectionsRealtimeListener() {
    _collectionsSubscription?.cancel();

    _collectionsSubscription = _collectionsRef.onValue.listen((event) {
      final collections = _parseCollectionsSnapshot(event.snapshot);

      _collections
        ..clear()
        ..addAll(collections);

      delegate?.didFetchCollections(List.unmodifiable(_collections));
    }, onError: (Object error) {
      delegate?.didFailWithError(error);
    });
  }

  List<StoryCollection> _parseCollectionsSnapshot(DataSnapshot snapshot) {
    final parsedCollections = <StoryCollection>[];

    var firebaseIndex = 0;

    for (final child in snapshot.children) {
      // ignore: avoid_print
      print('----------------------------------------------------------');
      // ignore: avoid_print
      print(
        '🔥 Firebase collection[$firebaseIndex] '
        'key="${child.key}" type=${child.value.runtimeType}',
      );

      final map = _asStringDynamicMap(child.value);

      if (map == null) {
        // ignore: avoid_print
        print(
          '❌ SKIPPED collection key="${child.key}" '
          'because value is not a Map',
        );
        firebaseIndex++;
        continue;
      }

      // ignore: avoid_print
      print('🔥 Collection fields: ${map.keys.toList()}');
      // ignore: avoid_print
      print('🔥 name raw value: ${map['name']}');

      final rawStories = map['stories'];

      // ignore: avoid_print
      print('🔥 stories raw type: ${rawStories.runtimeType}');

      if (rawStories is List) {
        // ignore: avoid_print
        print('🔥 stories list length: ${rawStories.length}');
      } else if (rawStories is Map) {
        // ignore: avoid_print
        print('🔥 stories map length: ${rawStories.length}');
        // ignore: avoid_print
        print('🔥 stories map keys: ${rawStories.keys.take(10).toList()}');
      } else if (rawStories == null) {
        // ignore: avoid_print
        print('⚠️ stories field is NULL');
      } else {
        // ignore: avoid_print
        print(
          '⚠️ Unsupported stories type: ${rawStories.runtimeType}',
        );
      }

      try {
        final collection = StoryCollection.fromMap(map);

        // ignore: avoid_print
        print(
          '✅ Parsed Firebase key="${child.key}" → '
          'name="${collection.name}", '
          'stories=${collection.stories.length}',
        );

        parsedCollections.add(collection);
      } catch (error, stackTrace) {
        // ignore: avoid_print
        print('❌ Failed parsing collection key="${child.key}"');
        // ignore: avoid_print
        print('❌ Parsing error: $error');
        // ignore: avoid_print
        print('❌ Parsing stack: $stackTrace');
      }

      firebaseIndex++;
    }

    // ignore: avoid_print
    print('----------------------------------------------------------');
    // ignore: avoid_print
    print(
      '🔥 Collection parser finished. '
      'Firebase children=${snapshot.children.length}, '
      'parsed=${parsedCollections.length}',
    );

    return parsedCollections;
  }

  Future<StoryCollection?> fetchCollectionByIndex(int index) async {
    try {
      final snapshot = await _collectionsRef.child('$index').get();

      if (!snapshot.exists) return null;

      final map = _asStringDynamicMap(snapshot.value);
      if (map == null) return null;

      return StoryCollection.fromMap(map);
    } catch (error) {
      delegate?.didFailWithError(error);
      rethrow;
    }
  }

  // ======================================================
  // GETTERS
  // ======================================================

  List<CustomizeItem> getAllCustomizeItems() => List.unmodifiable(_items);

  List<StoryCollection> getAllCollections() =>
      List.unmodifiable(_collections);

  List<WriterItem> getAllWriterItems() => List.unmodifiable(_itemsWriter);

  List<StoryTellerItem> getAllStoryTellerItems() =>
      List.unmodifiable(_storyTellerItems);

  List<ThemeItem> getAllThemes() => List.unmodifiable(_themeWriter);

  List<TogetherAIModelItem> getAllTogetherAIModels() =>
      List.unmodifiable(_togetherAIModels);

  // ======================================================
  // STOP LISTENING / DISPOSE
  // ======================================================

  Future<void> stopListening() async {
    await Future.wait([
      if (_themeSubscription != null) _themeSubscription!.cancel(),
      if (_customizeSubscription != null) _customizeSubscription!.cancel(),
      if (_writerSubscription != null) _writerSubscription!.cancel(),
      if (_collectionsSubscription != null) _collectionsSubscription!.cancel(),
      if (_storyTellerSubscription != null)
        _storyTellerSubscription!.cancel(),
      if (_togetherAIModelsSubscription != null)
        _togetherAIModelsSubscription!.cancel(),
    ]);

    _themeSubscription = null;
    _customizeSubscription = null;
    _writerSubscription = null;
    _collectionsSubscription = null;
    _storyTellerSubscription = null;
    _togetherAIModelsSubscription = null;
  }

  Future<void> dispose() => stopListening();

  // ======================================================
  // HELPERS
  // ======================================================

  static int _sortableId(String? value) =>
      int.tryParse(value ?? '') ?? 0x7fffffff;

  static Map<String, dynamic>? _asStringDynamicMap(Object? value) {
    if (value is! Map) return null;

    return value.map(
      (key, value) => MapEntry(key.toString(), value),
    );
  }
}

// ======================================================
// MODELS
// ======================================================

class TogetherAIModelItem {
  const TogetherAIModelItem({
    required this.key,
    required this.modelID,
  });

  final String key;
  final String modelID;

  static TogetherAIModelItem? fromMap(Map<String, dynamic> map) {
    final key = map['key']?.toString() ?? '';
    final modelID = map['modelID']?.toString() ?? '';

    if (key.isEmpty || modelID.isEmpty) return null;

    return TogetherAIModelItem(
      key: key,
      modelID: modelID,
    );
  }

  Map<String, dynamic> toMap() => {
        'key': key,
        'modelID': modelID,
      };

  static const List<TogetherAIModelItem> fallbackModels = [
    TogetherAIModelItem(
      key: 'deepSeek_V4_Pro',
      modelID: 'deepseek-ai/DeepSeek-V4-Pro',
    ),
    TogetherAIModelItem(
      key: 'gptOSS120B',
      modelID: 'openai/gpt-oss-120b',
    ),
    TogetherAIModelItem(
      key: 'kimiK2_5',
      modelID: 'moonshotai/Kimi-K2.5',
    ),
    TogetherAIModelItem(
      key: 'miniMaxM2_5',
      modelID: 'MiniMaxAI/MiniMax-M2.5',
    ),
    TogetherAIModelItem(
      key: 'glm5',
      modelID: 'zai-org/GLM-5',
    ),
  ];
}

class CustomizeItem {
  const CustomizeItem({
    required this.id,
    required this.imageId,
    required this.original,
    required this.thumbnail,
  });

  final String id;
  final String imageId;
  final String original;
  final String thumbnail;

  factory CustomizeItem.fromMap(Map<String, dynamic> map) {
    return CustomizeItem(
      id: map['id']?.toString() ?? '',
      imageId: map['imageId']?.toString() ?? '',
      original: map['original']?.toString() ?? '',
      thumbnail: map['thumbnail']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'imageId': imageId,
        'original': original,
        'thumbnail': thumbnail,
      };
}

class StoryTellerItem {
  const StoryTellerItem({
    required this.id,
    required this.imageUrl,
    required this.description,
    required this.prompt,
    required this.name,
    required this.purpose,
  });

  final String id;
  final String imageUrl;
  final String description;
  final String prompt;
  final String name;
  final String purpose;

  factory StoryTellerItem.fromMap(Map<String, dynamic> map) {
    return StoryTellerItem(
      id: map['id']?.toString() ?? '',
      imageUrl: map['imageUrl']?.toString() ?? '',
      description: map['description']?.toString() ?? '',
      prompt: map['prompt']?.toString() ?? '',
      name: map['name']?.toString() ?? '',
      purpose: map['purpose']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'imageUrl': imageUrl,
        'description': description,
        'prompt': prompt,
        'name': name,
        'purpose': purpose,
      };
}

class ThemeItem {
  const ThemeItem({
    required this.id,
    required this.name,
    required this.url,
  });

  final String id;
  final String name;
  final String url;

  factory ThemeItem.fromMap(Map<String, dynamic> map) {
    return ThemeItem(
      id: map['id']?.toString() ?? '',
      name: map['name']?.toString() ?? '',
      url: map['url']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'url': url,
      };
}

class WriterItem {
  const WriterItem({
    required this.id,
    required this.name,
    required this.url,
  });

  final String id;
  final String name;
  final String url;

  factory WriterItem.fromMap(Map<String, dynamic> map) {
    return WriterItem(
      id: map['id']?.toString() ?? '',
      name: map['name']?.toString() ?? '',
      url: map['url']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'url': url,
      };
}

class Story {
  const Story({
    this.originalUrl,
    this.summary,
    this.theme,
    this.thumbUrl,
    this.title,
  });

  final String? originalUrl;
  final String? summary;
  final String? theme;
  final String? thumbUrl;
  final String? title;

  factory Story.fromMap(Map<String, dynamic> map) {
    return Story(
      originalUrl: map['originalUrl']?.toString() ?? '',
      summary: map['summary']?.toString() ?? '',
      theme: map['theme']?.toString() ?? '',
      thumbUrl: map['thumbUrl']?.toString() ?? '',
      title: map['title']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toMap() => {
        'originalUrl': originalUrl,
        'summary': summary,
        'theme': theme,
        'thumbUrl': thumbUrl,
        'title': title,
      };
}

class StoryCollection {
  const StoryCollection({
    required this.name,
    required this.stories,
  });

  final String name;
  final List<Story> stories;

  factory StoryCollection.fromMap(Map<String, dynamic> map) {
    final rawStories = map['stories'];
    final parsedStories = <Story>[];

    if (rawStories is List) {
      for (final raw in rawStories) {
        final storyMap = RealtimeDBManager._asStringDynamicMap(raw);
        if (storyMap != null) {
          parsedStories.add(Story.fromMap(storyMap));
        }
      }
    } else if (rawStories is Map) {
      // Supports Firebase data where "stories" is keyed rather than an array.
      for (final raw in rawStories.values) {
        final storyMap = RealtimeDBManager._asStringDynamicMap(raw);
        if (storyMap != null) {
          parsedStories.add(Story.fromMap(storyMap));
        }
      }
    }

    return StoryCollection(
      name: map['name']?.toString() ?? '',
      stories: parsedStories,
    );
  }

  Map<String, dynamic> toMap() => {
        'name': name,
        'stories': stories.map((story) => story.toMap()).toList(),
      };
}
