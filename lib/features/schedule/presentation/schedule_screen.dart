import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/domain/entity/multimedia_item.dart';
import '../../../core/extensions/providers/animewitcher_native_provider.dart';
import '../../../core/router/app_router.dart';
import '../../../core/utils/responsive_breakpoints.dart';
import '../../../shared/widgets/anime_catalog_shimmer.dart';
import '../../../shared/widgets/multimedia_card.dart';
import '../../../shared/widgets/mouse_drag_refresh_indicator.dart';
import '../../../shared/widgets/underline_segment_tabs.dart';
import '../../../../core/extensions/native_provider_resolution.dart';

class ScheduleScreen extends ConsumerStatefulWidget {
  const ScheduleScreen({super.key});

  @override
  ConsumerState<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _DayState {
  const _DayState({
    this.items = const <MultimediaItem>[],
    this.loading = false,
    this.loaded = false,
    this.error,
  });
  final List<MultimediaItem> items;
  final bool loading;
  final bool loaded;
  final Object? error;
}

class _ScheduleScreenState extends ConsumerState<ScheduleScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  late int _selectedDay;
  final Map<String, _DayState> _days = <String, _DayState>{};

  int _todayIndex() => switch (DateTime.now().weekday) {
        DateTime.saturday => 0,
        DateTime.sunday => 1,
        DateTime.monday => 2,
        DateTime.tuesday => 3,
        DateTime.wednesday => 4,
        DateTime.thursday => 5,
        DateTime.friday => 6,
        _ => 0,
      };

  @override
  void initState() {
    super.initState();
    _selectedDay = _todayIndex();
    for (final d in animeWitcherBroadcastDays) {
      _days[d] = const _DayState();
    }
    _tabController = TabController(
      length: animeWitcherBroadcastDays.length,
      vsync: this,
      initialIndex: _selectedDay,
    )..addListener(_onTab);
    unawaited(_load(animeWitcherBroadcastDays[_selectedDay], refresh: true));
  }

  void _onTab() {
    if (_tabController.indexIsChanging) return;
    if (_tabController.index == _selectedDay) return;
    setState(() => _selectedDay = _tabController.index);
    final day = animeWitcherBroadcastDays[_selectedDay];
    final st = _days[day] ?? const _DayState();
    if (!st.loaded && !st.loading) {
      unawaited(_load(day, refresh: true));
    }
  }

  @override
  void dispose() {
    _tabController
      ..removeListener(_onTab)
      ..dispose();
    super.dispose();
  }

  Future<void> _load(String day, {required bool refresh}) async {
    final provider = ref.nativeProvider;
    if (provider == null) {
      if (!mounted) return;
      setState(() => _days[day] = _DayState(error: StateError('no provider')));
      return;
    }
    final prev = _days[day] ?? const _DayState();
    setState(() => _days[day] = _DayState(items: prev.items, loading: true, loaded: prev.loaded));
    try {
      final page = await provider.getBroadcastSchedulePage(
        day,
        offset: 0,
        limit: 50,
        refresh: refresh,
      );
      if (!mounted) return;
      setState(() => _days[day] = _DayState(items: List<MultimediaItem>.from(page.items), loaded: true));
    } catch (e) {
      if (!mounted) return;
      setState(() => _days[day] = _DayState(items: prev.items, loaded: prev.loaded, error: e));
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 4),
              child: Text(
                'جدول البث',
                style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
              ),
            ),
            FilterStyleTabBar(
              controller: _tabController,
              isScrollable: true,
              tabs: [
                for (final day in animeWitcherBroadcastDays)
                  FilterStyleTab(label: day),
              ],
            ),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  for (final day in animeWitcherBroadcastDays)
                    _DayBody(
                      state: _days[day] ?? const _DayState(),
                      onRefresh: () => _load(day, refresh: true),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DayBody extends StatelessWidget {
  const _DayBody({required this.state, required this.onRefresh});
  final _DayState state;
  final Future<void> Function() onRefresh;

  @override
  Widget build(BuildContext context) {
    if (state.loading && state.items.isEmpty) {
      return const AnimeCatalogShimmer();
    }
    if (state.error != null && state.items.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline),
            const SizedBox(height: 8),
            TextButton(onPressed: onRefresh, child: const Text('إعادة المحاولة')),
          ],
        ),
      );
    }
    if (state.items.isEmpty) {
      return MouseDragRefreshIndicator(
        onRefresh: onRefresh,
        child: ListView(
          children: const [
            SizedBox(height: 120),
            Center(child: Text('لا توجد حلقات مجدولة لهذا اليوم')),
          ],
        ),
      );
    }
    return MouseDragRefreshIndicator(
      onRefresh: onRefresh,
      child: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: ResponsiveBreakpoints.animeGridDelegate(
          context,
          maxCrossAxisExtent: 220,
          childAspectRatio: MultimediaCardLayout.gridAspectRatio(
            isPortrait: true,
            isDesktop: context.isDesktop,
          ),
          crossAxisSpacing: 12,
          mainAxisSpacing: 14,
          handsetPortraitCrossAxisCount: MultimediaCardLayout.handsetPortraitGridColumns,
        ),
        itemCount: state.items.length,
        itemBuilder: (context, index) {
          final item = state.items[index];
          return MultimediaCard.fromItem(
            item: item,
            heroTag: heroTagWithUrl('schedule', item, index),
            onTap: () => item.openDetails(context),
          );
        },
      ),
    );
  }
}
