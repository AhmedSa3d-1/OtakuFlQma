import 'dart:async';

import 'package:otakuflqma/core/account/account_providers.dart';
import 'package:otakuflqma/core/account/animewitcher_account_models.dart';
import 'package:otakuflqma/core/domain/entity/multimedia_item.dart';
import 'package:otakuflqma/core/extensions/base_provider.dart';
import 'package:otakuflqma/core/extensions/extension_manager.dart';
import 'package:otakuflqma/core/extensions/providers/animewitcher_native_provider.dart';
import 'package:otakuflqma/core/storage/settings_repository.dart';
import 'package:otakuflqma/core/storage/storage_service.dart';
import 'package:otakuflqma/features/more/presentation/seasons_screen.dart';
import 'package:otakuflqma/l10n/generated/app_localizations.dart';
import 'package:otakuflqma/shared/widgets/anime_catalog_shimmer.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class _SignedOutAccount extends AnimeWitcherAccountController {
  @override
  Future<AnimeWitcherAccountSnapshot> build() async {
    return const AnimeWitcherAccountSnapshot();
  }
}

class _MemoryStorage extends StorageService {
  @override
  bool isHighQualityPostersEnabled() => false;

  @override
  bool isEpisodeImagesFromAniZipEnabled() => false;
}

class _DelayedSeasonsProvider extends AnimeWitcherNativeProvider {
  _DelayedSeasonsProvider(this.gate)
    : super(Dio(), settingsRepository: SettingsRepository(_MemoryStorage()));

  final Completer<void> gate;

  @override
  Future<AnimeWitcherSeasonConfig> getSeasonConfig() async {
    await gate.future;
    return const AnimeWitcherSeasonConfig(
      past: 'ربيع عام 2026',
      current: 'صيف عام 2026',
      next: 'خريف عام 2026',
    );
  }

  @override
  Future<List<String>> getAllSeasons({bool refresh = false}) async {
    await gate.future;
    return const <String>['صيف عام 2026', 'خريف عام 2026'];
  }

  @override
  Future<ProviderMediaPage> getSeasonPage(
    String season, {
    int offset = 0,
    int limit = 30,
  }) async {
    return const ProviderMediaPage(
      items: <MultimediaItem>[],
      nextOffset: 0,
      hasMore: false,
    );
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('season tabs and season/year skeleton stay visible while loading', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final gate = Completer<void>();
    final provider = _DelayedSeasonsProvider(gate);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          animeWitcherAccountControllerProvider.overrideWith(
            _SignedOutAccount.new,
          ),
          extensionManagerProvider.overrideWithValue(<AnimeWitcherProvider>[
            provider,
          ]),
          activeProviderProvider.overrideWithValue(provider),
        ],
        child: MaterialApp(
          locale: const Locale('ar'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          theme: ThemeData.dark(),
          home: const SeasonsScreen(),
        ),
      ),
    );
    await tester.pump();

    for (final label in const <String>[
      'السابق',
      'الحالي',
      'القادم',
      'المواسم الأخرى',
    ]) {
      expect(find.text(label), findsOneWidget);
    }
    expect(find.byType(SeasonListTitleSkeleton), findsOneWidget);
    expect(
      find.byKey(const ValueKey('season-title-loading-skeleton')),
      findsOneWidget,
    );
    expect(find.byType(AnimeCatalogShimmer), findsOneWidget);

    final tabs = tester.widget<TabBar>(find.byType(TabBar));
    tabs.controller!.animateTo(2);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 350));
    expect(find.text('القادم'), findsOneWidget);
    expect(find.byType(SeasonListTitleSkeleton), findsOneWidget);

    gate.complete();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));
    await tester.pump(const Duration(milliseconds: 50));

    expect(find.byType(SeasonListTitleSkeleton), findsNothing);
    expect(find.text('خريف عام 2026'), findsOneWidget);
  });
}
