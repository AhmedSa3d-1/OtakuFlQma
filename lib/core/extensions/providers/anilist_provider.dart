import 'package:dio/dio.dart';

import '../../domain/entity/multimedia_item.dart';
import '../../network/anilist_client.dart';
import '../base_provider.dart';

class AniListProvider extends AnimeWitcherProvider {
  AniListProvider(Dio dio) : _client = AniListClient(dio);

  final AniListClient _client;

  static const _mediaFields = r'''
    id
    idMal
    title { romaji english native userPreferred }
    coverImage { extraLarge large medium color }
    bannerImage
    description(asHtml: false)
    episodes
    chapters
    volumes
    format
    status
    season
    seasonYear
    averageScore
    meanScore
    popularity
    trending
    favourites
    genres
    duration
    countryOfOrigin
    isAdult
    nextAiringEpisode { airingAt timeUntilAiring episode }
    startDate { year month day }
    endDate { year month day }
    studios(isMain: true) { nodes { name } }
    trailer { id site thumbnail }
    externalLinks { site url }
    relations {
      edges {
        relationType(version: 2)
        node {
          id idMal
          title { romaji english native userPreferred }
          coverImage { extraLarge large medium }
          format
          status
          startDate { year }
          averageScore
        }
      }
    }
    recommendations(perPage: 12, sort: RATING_DESC) {
      nodes {
        mediaRecommendation {
          id idMal
          title { romaji english native userPreferred }
          coverImage { extraLarge large medium }
          format
          status
          startDate { year }
          averageScore
          episodes
        }
      }
    }
    characters(perPage: 12, sort: ROLE) {
      edges {
        role
        node { id name { full native } image { large medium } }
        voiceActors(language: JAPANESE, sort: RELEVANCE) {
          id name { full native } image { large medium }
        }
      }
    }
  ''';

  @override
  String get packageName => 'otakuflqma.anilist';

  @override
  String get name => 'AniList';

  @override
  String get mainUrl => 'https://anilist.co';

  @override
  String get version => '1.0.0';

  @override
  List<String> get languages => const ['ar', 'en'];

  @override
  Set<ProviderType> get supportedTypes => const {
        ProviderType.anime,
        ProviderType.movie,
        ProviderType.series,
        ProviderType.manga,
      };

  // --- Helpers ---

  String _title(Map<dynamic, dynamic>? t) {
    if (t == null) return 'بدون عنوان';
    for (final k in const ['userPreferred', 'romaji', 'english', 'native']) {
      final v = t[k]?.toString().trim() ?? '';
      if (v.isNotEmpty && v != 'null') return v;
    }
    return 'بدون عنوان';
  }

  String _cover(Map<dynamic, dynamic>? c) {
    if (c == null) return '';
    for (final k in const ['extraLarge', 'large', 'medium']) {
      final v = c[k]?.toString().trim() ?? '';
      if (v.isNotEmpty && v != 'null') return v;
    }
    return '';
  }

  MultimediaContentType _contentType(String? format) => switch (format) {
        'MOVIE' => MultimediaContentType.movie,
        'MANGA' || 'NOVEL' || 'ONE_SHOT' => MultimediaContentType.manga,
        _ => MultimediaContentType.anime,
      };

  ShowStatus _status(String? s) => switch (s) {
        'FINISHED' => ShowStatus.completed,
        'NOT_YET_RELEASED' => ShowStatus.upcoming,
        _ => ShowStatus.ongoing,
      };

  String _catalogType(String? format) => switch (format) {
        'TV' || 'TV_SHORT' => 'مسلسل',
        'MOVIE' => 'فيلم',
        'OVA' => 'اوفا',
        'ONA' => 'اونا',
        'SPECIAL' => 'خاصة',
        'MUSIC' => 'موسيقى',
        'MANGA' => 'مانجا',
        'NOVEL' => 'رواية',
        'ONE_SHOT' => 'ون شوت',
        _ => 'مسلسل',
      };

  String _relationLabel(String? type) => switch (type) {
        'PREQUEL' => 'سابق',
        'SEQUEL' => 'لاحق',
        'SIDE_STORY' => 'قصة جانبية',
        'SPIN_OFF' => 'عمل مشتق',
        'PARENT' => 'الأصل',
        'ADAPTATION' => 'اقتباس',
        'ALTERNATIVE' => 'بديل',
        'CHARACTER' => 'شخصية',
        'SUMMARY' => 'ملخص',
        'OTHER' => 'آخر',
        _ => '',
      };

  MultimediaItem _mediaToItem(Map<dynamic, dynamic> m, {String? relationType}) {
    final id = (m['id'] as num?)?.toInt() ?? 0;
    final malId = (m['idMal'] as num?)?.toInt();
    final format = m['format']?.toString();
    final next = m['nextAiringEpisode'];
    NextAiring? nextAiring;
    if (next is Map<dynamic, dynamic>) {
      nextAiring = NextAiring(
        episode: (next['episode'] as num?)?.toInt() ?? 0,
        unixTime: (next['airingAt'] as num?)?.toInt() ?? 0,
      );
    }
    final studios = m['studios'];
    final studioNodes = studios is Map<dynamic, dynamic> ? studios['nodes'] : null;
    final studioName = (studioNodes is List &&
            studioNodes.isNotEmpty &&
            studioNodes.first is Map<dynamic, dynamic>)
        ? (studioNodes.first['name']?.toString() ?? '')
        : '';

    final trailer = m['trailer'];
    final trailers = <Trailer>[];
    if (trailer is Map<dynamic, dynamic> &&
        trailer['site'] == 'youtube' &&
        trailer['id'] != null) {
      trailers.add(Trailer(url: 'https://www.youtube.com/watch?v=${trailer['id']}'));
    }

    final cast = <Actor>[];
    final chars = m['characters'];
    final edges = chars is Map<dynamic, dynamic> ? chars['edges'] : null;
    if (edges is List) {
      for (final e in edges) {
        if (e is! Map<dynamic, dynamic>) continue;
        final node = e['node'];
        if (node is! Map<dynamic, dynamic>) continue;
        final vas = e['voiceActors'];
        Actor? va;
        if (vas is List && vas.isNotEmpty && vas.first is Map<dynamic, dynamic>) {
          final v = vas.first as Map<dynamic, dynamic>;
          final vimg = v['image'];
          va = Actor(
            name: _name(v['name']),
            image: vimg is Map<dynamic, dynamic>
                ? (vimg['large'] ?? vimg['medium'])?.toString()
                : null,
          );
        }
        final img = node['image'];
        cast.add(Actor(
          name: _name(node['name']),
          image: img is Map<dynamic, dynamic>
              ? (img['large'] ?? img['medium'])?.toString()
              : null,
          role: e['role']?.toString(),
          voiceActor: va,
          id: node['id']?.toString(),
        ));
      }
    }

    final related = <MultimediaItem>[];
    final rels = m['relations'];
    final relEdges = rels is Map<dynamic, dynamic> ? rels['edges'] : null;
    if (relEdges is List) {
      for (final e in relEdges) {
        if (e is! Map<dynamic, dynamic>) continue;
        final node = e['node'];
        if (node is! Map<dynamic, dynamic>) continue;
        final rType = e['relationType']?.toString();
        related.add(_mediaToItem(Map<String, dynamic>.from(node), relationType: rType));
      }
    }

    final recs = <MultimediaItem>[];
    final recNodes = (m['recommendations'] is Map<dynamic, dynamic>)
        ? (m['recommendations']['nodes'] as List?)
        : null;
    if (recNodes != null) {
      for (final n in recNodes) {
        if (n is! Map<dynamic, dynamic>) continue;
        final mr = n['mediaRecommendation'];
        if (mr is Map<dynamic, dynamic>) {
          recs.add(_mediaToItem(Map<String, dynamic>.from(mr)));
        }
      }
    }

    final genres = (m['genres'] is List)
        ? (m['genres'] as List).map((e) => e.toString()).toList()
        : <String>[];
    final startDate = m['startDate'];
    final year = startDate is Map<dynamic, dynamic>
        ? (startDate['year'] as num?)?.toInt()
        : null;
    final desc = m['description']
        ?.toString()
        .replaceAll(RegExp(r'<[^>]*>'), '')
        .trim();

    return MultimediaItem(
      title: _title(m['title'] as Map<dynamic, dynamic>?),
      url: 'anilist:$id',
      posterUrl: _cover(m['coverImage'] as Map<dynamic, dynamic>?),
      bannerUrl: m['bannerImage']?.toString(),
      description: (desc != null && desc.isNotEmpty && desc != 'null') ? desc : null,
      contentType: _contentType(format),
      provider: packageName,
      year: year,
      score: (m['averageScore'] as num?)?.toDouble(),
      duration: (m['duration'] as num?)?.toInt(),
      status: _status(m['status']?.toString()),
      tags: genres,
      cast: cast.isEmpty ? null : cast,
      trailers: trailers.isEmpty ? null : trailers,
      recommendations: recs.isEmpty ? null : recs,
      related: related.isEmpty ? null : related,
      relationLabel: relationType != null ? _relationLabel(relationType) : null,
      relationType: relationType,
      isAdult: m['isAdult'] == true,
      nextAiring: nextAiring,
      catalogType: _catalogType(format),
      source: 'AniList',
      syncData: <String, String>{
        'anilistId': '$id',
        if (malId != null) 'malId': '$malId',
        if (malId != null) 'mal_id': '$malId',
        if (studioName.isNotEmpty) 'studio': studioName,
        'episodes': '${(m['episodes'] as num?)?.toInt() ?? 0}',
      },
    );
  }

  String _name(dynamic n) {
    if (n is! Map<dynamic, dynamic>) return '';
    for (final k in const ['full', 'native']) {
      final v = n[k]?.toString().trim() ?? '';
      if (v.isNotEmpty && v != 'null') return v;
    }
    return '';
  }

  // --- Home ---

  @override
  Future<Map<String, List<MultimediaItem>>> getHome() async {
    const q = r'''
query {
  trending: Page(page: 1, perPage: 20) {
    media(type: ANIME, sort: TRENDING_DESC, isAdult: false) {
      id idMal title { romaji english native userPreferred }
      coverImage { extraLarge large medium }
      bannerImage format status averageScore episodes
      startDate { year } nextAiringEpisode { airingAt episode }
      genres studios(isMain: true) { nodes { name } }
    }
  }
  popular: Page(page: 1, perPage: 20) {
    media(type: ANIME, sort: POPULARITY_DESC, isAdult: false) {
      id idMal title { romaji english native userPreferred }
      coverImage { extraLarge large medium }
      format status averageScore episodes startDate { year }
      genres
    }
  }
  seasonal: Page(page: 1, perPage: 20) {
    media(type: ANIME, season: SPRING, seasonYear: 2026, sort: POPULARITY_DESC, isAdult: false) {
      id idMal title { romaji english native userPreferred }
      coverImage { extraLarge large medium }
      format status averageScore episodes startDate { year }
      genres
    }
  }
  topRated: Page(page: 1, perPage: 20) {
    media(type: ANIME, sort: SCORE_DESC, isAdult: false) {
      id idMal title { romaji english native userPreferred }
      coverImage { extraLarge large medium }
      format status averageScore episodes startDate { year }
      genres
    }
  }
}
''';
    final data = await _client.query(q);
    List<MultimediaItem> parse(String key) {
      final page = data[key];
      if (page is! Map<dynamic, dynamic>) return const [];
      final media = page['media'];
      if (media is! List) return const [];
      return media
          .whereType<Map<dynamic, dynamic>>()
          .map((m) => _mediaToItem(Map<String, dynamic>.from(m)))
          .toList();
    }
    return <String, List<MultimediaItem>>{
      'الرائج الآن': parse('trending'),
      'الأكثر شعبية': parse('popular'),
      'أنمي الموسم': parse('seasonal'),
      'الأعلى تقييماً': parse('topRated'),
    };
  }

  // --- Search ---

  @override
  Future<List<MultimediaItem>> search(String query, {CancelToken? cancelToken}) async {
    final page = await searchPage(query, const ProviderSearchFilters(), limit: 30);
    return page.items;
  }

  @override
  Future<ProviderMediaPage> searchPage(
    String query,
    ProviderSearchFilters filters, {
    int offset = 0,
    int limit = 30,
    CancelToken? cancelToken,
  }) async {
    final page = (offset ~/ limit) + 1;
    const q = r'''
query ($search: String, $page: Int, $perPage: Int) {
  Page(page: $page, perPage: $perPage) {
    pageInfo { hasNextPage }
    media(search: $search, type: ANIME, sort: SEARCH_MATCH, isAdult: false) {
      id idMal title { romaji english native userPreferred }
      coverImage { extraLarge large medium }
      format status averageScore episodes startDate { year } genres
    }
  }
}
''';
    final data = await _client.query(q, variables: {
      'search': query,
      'page': page,
      'perPage': limit,
    });
    final pageData = data['Page'] as Map<dynamic, dynamic>? ?? {};
    final media = pageData['media'] as List? ?? [];
    final info = pageData['pageInfo'] as Map<dynamic, dynamic>? ?? {};
    final items = media
        .whereType<Map<dynamic, dynamic>>()
        .map((m) => _mediaToItem(Map<String, dynamic>.from(m)))
        .toList();
    return ProviderMediaPage(
      items: items,
      nextOffset: offset + items.length,
      hasMore: info['hasNextPage'] == true,
    );
  }

  @override
  Future<ProviderMediaPage> searchMangaPage(
    String query,
    ProviderSearchFilters filters, {
    int offset = 0,
    int limit = 30,
    CancelToken? cancelToken,
  }) async {
    final page = (offset ~/ limit) + 1;
    const q = r'''
query ($search: String, $page: Int, $perPage: Int) {
  Page(page: $page, perPage: $perPage) {
    pageInfo { hasNextPage }
    media(search: $search, type: MANGA, sort: SEARCH_MATCH, isAdult: false) {
      id idMal title { romaji english native userPreferred }
      coverImage { extraLarge large medium }
      format status averageScore chapters startDate { year } genres
    }
  }
}
''';
    final data = await _client.query(q, variables: {
      'search': query,
      'page': page,
      'perPage': limit,
    });
    final pageData = data['Page'] as Map<dynamic, dynamic>? ?? {};
    final media = pageData['media'] as List? ?? [];
    final info = pageData['pageInfo'] as Map<dynamic, dynamic>? ?? {};
    final items = media
        .whereType<Map<dynamic, dynamic>>()
        .map((m) => _mediaToItem(Map<String, dynamic>.from(m)))
        .toList();
    return ProviderMediaPage(
      items: items,
      nextOffset: offset + items.length,
      hasMore: info['hasNextPage'] == true,
    );
  }

  // --- Details ---

  @override
  Future<MultimediaItem> getDetails(String url) async {
    final id = _extractId(url);
    const q = '''
query (\$id: Int) {
  Media(id: \$id) {
    $_mediaFields
  }
}
''';
    final data = await _client.query(q, variables: {'id': id});
    final media = data['Media'];
    if (media is! Map) throw Exception('Anime not found');
    return _mediaToItem(Map<String, dynamic>.from(media));
  }

  @override
  Future<MultimediaItem> getMangaDetails(String url) => getDetails(url);

  @override
  Future<List<Episode>> getEpisodes(String url) async {
    // AniList doesn't provide episode streams/URLs; return episode stubs from count
    final id = _extractId(url);
    const q = r'''
query ($id: Int) {
  Media(id: $id) {
    episodes
    nextAiringEpisode { episode }
    streamingEpisodes { title thumbnail url site }
  }
}
''';
    final data = await _client.query(q, variables: {'id': id});
    final media = data['Media'] as Map? ?? {};
    final streaming = media['streamingEpisodes'];
    if (streaming is List && streaming.isNotEmpty) {
      final eps = <Episode>[];
      for (var i = 0; i < streaming.length; i++) {
        final e = streaming[i];
        if (e is! Map) continue;
        final title = e['title']?.toString() ?? 'Episode ${i + 1}';
        // Try to extract episode number from title
        final numMatch = RegExp(r'(\d+)').firstMatch(title);
        final epNum = numMatch != null ? int.tryParse(numMatch.group(1)!) ?? (i + 1) : (i + 1);
        eps.add(Episode(
          name: title,
          url: e['url']?.toString() ?? 'anilist:$id:ep:$epNum',
          posterUrl: e['thumbnail']?.toString(),
          episode: epNum,
        ));
      }
      return eps;
    }
    // Fallback: generate from episode count
    final count = (media['episodes'] as num?)?.toInt() ??
        ((media['nextAiringEpisode'] as Map?)?['episode'] as num?)?.toInt() ??
        0;
    if (count <= 0) return const [];
    return List.generate(count, (i) => Episode(
      name: 'الحلقة ${i + 1}',
      url: 'anilist:$id:ep:${i + 1}',
      episode: i + 1,
    ));
  }

  @override
  Future<List<StreamResult>> loadStreams(String url) async => const [];

  @override
  Future<List<StreamResult>> loadStreamSources(String url) async => const [];

  int _extractId(String url) {
    final match = RegExp(r'anilist:(\d+)').firstMatch(url);
    if (match != null) return int.parse(match.group(1)!);
    final numMatch = RegExp(r'(\d+)').firstMatch(url);
    return numMatch != null ? int.parse(numMatch.group(1)!) : 0;
  }

  @override
  void prepareForNetworkRetry() {}
}
