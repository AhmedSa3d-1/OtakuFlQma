import 'package:flutter/material.dart';
import 'package:animewitcher/l10n/generated/app_localizations.dart';

enum TaskbarDestination {
  home,
  search,
  schedule,
  community,
  library,
  manga,
  downloads,
  settings;

  String get id => name;

  int get branchIndex => switch (this) {
    TaskbarDestination.home => 0,
    TaskbarDestination.search => 1,
    TaskbarDestination.schedule => 2,
    TaskbarDestination.community => 3,
    TaskbarDestination.library => 4,
    TaskbarDestination.manga => 5,
    TaskbarDestination.downloads => 6,
    TaskbarDestination.settings => 7,
  };

  String get route => switch (this) {
    TaskbarDestination.home => '/home',
    TaskbarDestination.search => '/search',
    TaskbarDestination.schedule => '/schedule',
    TaskbarDestination.community => '/community',
    TaskbarDestination.library => '/library',
    TaskbarDestination.manga => '/manga',
    TaskbarDestination.downloads => '/downloads',
    TaskbarDestination.settings => '/settings',
  };

  IconData get icon => switch (this) {
    TaskbarDestination.home => Icons.home_outlined,
    TaskbarDestination.search => Icons.search_outlined,
    TaskbarDestination.schedule => Icons.calendar_today_outlined,
    TaskbarDestination.community => Icons.forum_outlined,
    TaskbarDestination.library => Icons.library_books_outlined,
    TaskbarDestination.manga => Icons.menu_book_outlined,
    TaskbarDestination.downloads => Icons.download_outlined,
    TaskbarDestination.settings => Icons.more_horiz_rounded,
  };

  IconData get selectedIcon => switch (this) {
    TaskbarDestination.home => Icons.home,
    TaskbarDestination.search => Icons.search,
    TaskbarDestination.schedule => Icons.calendar_today,
    TaskbarDestination.community => Icons.forum,
    TaskbarDestination.library => Icons.library_books,
    TaskbarDestination.manga => Icons.menu_book,
    TaskbarDestination.downloads => Icons.download,
    TaskbarDestination.settings => Icons.more_horiz_rounded,
  };

  String label(AppLocalizations l10n) => switch (this) {
    TaskbarDestination.home => l10n.home,
    TaskbarDestination.search => 'بحث',
    TaskbarDestination.schedule => 'الجدول',
    TaskbarDestination.community => 'المجتمع',
    TaskbarDestination.library => 'المكتبة',
    TaskbarDestination.manga => 'المانجا',
    TaskbarDestination.downloads => 'التنزيلات',
    TaskbarDestination.settings => 'المزيد',
  };
}

const List<String> defaultTaskbarOrderIds = <String>[
  'home',
  'search',
  'schedule',
  'community',
  'library',
  'manga',
  'downloads',
];

TaskbarDestination? taskbarDestinationFromId(String id) {
  for (final destination in TaskbarDestination.values) {
    if (destination.id == id) return destination;
  }
  return null;
}

TaskbarDestination? taskbarDestinationForRoute(String route) {
  for (final destination in TaskbarDestination.values) {
    if (destination.route == route) return destination;
  }
  return null;
}

List<TaskbarDestination> normalizeTaskbarOrder(Iterable<String> storedIds) {
  final result = <TaskbarDestination>[];
  final seen = <TaskbarDestination>{};

  for (final id in storedIds) {
    final destination = taskbarDestinationFromId(id);
    if (destination != null &&
        destination != TaskbarDestination.settings &&
        seen.add(destination)) {
      result.add(destination);
    }
  }

  for (final destination in TaskbarDestination.values) {
    if (destination != TaskbarDestination.settings && seen.add(destination)) {
      result.add(destination);
    }
  }

  return List<TaskbarDestination>.unmodifiable(result);
}

Set<String> normalizeHiddenTaskbarItems(Iterable<String> storedIds) {
  final valid = TaskbarDestination.values.map((value) => value.id).toSet();
  return Set<String>.unmodifiable(
    storedIds.where(
      (id) => id != TaskbarDestination.settings.id && valid.contains(id),
    ),
  );
}

List<TaskbarDestination> visibleTaskbarDestinations(
  Iterable<String> orderIds,
  Iterable<String> hiddenIds,
) {
  final hidden = normalizeHiddenTaskbarItems(hiddenIds);
  final visible = normalizeTaskbarOrder(orderIds)
      .where((destination) => !hidden.contains(destination.id))
      .toList(growable: false);
  // Older preferences could hide every tab except More.
  return visible.isEmpty ? const [TaskbarDestination.home] : visible;
}

String resolveInitialTaskbarRoute(
  String preferredRoute,
  Iterable<String> orderIds,
  Iterable<String> hiddenIds,
) {
  final visible = visibleTaskbarDestinations(orderIds, hiddenIds);
  final preferred = taskbarDestinationForRoute(preferredRoute);
  return visible.contains(preferred) ? preferred!.route : visible.first.route;
}
