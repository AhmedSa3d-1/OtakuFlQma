import 'dart:async';

import 'package:otakuflqma/core/domain/entity/multimedia_item.dart';
import 'package:otakuflqma/core/extensions/extension_manager.dart';
import 'package:otakuflqma/core/extensions/providers/animewitcher_native_provider.dart';
import 'package:otakuflqma/core/storage/settings_repository.dart';
import 'package:otakuflqma/core/storage/storage_service.dart';
import 'package:otakuflqma/features/details/presentation/extra_anime_list_screen.dart';
import 'package:otakuflqma/shared/widgets/anime_catalog_shimmer.dart';
import 'package:otakuflqma/shared/widgets/app_page_header.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class _MemoryStorage extends StorageService {
  @override
  bool isHighQualityPostersEnabled() => false;

  @override
  bool isEpisodeImagesFromAniZipEnabled() => false;
}

void main() {
  testWidgets('loading posters start below the progressive header', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final gate = Completer<List<MultimediaItem>>();
    final provider = AnimeWitcherNativeProvider(
      Dio(),
      settingsRepository: SettingsRepository(_MemoryStorage()),
    );
    await tester.pumpWidget(
      ProviderScope(
        overrides: [activeProviderProvider.overrideWithValue(provider)],
        child: MaterialApp(
          theme: ThemeData.dark(),
          home: MediaQuery(
            data: const MediaQueryData(
              size: Size(390, 844),
              padding: EdgeInsets.only(top: 44),
            ),
            child: ExtraAnimeListScreen(
              source: MultimediaItem(
                title: 'Source',
                url: 'test://source',
                posterUrl: '',
              ),
              title: 'Similar anime',
              emptyMessage: 'No titles',
              keyPrefix: 'test',
              load: (_) => gate.future,
            ),
          ),
        ),
      ),
    );
    await tester.pump();
    final header = tester.getRect(find.byType(AppProgressiveHeaderBackdrop));
    final poster = tester.getRect(find.byType(AnimePosterShimmer).first);
    expect(poster.top, greaterThanOrEqualTo(header.bottom));
    expect(find.byType(BackdropFilter), findsWidgets);
    expect(tester.takeException(), isNull);
    gate.complete([]);
    await tester.pump();
  });
}
