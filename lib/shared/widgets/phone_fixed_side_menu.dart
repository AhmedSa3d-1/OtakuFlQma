import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/navigation/taskbar_destination.dart';
import '../../features/characters/presentation/characters_screen.dart';
import '../../features/more/presentation/broadcast_schedule_screen.dart';
import '../../features/more/presentation/coming_soon_screen.dart';
import '../../features/more/presentation/global_statistics_screen.dart';
import '../../features/more/presentation/recent_watched_screen.dart';
import '../../features/more/presentation/seasons_screen.dart';
import '../../features/news/presentation/open_news.dart';
import 'app_side_menu.dart';

/// The phone side menu has a product-defined order. It deliberately does not
/// read the customizable bottom-bar order or hidden items.
List<AppSideMenuEntry> phoneFixedSideMenuEntries(
  BuildContext context,
  WidgetRef ref, {
  required int currentBranchIndex,
  required ValueChanged<TaskbarDestination> onDestination,
}) {
  void open(Widget page) {
    Navigator.of(
      context,
      rootNavigator: true,
    ).push(MaterialPageRoute<void>(builder: (_) => page));
  }

  void openSearch() {
    // Search is now a full-screen route, not a tab branch.
    // Keep it accessible from the side menu.
    Navigator.of(context, rootNavigator: true).pushNamed('/search');
  }

  bool selectedBranch(TaskbarDestination destination) =>
      currentBranchIndex == destination.branchIndex;

  return <AppSideMenuEntry>[
    AppSideMenuEntry(
      id: 'home',
      icon: selectedBranch(TaskbarDestination.home)
          ? Icons.home_rounded
          : Icons.home_outlined,
      label: 'الرئيسية',
      selected: selectedBranch(TaskbarDestination.home),
      onTap: () => onDestination(TaskbarDestination.home),
    ),
    AppSideMenuEntry(
      id: 'schedule',
      icon: selectedBranch(TaskbarDestination.schedule)
          ? Icons.calendar_today
          : Icons.calendar_today_outlined,
      label: 'الجدول',
      selected: selectedBranch(TaskbarDestination.schedule),
      onTap: () => onDestination(TaskbarDestination.schedule),
    ),
    AppSideMenuEntry(
      id: 'search',
      icon: Icons.search_rounded,
      label: 'البحث',
      onTap: openSearch,
    ),
    AppSideMenuEntry(
      id: 'community',
      icon: selectedBranch(TaskbarDestination.community)
          ? Icons.forum
          : Icons.forum_outlined,
      label: 'المجتمع',
      selected: selectedBranch(TaskbarDestination.community),
      onTap: () => onDestination(TaskbarDestination.community),
    ),
    AppSideMenuEntry(
      id: 'seasons',
      icon: Icons.calendar_month_rounded,
      label: 'المواسم',
      dividerBefore: true,
      onTap: () => open(const SeasonsScreen()),
    ),
    AppSideMenuEntry(
      id: 'global-statistics',
      icon: Icons.query_stats_rounded,
      label: 'الإحصائيات العالمية',
      onTap: () => open(const GlobalStatisticsScreen()),
    ),
    AppSideMenuEntry(
      id: 'coming-soon',
      icon: Icons.upcoming_rounded,
      label: 'القادم قريبًا',
      onTap: () => open(const ComingSoonScreen()),
    ),
    AppSideMenuEntry(
      id: 'recent-watched',
      icon: Icons.history_rounded,
      label: 'آخر المشاهدات',
      dividerBefore: true,
      onTap: () => open(const RecentWatchedScreen()),
    ),
    AppSideMenuEntry(
      id: 'characters',
      icon: Icons.groups_rounded,
      label: 'الشخصيات',
      onTap: () => open(const CharactersScreen(favoritesOnly: false)),
    ),
    AppSideMenuEntry(
      id: 'favorite-characters',
      icon: Icons.face_rounded,
      label: 'الشخصيات المفضلة',
      onTap: () => open(const CharactersScreen(favoritesOnly: true)),
    ),
    AppSideMenuEntry(
      id: 'broadcast-schedule',
      icon: Icons.calendar_month_rounded,
      label: 'جدول الحلقات',
      dividerBefore: true,
      onTap: () => open(const BroadcastScheduleScreen()),
    ),
    AppSideMenuEntry(
      id: 'news',
      icon: Icons.newspaper_rounded,
      label: 'الأخبار',
      onTap: () => openNewsScreen(context, ref),
    ),
    AppSideMenuEntry(
      id: 'settings',
      icon: Icons.settings_rounded,
      label: 'الإعدادات',
      dividerBefore: true,
      selected: selectedBranch(TaskbarDestination.settings),
      onTap: () => onDestination(TaskbarDestination.settings),
    ),
  ];
}
