# AnimeWitcher Repository Technical Audit Report
## Prepared for OtakuFlQma Transformation

---

## A. Repository Architecture Map

### High-Level Structure
```
/home/zoka/Documents/OtakuFlQma/
├── lib/                          # Main Dart source (383 files)
│   ├── main.dart                 # Application entry point (1105 lines)
│   ├── core/                     # Cross-cutting concerns
│   │   ├── account/              # Firebase auth & AnimeWitcher account sync
│   │   ├── data/                 # Data models (GitHub release)
│   │   ├── domain/               # Business entities
│   │   │   └── entity/           # MultimediaItem, MangaChapter, Episode, etc.
│   │   ├── extensions/           # Provider abstraction layer
│   │   │   └── providers/        # AnimeWitcherNativeProvider (208KB)
│   │   ├── logger/               # Talker-based logging
│   │   ├── navigation/           # AppLayoutStyle, TaskbarDestination
│   │   ├── network/              # Dio client, poster cache, batch scheduler
│   │   ├── providers/            # Locale, device info, theme, update providers
│   │   ├── router/               # GoRouter configuration (Typed routes)
│   │   ├── services/             # Download, notification, artwork, proxy services
│   │   │   └── download_v2/      # New download architecture (16 files)
│   │   ├── storage/              # Hive boxes, settings, secure storage
│   │   ├── theme/                # AppTheme, ThemeProvider
│   │   ├── utils/                # 30+ utility files
│   │   └── widgets/              # Core UI components
│   ├── features/                 # Feature modules (16 features)
│   │   ├── characters/
│   │   ├── comments/
│   │   ├── details/              # Anime/Manga details (64KB screen)
│   │   ├── home/                 # Home screen with hero carousel
│   │   ├── library/              # Library & downloads management
│   │   ├── manga/                # Manga home, details, reader
│   │   ├── more/                 # Schedule, seasons, statistics
│   │   ├── news/
│   │   ├── notifications/
│   │   ├── onboarding/
│   │   ├── player/               # Video player (192KB controller)
│   │   ├── search/
│   │   ├── settings/
│   │   └── skip/                 # AniSkip/IntroDB integration
│   ├── shared/                   # Shared UI widgets (37 widgets)
│   ├── ffi/                      # FFI bindings
│   └── l10n/                     # Arabic localization (ARB)
├── android/                      # Android configuration
├── ios/                          # iOS configuration
├── packages/                     # Local packages
│   ├── media_kit/                # Custom media_kit fork
│   └── video_view/               # Lightweight video player plugin
├── test/                         # Unit/Widget tests
└── third_party/                  # MPV headers
```

### Module Dependency Graph
```
main.dart
  ├── AppRoot (StorageService init, artwork reachability probe)
  ├── MyApp (ProviderScope, DynamicColorBuilder, MaterialApp.router)
  │   ├── GoRouter (app_router.dart)
  │   │   ├── StatefulShellRoute (AppScaffold with 6 branches)
  │   │   │   ├── HomeBranch → HomeScreen
  │   │   │   ├── SearchBranch → SearchScreen
  │   │   │   ├── LibraryBranch → LibraryScreen
  │   │   │   ├── DownloadsBranch → DownloadsScreen
  │   │   │   ├── SettingsBranch → SettingsScreen
  │   │   │   └── MangaBranch → MangaHomeScreen
  │   │   └── Full-screen routes: Details, MangaDetails, MangaReader, Player, ViewAll
  │   ├── Theme (AppTheme - AnimeWitcher gold accent #EEC60A)
  │   ├── LocaleProvider (Arabic-only, RTL)
  │   └── ExtensionManager (AnimeWitcherNativeProvider)
  └── Services initialized on demand
```

---

## B. Important Files and Their Responsibilities

### Core Infrastructure
| File | Lines | Responsibility |
|------|-------|----------------|
| `lib/main.dart` | 1105 | App entry, initialization, ProviderScope, router, theme, locale, desktop window management |
| `lib/core/router/app_router.dart` | 408 | GoRouter typed routes, StatefulShellRoute with 6 bottom nav branches |
| `lib/core/extensions/extension_manager.dart` | 88 | Provider registry, active provider selection |
| `lib/core/extensions/base_provider.dart` | 441 | Abstract provider interface (search, home, details, episodes, streams) |
| `lib/core/extensions/providers/animewitcher_native_provider.dart` | 6315 | **Primary data provider** - Firestore, Algolia, AnimeWitcher API integration |

### State Management (Riverpod)
| File | Responsibility |
|------|----------------|
| `lib/core/providers/locale_provider.dart` | Arabic-only locale, RTL enforcement |
| `lib/core/providers/device_info_provider.dart` | TV, tablet, desktop detection |
| `lib/core/theme/theme_provider.dart` | Theme style (dark/light/amoled/amber/ocean/forest/sakura/violet/crimson) |
| `lib/features/home/presentation/home_provider.dart` | Home data fetching, continue watching |
| `lib/features/details/presentation/details_controller.dart` | Details screen state, episodes, related, recommendations |
| `lib/features/player/presentation/player_controller.dart` | Playback state, gestures, PiP, subtitles, Anime4K |
| `lib/features/library/presentation/library_provider.dart` | Library lists, categories, sync |

### Data Layer
| File | Responsibility |
|------|----------------|
| `lib/core/storage/storage_service.dart` | 1627 lines - Hive boxes (library, settings, history, downloads), cache management |
| `lib/core/storage/settings_repository.dart` | 239 lines - Settings persistence wrapper |
| `lib/core/storage/secure_token_storage.dart` | Encrypted token storage (Flutter Secure Storage) |
| `lib/core/network/dio_client_provider.dart` | Dio HTTP client with interceptors |
| `lib/core/network/poster_cache.dart` | Poster image caching with decode queue |

### Domain Entities
| File | Responsibility |
|------|----------------|
| `lib/core/domain/entity/multimedia_item.dart` | 1013 lines - Core entity: MultimediaItem, Episode, StreamResult, Actor, Trailer, NewsItem |
| `lib/core/domain/entity/manga.dart` | 98 lines - MangaChapter, MangaPage, MangaLatestChapter |

### UI Components (Shared)
| File | Responsibility |
|------|----------------|
| `lib/shared/widgets/multimedia_card.dart` | 21775 lines - Primary media card widget |
| `lib/shared/widgets/app_scaffold.dart` | 9241 lines - Main scaffold with navigation shell |
| `lib/shared/widgets/app_side_menu.dart` | 24929 lines - Side navigation drawer |
| `lib/shared/widgets/apple_liquid_glass.dart` | 64957 lines - iOS 26 liquid glass effects |
| `lib/features/home/presentation/widgets/media_horizontal_list.dart` | Horizontal rail component |

---

## C. Existing Feature Inventory

### 1. Navigation & Shell — **REUSABLE**
- **StatefulShellRoute** with 6 branches (Home, Search, Library, Downloads, Settings, Manga)
- Bottom navigation bar with customizable order/visibility
- Tablet/desktop two-pane layout support
- TV leanback launcher support
- Deep linking via GoRouter typed routes
- **Assessment**: Well-architected, minimal changes needed for OtakuFlQma nav structure

### 2. Home Screen — **ADAPTABLE**
- Hero carousel (featured movies)
- Continue watching section (local + synced)
- Provider home sections (new episodes, latest added, etc.)
- MyAnimeList ranking rails (trending, top rated, popular)
- News section integration
- Shimmer loading states
- Pull-to-refresh + mouse drag refresh
- **Assessment**: Structure reusable; data source must change from AnimeWitcher to AniList/API

### 3. Anime Details — **ADAPTABLE**
- Hero artwork with actions (play, download, favorite)
- Information section (genres, year, studio, status, score)
- Ratings row (MyAnimeList, AniList, AnimeWitcher)
- Seasons bar with episode counts
- Episode list with search, sort, filler markers
- Cast, trailers, recommendations, related anime tabs
- Comments preview + full comments screen
- Download management dialog
- **Assessment**: UI comprehensive; data mapping from AniList needed

### 4. Video Player — **REUSABLE**
- media_kit based (mpv backend)
- Hardware decoding, buffer control
- Gesture controls (brightness, volume, seek)
- Picture-in-Picture (Android)
- Subtitle rendering (SRT/ASS), sync, appearance customization
- Episode navigation panel with search
- Next episode overlay with pre-fetch
- Anime4K shader support (external GLSL)
- External player launching (VLC, MX Player, MPV)
- Skip segments (AniSkip/IntroDB via ani.zip)
- Hotstar edge rail for multi-source streams
- **Assessment**: Feature-complete player; retain with OtakuFlQma branding

### 5. Manga Reader — **ADAPTABLE**
- Vertical/horizontal/webtoon reading modes
- Two-page spread on landscape
- Chapter navigation, download integration
- Reading progress sync
- Custom cover support
- **Assessment**: Good reader; data source change needed

### 6. Search — **ADAPTABLE**
- Instant results (Algolia-powered)
- Recent searches persistence
- Filter options (status, type, year, season, genre, sort)
- MyAnimeList ranking integration
- Voice search support
- **Assessment**: UI excellent; backend must switch to AniList/search API

### 7. Library & Downloads — **ADAPTABLE**
- Categories: Watching, Completed, On Hold, Plan to Watch, Dropped, Favorites
- Manga library with chapters tracking
- Download management (v2 architecture)
  - Multi-part parallel downloads
  - Background downloads with notifications
  - Integrity verification
  - Continued processing on iOS
  - Artwork embedding
- Watch history with continue watching
- **Assessment**: Download v2 is sophisticated; retain architecture, adapt to new sources

### 8. Account & Sync — **REBUILD**
- Firebase Auth (Google sign-in)
- Firestore sync (library, watch progress, ratings, comments, characters)
- Conflict resolution (last-write-wins with manual override)
- Profile management (avatar, privacy settings)
- Ecchi content filter
- **Assessment**: Tied to AnimeWitcher Firebase project; must rebuild for OtakuFlQma backend

### 9. Comments & Community — **REBUILD**
- AnimeWitcher comments screen (replies, mentions, sorting)
- My comments screen
- Comment editing
- **Assessment**: Requires new backend (Firestore or alternative)

### 10. Notifications — **REBUILD**
- AnimeWitcher notification models
- FCM integration
- **Assessment**: Requires new Firebase project or alternative push service

### 11. Schedule & Seasons — **ADAPTABLE**
- Weekly broadcast schedule (7 days)
- Season grids (past/current/next + archive)
- Global statistics (MyAnimeList rankings)
- **Assessment**: UI reusable; data from AniList airing schedule

### 12. Settings — **ADAPTABLE**
- Theme selection (9 dark variants + light)
- Player settings (decoder, buffer, gestures, PiP, Anime4K)
- Download settings (concurrency, parallel parts, notifications)
- Taskbar customization
- Cache management
- Language (Arabic only currently)
- **Assessment**: Good structure; simplify for OtakuFlQma scope

### 13. Arabic Localization & RTL — **REUSABLE**
- Complete Arabic translations (1294 keys in app_localizations_ar.dart)
- RTL-only locale enforcement
- Digit normalization (Arabic-Indic ↔ Western)
- Mixed Arabic/English text handling
- **Assessment**: Excellent foundation; primary language for OtakuFlQma

### 14. Onboarding — **ADAPTABLE**
- First run setup (theme, provider, sign-in prompt)
- Welcome dialog
- **Assessment**: Simplify for OtakuFlQma branding

---

## D. Dependency and Licensing Report

### Direct Dependencies (pubspec.yaml)
| Package | Version | License | Notes |
|---------|---------|---------|-------|
| flutter_riverpod | ^3.4.3 | MIT | State management |
| hooks_riverpod | ^3.4.3 | MIT | Hooks integration |
| riverpod_annotation | ^4.0.7 | MIT | Code generation |
| go_router | ^18.1.0 | BSD-3-Clause | Navigation |
| dio | ^5.11.1 | MIT | HTTP client |
| google_fonts | ^9.0.0 | Apache-2.0 | Font loading (Readex Pro bundled) |
| cached_network_image | ^4.0.4 | MIT | Image caching |
| octo_image | ^2.1.2 | MIT | Advanced image loading |
| hive_flutter | ^1.1.0 | MIT | Local database |
| shared_preferences | ^2.5.6 | BSD-3-Clause | Key-value storage |
| flutter_secure_storage | ^11.2.0 | MIT | Encrypted storage |
| media_kit | ^1.2.6 | MIT | Media player (custom fork in packages/) |
| media_kit_video | ^2.0.1 | MIT | Video output |
| media_kit_libs_video | ^1.0.7 | LGPL-2.1 | MPV libraries |
| background_downloader | 9.6.5 | MIT | Background downloads |
| permission_handler | ^13.0.2 | MIT | Runtime permissions |
| flutter_cache_manager | ^3.4.5 | MIT | Cache management |
| connectivity_plus | ^7.3.2 | BSD-3-Clause | Network state |
| dynamic_color | ^2.1.0 | Apache-2.0 | Material You colors |
| window_manager | ^0.5.2 | MIT | Desktop window controls |
| device_info_plus | ^13.3.0 | BSD-3-Clause | Device info |
| crypto | ^3.0.7 | BSD-3-Clause | Hashing |
| ffi | ^2.2.0 | MIT | FFI support |
| native_toolchain_c | ^0.19.5 | MIT | C toolchain |
| file_picker | ^13.1.0 | MIT | File picking |
| image | ^4.12.0 | MIT | Image processing |
| archive | ^4.5.2 | MIT | Archive extraction |
| url_launcher | ^6.3.3 | BSD-3-Clause | URL launching |
| open_file | ^4.0.0 | MIT | File opening |
| flutter_displaymode | ^0.7.0 | MIT | Display mode control |
| intl | ^0.20.3 | BSD-3-Clause | Internationalization |
| flutter_svg | ^2.3.0 | MIT | SVG rendering |
| dpad | ^3.1.1 | MIT | TV remote navigation |
| shimmer | ^4.0.0 | MIT | Shimmer loading |
| super_sliver_list | ^0.4.1 | MIT | Sliver list performance |
| video_view | local | MIT | Custom video player plugin |
| talker_flutter | ^5.1.20 | MIT | Logging |
| visibility_detector | ^0.4.0+2 | MIT | Visibility detection |
| lucide_icons_flutter | ^4.0.0 | MIT | Icons |

### License Compatibility
- **Project License**: GPL-3.0-only (LICENSE file)
- **All dependencies**: MIT, BSD-3-Clause, Apache-2.0 — all GPL-3.0 compatible
- **media_kit_libs_video**: LGPL-2.1 — compatible with GPL-3.0 (dynamic linking)
- **Third-party notices**: Harbor (MIT) - poster plate, idle preload, search layout

### Action Required for OtakuFlQma
- Preserve GPL-3.0 license for derivative work
- Update copyright notices to include OtakuFlQma
- Maintain THIRD_PARTY_NOTICES.md
- Ensure source code availability per GPL-3.0

---

## E. Android Build and Compatibility Report

### Build Configuration
| Setting | Value |
|---------|-------|
| compileSdk | 37 (Android 14+) |
| targetSdk | 36 |
| minSdk | Flutter default (21+) |
| JVM Target | 17 |
| NDK | Flutter managed |
| Signing | Release requires key.properties |
| Minify | Enabled (ProGuard + custom rules) |
| Shrink Resources | Enabled |

### Permissions (AndroidManifest.xml)
| Permission | Max SDK | Purpose |
|------------|---------|---------|
| INTERNET | - | Network access |
| WRITE_SETTINGS | - | Brightness control in player |
| READ_EXTERNAL_STORAGE | 32 | Legacy media access |
| WRITE_EXTERNAL_STORAGE | 28 | Legacy media write |
| REQUEST_INSTALL_PACKAGES | - | APK installation (updates) |
| POST_NOTIFICATIONS | - | Download progress, episode reminders |
| FOREGROUND_SERVICE | - | Background downloads |
| FOREGROUND_SERVICE_DATA_SYNC | - | Download sync |
| WAKE_LOCK | - | Keep CPU awake during download |
| REQUEST_IGNORE_BATTERY_OPTIMIZATIONS | - | Background download reliability |
| RECEIVE_BOOT_COMPLETED | - | Resume downloads on boot |
| ACCESS_NETWORK_STATE | - | Connectivity monitoring |
| RUN_USER_INITIATED_JOBS | - | WorkManager jobs |

### Features
- `android.software.leanback` (optional) — Android TV support
- `android.hardware.touchscreen` (optional) — TV installability

### Network Security
- `android:usesCleartextTraffic="true"` — Allows HTTP (for some streams)
- Custom `network_security_config.xml` referenced

### Application
- Label: "AnimeWitcher" → **Must change to "OtakuFlQma"**
- Icon: @mipmap/ic_launcher
- Banner: @drawable/banner (TV)
- Theme: LaunchTheme → NormalTheme transition
- Activity: MainActivity (singleTop, hardwareAccelerated, supportsPiP)
- ConfigChanges: Full set (orientation, keyboard, screenSize, locale, layoutDirection, fontScale, screenLayout, density, uiMode)

### Services
- `background_downloader.UIDTJobService` — Background download jobs
- `androidx.work.impl.foreground.SystemForegroundService` — WorkManager

### Meta-data
- `flutterEmbedding: 2`
- `EnableImpeller: true` — Vulkan/Metal rendering

### Compatibility Assessment
- **Target SDK 36**: Current, supports latest Android features
- **Min SDK 21**: Covers 99%+ devices
- **Permissions**: Appropriate for media app with downloads
- **TV Support**: Properly configured with leanback launcher
- **Impeller**: Enabled for better rendering performance

---

## F. Reuse vs Rebuild Recommendations

### REUSABLE (Retain with Minimal Changes)
| Component | Reason |
|-----------|--------|
| Navigation architecture (GoRouter + StatefulShellRoute) | Clean, typed, scalable |
| Video player (media_kit + custom controls) | Feature-complete, hardware accelerated |
| Manga reader | Mature, multiple reading modes |
| Download v2 architecture | Sophisticated, background-capable |
| Arabic localization & RTL | Complete, primary language |
| Theme system (9 dark variants + light) | Well-structured, M3 compliant |
| Shared UI widgets (multimedia_card, app_scaffold, app_side_menu, shimmers) | High quality, reusable |
| Storage layer (Hive + SecureStorage + SettingsRepository) | Robust, migration-ready |
| Network layer (Dio + poster cache + batch scheduler) | Well-abstracted |
| Device detection (TV, tablet, desktop) | Comprehensive |
| Anime4K integration | Optional, external shaders |
| Skip segments (AniSkip/IntroDB) | Community data, via ani.zip |
| Test infrastructure | Existing unit/widget tests |

### ADAPTABLE (Requires Modifications)
| Component | Required Changes |
|-----------|------------------|
| Home screen data | Replace AnimeWitcher provider with AniList/API |
| Anime details screen | Map AniList fields to MultimediaItem |
| Search | New backend (AniList GraphQL or REST) |
| Schedule/Seasons | AniList airing schedule API |
| Library categories | Simplify to Favorites/Watchlist |
| Settings | Remove AnimeWitcher-specific options (provider selection, custom base URL) |
| Theme colors | Apply OtakuFlQma palette (#E60066 primary, #101318 background) |
| App branding | Package name, app name, icons, splash |
| Network security | Review cleartext traffic for new sources |

### REBUILD (Implement Independently)
| Component | Reason |
|-----------|--------|
| Authentication & User Accounts | Tied to AnimeWitcher Firebase project |
| Cloud Sync (library, progress, ratings) | Requires new backend |
| Comments & Community | Requires new backend + moderation |
| Push Notifications | New Firebase project or alternative |
| AnimeWitcher Native Provider | Entire provider tied to AnimeWitcher APIs |
| Account settings screens | AnimeWitcher-specific profile/privacy |
| News feed | AnimeWitcher news source; replace with approved sources |
| Provider selection/management | Single-source app, no extension system needed |

### REMOVE (Unnecessary for OtakuFlQma)
| Component | Reason |
|-----------|--------|
| Extension Manager / Provider abstraction | Single data source (AniList) |
| AnimeWitcher account service (142KB) | Tied to AnimeWitcher backend |
| Custom base URL setting | Not needed |
| Provider-specific search settings (Algolia) | Not applicable |
| Ecchi filter (server-side) | Client-side only if needed |
| AnimeWitcher character models/favorites | Not in scope |
| Firebase Functions/Storage clients | Not needed unless new backend uses them |
| desktop window_manager (if Android-only) | Keep if multi-platform desired |

---

## G. Proposed OtakuFlQma Architecture

### Layered Architecture
```
┌─────────────────────────────────────────────────────────────┐
│                    PRESENTATION LAYER                        │
│  Screens (Home, Schedule, Details, Search, Community,      │
│          Profile, Settings) + Shared Widgets                │
├─────────────────────────────────────────────────────────────┤
│                    APPLICATION LAYER                         │
│  Controllers/Providers (Riverpod)                           │
│  - HomeController, ScheduleController, DetailsController   │
│  - SearchController, CommunityController, ProfileController │
│  - DownloadController, PlayerController                     │
├─────────────────────────────────────────────────────────────┤
│                      DOMAIN LAYER                            │
│  Entities: Anime, Episode, Manga, Chapter, User, Post,     │
│            Comment, Notification, ScheduleEntry             │
│  Repository Interfaces (Contracts)                          │
├─────────────────────────────────────────────────────────────┤
│                       DATA LAYER                             │
│  Repositories (Impl)                                        │
│  - AniListRepository (GraphQL)                              │
│  - AuthRepository (Firebase Auth / Custom)                  │
│  - CommunityRepository (Firestore / Supabase / Custom)      │
│  - LocalRepository (Hive + SharedPreferences)               │
│  - DownloadRepository (background_downloader)               │
│  - CacheRepository (flutter_cache_manager)                  │
└─────────────────────────────────────────────────────────────┘
```

### Navigation Structure (4 Primary Tabs per Blueprint)
```
StatefulShellRoute (AppScaffold)
├── HomeBranch (index 0)          → HomeScreen
│   └── /home
├── ScheduleBranch (index 1)      → ScheduleScreen (NEW)
│   └── /schedule
├── CommunityBranch (index 2)     → CommunityScreen (NEW)
│   └── /community
└── SettingsBranch (index 3)      → SettingsScreen
    └── /settings

Full-screen Routes:
├── /anime-details/:id            → AnimeDetailsScreen
├── /manga-details/:id            → MangaDetailsScreen
├── /manga-reader                 → MangaReaderScreen
├── /player                       → PlayerScreen
├── /search                       → SearchScreen
├── /profile                      → ProfileScreen
└── /view-all                     → ViewAllScreen
```

### Data Sources
| Feature | Primary Source | Fallback |
|---------|---------------|----------|
| Anime Metadata | AniList GraphQL | Jikan REST (unofficial MAL) |
| Airing Schedule | AniList GraphQL | - |
| Anime Search | AniList GraphQL | - |
| Manga Metadata | AniList GraphQL | - |
| User Auth | Firebase Auth | - |
| Community Data | Cloud Firestore | - |
| Push Notifications | Firebase FCM | - |
| Images | AniList CDN / Media proxy | - |

### State Management Pattern
- **Riverpod 3.x** with `riverpod_annotation` for code generation
- **AsyncValue** for loading/error/data states
- **AutoDispose** for scoped providers, **keepAlive** for singletons
- **Provider overrides** for testing and platform-specific implementations

---

## H. Prioritized Implementation Roadmap

### Phase 1: Codebase Audit & Baseline ✅ (Current Task)
- [x] Repository inspection complete
- [ ] Build original Android APK
- [ ] Verify launch and navigation
- [ ] Document build errors

### Phase 2: Android Baseline & Branding
| Priority | Task | Effort |
|----------|------|--------|
| P0 | Change package name: `com.animewitcher.app` → `com.otakuflqma.app` | 2h |
| P0 | Update app label, icons, splash screen | 4h |
| P0 | Apply OtakuFlQma color palette to AppTheme | 4h |
| P0 | Update AndroidManifest permissions review | 2h |
| P0 | Build and test debug APK | 2h |

### Phase 3: Navigation Restructure
| Priority | Task | Effort |
|----------|------|--------|
| P0 | Reduce bottom nav to 4 tabs (Home, Schedule, Community, Settings) | 4h |
| P0 | Create ScheduleScreen with weekly calendar | 8h |
| P0 | Create CommunityScreen scaffold | 8h |
| P0 | Remove Manga tab from bottom nav (move to Home/Search) | 2h |
| P0 | Update AppScaffold and TaskbarDestination | 4h |

### Phase 4: Data Layer Replacement
| Priority | Task | Effort |
|----------|------|--------|
| P0 | Create AniList GraphQL client (Dio + custom parser) | 16h |
| P0 | Implement AnimeRepository (search, details, schedule, rankings) | 16h |
| P0 | Map AniList data to MultimediaItem entity | 8h |
| P0 | Replace AnimeWitcherNativeProvider with AniListProvider | 12h |
| P1 | Implement MangaRepository (AniList manga) | 8h |
| P1 | Add image proxy/fallback for AniList CDN | 4h |

### Phase 5: Feature Implementation
| Priority | Task | Effort |
|----------|------|--------|
| P0 | HomeScreen: Featured news, trending, recent updates | 12h |
| P0 | ScheduleScreen: Week view, day navigation, time zones | 16h |
| P0 | AnimeDetailsScreen: Adapt existing details screen | 8h |
| P0 | SearchScreen: Adapt to AniList search | 8h |
| P1 | Favorites/Watchlist (local + sync) | 12h |
| P1 | Firebase Auth integration | 8h |
| P1 | Community: Posts, comments, reactions (Firestore) | 24h |
| P1 | Notifications: Episode reminders, announcements | 8h |

### Phase 6: Polish & Release
| Priority | Task | Effort |
|----------|------|--------|
| P0 | Arabic RTL verification across all screens | 8h |
| P0 | Offline/error states, skeleton loading | 8h |
| P0 | Performance profiling (memory, frame times) | 8h |
| P0 | Release build, ProGuard testing | 4h |
| P0 | Play Store listing preparation | 4h |

---

## First Five Implementation Tasks (Awaiting Approval)

1. **Task 1: Android Baseline Build & Branding Setup**
   - Change package name to `com.otakuflqma.app`
   - Update `android:label` to "OtakuFlQma" in AndroidManifest.xml
   - Replace app icons (ic_launcher, banner) with OtakuFlQma assets
   - Apply OtakuFlQma color palette to `AppTheme` (primary #E60066, backgrounds #101318/#181B22/#1E222B)
   - Build debug APK and verify launch

2. **Task 2: Navigation Restructure to 4-Tab Layout**
   - Modify `app_router.dart`: Reduce StatefulShellRoute branches from 6 to 4
   - Create `ScheduleScreen` placeholder with weekly calendar structure
   - Create `CommunityScreen` placeholder
   - Remove `MangaBranch` from bottom nav (integrate manga into Home/Search)
   - Update `TaskbarDestination` enum and `AppScaffold`

3. **Task 3: AniList GraphQL Client & Repository**
   - Create `lib/core/network/anilist_client.dart` with Dio + GraphQL
   - Implement `AnimeRepository` interface with: search, getDetails, getSchedule, getRankings, getSeasonal
   - Add AniList data mappers to `MultimediaItem` entity
   - Replace `AnimeWitcherNativeProvider` usage in `HomeScreen` and `DetailsScreen` with new repository
   - Remove `extension_manager.dart` and provider abstraction (single source)

4. **Task 4: Home Screen Data Migration**
   - Update `HomeProvider` to use `AnimeRepository` instead of `activeProviderProvider`
   - Implement: Featured (seasonal popular), Trending (rankings), Recent Updates, Continue Watching
   - Connect Schedule data to Home quick-access
   - Add News section placeholder (approved sources only)
   - Verify shimmer loading and pull-to-refresh

5. **Task 5: Schedule Screen Implementation**
   - Build weekly calendar UI (7-day horizontal tabs or vertical list)
   - Fetch airing schedule from AniList (airingAt, episode, timeUntilAiring)
   - Implement time-zone-aware display (user local time)
   - Add anime card with cover, title, episode number, countdown
   - Connect "Save to Favorites" action (local storage initially)

---

## Technical Risks & Mitigations

| Risk | Impact | Mitigation |
|------|--------|------------|
| AniList rate limits (90 req/min) | High | Implement caching, batch requests, local-first UI |
| AniList GraphQL schema changes | Medium | Version-pinned queries, integration tests |
| Firebase cost (Firestore/FCM) | Medium | Evaluate Supabase/Appwrite alternatives; implement usage monitoring |
| GPL-3.0 compliance | High | Maintain source availability, preserve license headers |
| Arabic RTL regressions | Medium | Automated RTL test screenshots, manual QA checklist |
| media_kit LGPL dependency | Low | Dynamic linking confirmed; document in THIRD_PARTY_NOTICES |
| Background download reliability | High | Test on Android 14+ with battery optimization edge cases |
| Video codec compatibility | Medium | Test HEVC, AV1, VP9 on target devices; fallback to external player |

---

## Conclusion

The AnimeWitcher codebase is a **well-architected, feature-rich Flutter application** with:
- Clean separation of concerns (core, features, shared)
- Modern tech stack (Riverpod 3, GoRouter 18, Dart 3.13+)
- Comprehensive video player and download system
- Excellent Arabic RTL foundation
- Multi-platform support (Android, iOS, Desktop, TV)

**For OtakuFlQma transformation**: ~60% of the codebase is reusable (navigation, player, reader, downloads, UI components, storage, theming). The primary work is replacing the AnimeWitcher data provider with AniList, rebuilding auth/sync/community on a new backend, and applying the new brand identity.

**Recommendation**: Proceed with the phased approach. Start with Tasks 1-2 to establish the branded baseline, then replace the data layer (Task 3) before building the new feature screens.

---

*Report generated: 2026-11-10*
*Audit scope: Complete repository inspection (383 Dart files, Android config, dependencies)*
*Classification: REUSABLE / ADAPTABLE / REBUILD / REMOVE per feature*