import 'package:dio/dio.dart';

import '../../account/animewitcher_character_models.dart';
import '../../domain/entity/multimedia_item.dart';
import '../base_provider.dart';
import 'anilist_provider.dart';

const List<String> animeWitcherBroadcastDays = <String>[
  'السبت',
  'الأحد',
  'الإثنين',
  'الثلاثاء',
  'الأربعاء',
  'الخميس',
  'الجمعة',
];

const int animeWitcherRankingPageSize = 24;

typedef AnimeWitcherMalIdResolver = Future<List<Map<String, dynamic>>> Function(
  Iterable<int> ids,
);

enum AnimeWitcherGlobalRanking {
  topRated('top-rated', 'الأعلى تقييماً'),
  popular('popular', 'الأكثر شعبية'),
  trending('trending', 'الرائج'),
  all('all', 'الكل'),
  continuing('continuing', 'المستمر');

  const AnimeWitcherGlobalRanking(this.queryType, this.arabicTitle);
  final String queryType;
  final String arabicTitle;
}

String _normalizeMangaGenre(String value) {
  final normalized = value
      .trim()
      .replaceAll('ى', 'ي')
      .replaceAll('ئ', 'ي')
      .replaceAll(RegExp(r'\s+'), '')
      .toLowerCase();
  return normalized.isEmpty ? value : normalized;
}

class AnimeWitcherSeasonConfig {
  const AnimeWitcherSeasonConfig({
    this.currentSeason = '',
    this.currentYear = '',
    this.seasons = const <String>[],
    this.past = '',
    this.current = '',
    this.next = '',
  });
  final String currentSeason;
  final String currentYear;
  final List<String> seasons;
  final String past;
  final String current;
  final String next;
}

/// Compatibility shim: OtakuFlQma now uses AniList as the primary data source.
/// This keeps existing imports/call sites working while features are migrated.
class AnimeWitcherNativeProvider extends AniListProvider {
  AnimeWitcherNativeProvider(
    super.dio, {
    dynamic settingsRepository,
    AnimeWitcherMalIdResolver? resolveAnimeByMalIds,
    bool Function()? isEcchiHidden,
  });

  static const List<String> mangaCatalogAttributes = <String>[
    'name',
    'poster',
    'tags',
    'details',
    'type',
  ];

  static bool mangaHitMatchesFilters(
    Map<String, Object?> hit,
    ProviderSearchFilters filters,
  ) {
    if (filters.isEmpty) return true;

    final details = hit['details'];
    final tags = hit['tags'] is Iterable ? hit['tags'] as Iterable : const <Object>[];
    final type = (hit['type'] ?? '').toString();
    final status = details is Map ? (details['status'] ?? '').toString() : '';
    final year = details is Map ? (details['year'] ?? '').toString() : '';

    if (filters.statuses.isNotEmpty &&
        filters.statuses.every((value) => value != status)) {
      return false;
    }
    if (filters.types.isNotEmpty &&
        filters.types.every((value) => value != type)) {
      return false;
    }
    if (filters.years.isNotEmpty &&
        filters.years.every((value) => value != year)) {
      return false;
    }
    if (filters.genres.isNotEmpty) {
      final normalizedTags = tags
          .map((tag) => _normalizeMangaGenre(tag.toString()))
          .toSet();
      for (final genre in filters.genres) {
        final normalizedGenre = _normalizeMangaGenre(genre);
        if (!normalizedTags.contains(normalizedGenre)) {
          return false;
        }
      }
    }
    return true;
  }

  static List<Map<String, Object?>> sortMangaHits(
    List<Map<String, Object?>> hits,
    String sort,
  ) {
    switch (sort) {
      case 'name_asc':
        return List<Map<String, Object?>>.from(
          hits,
        )..sort((left, right) {
          final leftName = (left['name'] ?? '').toString().toLowerCase();
          final rightName = (right['name'] ?? '').toString().toLowerCase();
          return leftName.compareTo(rightName);
        });
      case 'name_desc':
        return List<Map<String, Object?>>.from(
          hits,
        )..sort((left, right) {
          final leftName = (left['name'] ?? '').toString().toLowerCase();
          final rightName = (right['name'] ?? '').toString().toLowerCase();
          return rightName.compareTo(leftName);
        });
      case 'year_asc':
        return List<Map<String, Object?>>.from(
          hits,
        )..sort((left, right) {
          final leftYear = int.tryParse((left['details'] is Map
                  ? (left['details'] as Map)['year'] ?? ''
                  : '')
              .toString()) ?? 0;
          final rightYear = int.tryParse((right['details'] is Map
                  ? (right['details'] as Map)['year'] ?? ''
                  : '')
              .toString()) ?? 0;
          return leftYear.compareTo(rightYear);
        });
      case 'year_desc':
        return List<Map<String, Object?>>.from(
          hits,
        )..sort((left, right) {
          final leftYear = int.tryParse((left['details'] is Map
                  ? (left['details'] as Map)['year'] ?? ''
                  : '')
              .toString()) ?? 0;
          final rightYear = int.tryParse((right['details'] is Map
                  ? (right['details'] as Map)['year'] ?? ''
                  : '')
              .toString()) ?? 0;
          return rightYear.compareTo(leftYear);
        });
      case 'favorites':
      default:
        return hits;
    }
  }

  // Characters - not yet backed by AniList in this app flow
  Future<AnimeWitcherCharacterPage> searchCharacters(String query) async {
    return const AnimeWitcherCharacterPage(
      items: <AnimeWitcherCharacterHit>[],
      hasMore: false,
      page: 0,
    );
  }

  Future<AnimeWitcherCharacterPage> getCharactersPage({int page = 0}) async {
    return const AnimeWitcherCharacterPage(
      items: <AnimeWitcherCharacterHit>[],
      hasMore: false,
      page: 0,
    );
  }

  Future<List<dynamic>> getAnimeCharacters(
    String animeId, {
    int page = 0,
  }) async => const [];

  Future<List<dynamic>> getAnimeCharactersByRole(
    String animeId, [
    String? role,
  ]) async => const [];

  Future<dynamic> getCharacterDocument(String id) async {
    return null;
  }

  Future<dynamic> getCharacterDetails(String id) async {
    return null;
  }

  Future<List<dynamic>> getCharacterAnimes(dynamic idOrDocument) async => const [];

  // Schedule / seasons / coming soon / stats - placeholders for migration
  Future<Map<String, List<MultimediaItem>>> getBroadcastSchedule({
    bool clearCache = false,
  }) async {
    return const <String, List<MultimediaItem>>{};
  }

  Future<ProviderMediaPage> getBroadcastSchedulePage(
    String day, {
    int offset = 0,
    int limit = 30,
    bool? refresh,
    CancelToken? cancelToken,
  }) async {
    return const ProviderMediaPage(
      items: <MultimediaItem>[],
      nextOffset: 0,
      hasMore: false,
    );
  }

  Future<ProviderMediaPage> getComingSoonPage({
    int offset = 0,
    int limit = 30,
  }) async {
    return const ProviderMediaPage(
      items: <MultimediaItem>[],
      nextOffset: 0,
      hasMore: false,
    );
  }

  Future<ProviderMediaPage> getUpcomingPage({
    int offset = 0,
  }) async => getComingSoonPage(offset: offset);

  Future<List<dynamic>> getSeasons() async => const [];
  Future<AnimeWitcherSeasonConfig> getSeasonConfig() async =>
      const AnimeWitcherSeasonConfig();
  Future<List<String>> getAllSeasons() async => const [];
  Future<ProviderMediaPage> getSeasonPage(
    String key, {
    int offset = 0,
  }) async {
    return const ProviderMediaPage(
      items: <MultimediaItem>[],
      nextOffset: 0,
      hasMore: false,
    );
  }

  Future<List<MultimediaItem>> getSeasonAnime(String seasonKey) async => const [];
  Future<Map<String, dynamic>> getGlobalStatistics() async => const <String, dynamic>{};
  Future<ProviderMediaPage> getGlobalRankingPage(
    AnimeWitcherGlobalRanking? ranking, {
    int offset = 0,
    int page = 0,
    int limit = 30,
  }) async {
    return const ProviderMediaPage(
      items: <MultimediaItem>[],
      nextOffset: 0,
      hasMore: false,
    );
  }

  Future<MultimediaItem?> getAnimeById(String id) async => null;
  Future<List<MultimediaItem>> getAnimesByMalIds(List<int> ids) async => const [];
  Future<List<MultimediaItem>> getAnimeCharactersByMalIds(List<dynamic> ids) async => const [];
  Future<List<MultimediaItem>> resolveCatalogAnimeByMalIds(Iterable<dynamic> ids) async => const [];
  Future<ProviderMediaPage> getStudioPage(
    String id, {
    int offset = 0,
    int page = 0,
    int limit = 30,
  }) async {
    return const ProviderMediaPage(
      items: <MultimediaItem>[],
      nextOffset: 0,
      hasMore: false,
    );
  }
}
