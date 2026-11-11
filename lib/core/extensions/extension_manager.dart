import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../network/dio_client_provider.dart';
import 'base_provider.dart';
import 'providers/anilist_provider.dart';

part 'extension_manager.g.dart';

/// Built-in provider registry for OtakuFlQma.
@Riverpod(keepAlive: true)
class ExtensionManager extends _$ExtensionManager {
  @override
  List<AnimeWitcherProvider> build() {
    return <AnimeWitcherProvider>[
      AniListProvider(ref.watch(dioClientProvider)),
    ];
  }

  List<AnimeWitcherProvider> getAllProviders() =>
      List<AnimeWitcherProvider>.unmodifiable(state);

  AnimeWitcherProvider? getProvider(String id) {
    final value = id.trim();
    if (value.isEmpty) return null;
    for (final provider in state) {
      if (provider.packageName == value || provider.name == value) {
        return provider;
      }
    }
    return null;
  }
}

@Riverpod(keepAlive: true)
class ProviderResolutionLoading extends _$ProviderResolutionLoading {
  @override
  bool build() => false;

  void set(bool value) => state = value;
}

/// AniList is the built-in provider and is selected automatically.
@Riverpod(keepAlive: true)
class ActiveProvider extends _$ActiveProvider {
  @override
  AnimeWitcherProvider? build() {
    final providers = ref.watch(extensionManagerProvider);
    if (providers.isEmpty) return null;

    final selected = providers.first;
    return selected;
  }

  Future<void> set(AnimeWitcherProvider? provider) async {
    final providers = ref.read(extensionManagerProvider);
    final next = provider ?? (providers.isEmpty ? null : providers.first);
    state = next;
    ref.read(providerResolutionLoadingProvider.notifier).set(false);
  }
}
