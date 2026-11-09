# OtakuFlQma — Master Development Blueprint
## Project Transformation Plan | Android

### 1. Project Identity

**Project Name:** OtakuFlQma  
**Arabic Name:** أوتاكو في القمة  
**Platform:** Android  
**Base Project:** AnimeWitcher  
**Primary Framework:** Flutter / Dart  
**Development Environment:** Google Antigravity

### 2. Project Vision

Transform the AnimeWitcher codebase into OtakuFlQma: an Arabic-first anime platform that combines anime news, anime discovery, release schedules, and an interactive anime community.

The application should represent the identity of the OtakuFlQma social media brand while maintaining a clean, fast, modern, and scalable architecture.

The application is primarily an anime information and community platform, not an unauthorized anime streaming or content-hosting service.

### 3. Brand Identity and UI Direction

**Visual identity:**
- Primary background: #101318
- Secondary background: #181B22
- Card background: #1E222B
- Primary accent: #E60066
- Secondary accent: #FF1A75
- Gold accent: #D4AF65
- Primary text: #FFFFFF
- Secondary text: #BEBBB5

**Design language:**
- Premium dark interface.
- Modern anime-inspired visual identity.
- Subtle glass effects.
- Rounded cards and clean spacing.
- Red highlights with restrained gold details.
- High-quality anime artwork.
- Smooth but lightweight animations.
- Consistent iconography.
- No excessive gradients or visual clutter.

**Arabic requirements:**
- Arabic is the default application language.
- Full RTL layout support.
- Correct Arabic typography and text alignment.
- Support Arabic and English anime titles.
- Numbers, dates, and mixed-language text must render correctly.
- English titles must not break Arabic layout.

### 4. Main Application Navigation

The application should have four primary navigation sections:

#### A. Home — الرئيسية
- Featured anime news.
- Latest announcements.
- Trending anime.
- Recommended anime.
- Recently updated content.
- Quick access to the anime schedule.
- Featured community posts.

#### B. Anime Schedule — جدول الأنمي
- Weekly anime release schedule.
- Day-by-day navigation.
- Anime cover and title.
- Episode number when available.
- Release date and time.
- Time-zone-aware display.
- Anime details page.
- Ability to save anime to favorites.

#### C. Community — المجتمع
- Community posts.
- Text-based discussions.
- Comments and replies.
- Reactions.
- Polls.
- Anime recommendations.
- User profiles.
- Basic reporting and moderation.

#### D. Settings — الإعدادات
- User account.
- Language selection.
- Theme settings.
- Notification preferences.
- Favorites.
- About OtakuFlQma.
- Privacy policy.
- Open-source licenses.

### 5. Core Features

**Anime News**
- Display news from approved sources.
- News categories.
- Featured news.
- Search and filtering.
- News details.
- Original source attribution.
- External source links.

**Anime Database**
- Anime title in Arabic and English when available.
- Cover image.
- Synopsis.
- Genres.
- Release year.
- Episode count when confirmed.
- Studio information.
- Status.
- Related anime.
- Favorites.

**Anime Schedule**
- Weekly calendar.
- Upcoming episodes.
- Local time display.
- Anime details.
- Notifications for saved anime when supported.

**Community**
- User-generated posts.
- Comments and replies.
- Reactions.
- Polls.
- User profiles.
- Content reporting.
- Basic moderation tools.

**Notifications**
- New anime announcements.
- Saved anime episode reminders.
- Important application updates.
- Community interactions.

### 6. Technical Architecture

First inspect the existing AnimeWitcher implementation.

Evaluate and reuse the existing technologies where appropriate:

- Flutter / Dart: application framework.
- Riverpod: state management.
- GoRouter: navigation.
- Dio: API communication.
- Hive: local storage.
- Shared Preferences: application settings.
- Flutter Secure Storage: sensitive local information.

Do not replace existing packages without a technical reason.

Recommended architecture:

- Presentation Layer: screens and reusable widgets.
- Application Layer: controllers and application logic.
- Domain Layer: entities and business rules.
- Data Layer: repositories, API clients, and local storage.

Keep the architecture modular and easy to maintain.

### 7. Data and Backend Strategy

Prioritize affordable services and free usage tiers.

Potential integrations:

- AniList API for anime metadata and schedules.
- Firebase Authentication for accounts.
- Cloud Firestore for community data.
- External image URLs from approved sources.
- Local caching to reduce unnecessary requests.

Important:
- Verify API availability and terms before implementation.
- Never expose private API keys or service credentials in source code.
- Do not assume that an API provides every required feature.
- Do not use Firebase Storage unless its cost and necessity have been evaluated.
- Provide graceful error handling when external services are unavailable.

### 8. Development Priorities

**Phase 1 — Codebase Audit**
- Inspect the entire project structure.
- Identify the application entry point.
- Understand navigation and state management.
- Identify existing screens and reusable widgets.
- Review API integrations.
- Review local storage.
- Check dependencies and licenses.
- Verify Android build configuration.

Deliverable: a technical audit report.

**Phase 2 — Android Baseline**
- Build the original application.
- Verify that it launches.
- Test navigation and existing functionality.
- Record current build errors.
- Document environment requirements.

Deliverable: a working baseline Android build.

**Phase 3 — Branding and UI**
- Introduce OtakuFlQma visual identity.
- Redesign the application navigation.
- Establish shared design components.
- Implement consistent Arabic RTL behavior.
- Preserve functional logic wherever possible.

Deliverable: branded Android interface.

**Phase 4 — Main Features**
Implement in this order:
1. Home.
2. Anime schedule.
3. Anime details and favorites.
4. Anime news.
5. Search.
6. User accounts.
7. Community.
8. Notifications.

Deliverable: functional application modules.

**Phase 5 — Testing and Optimization**
- Test Arabic and English interfaces.
- Test different Android screen sizes.
- Check navigation and state persistence.
- Test offline and network error states.
- Optimize images and loading.
- Check memory and performance.
- Verify permissions and privacy.
- Test the release build.

Deliverable: stable Android APK.

### 9. UI/UX Rules

- Keep the interface consistent across all screens.
- Use reusable widgets instead of duplicated components.
- Every interactive element must work.
- Add loading, empty, and error states.
- Use skeleton loading where appropriate.
- Preserve scroll positions when navigating where practical.
- Avoid unnecessary network requests.
- Support Android back navigation.
- Do not introduce decorative buttons without functionality.

### 10. Licensing and Legal Requirements

AnimeWitcher is licensed under GPL-3.0.

When modifying and distributing a derivative version:
- Preserve required copyright notices.
- Include the applicable GPL-3.0 license.
- Document modifications.
- Provide corresponding source code as required by the license.
- Review third-party package licenses independently.
- Do not assume anime artwork, logos, or external content are covered by the project's GPL license.

The OtakuFlQma brand identity must be independent. Do not reuse AnimeWitcher branding or imply official affiliation.

### 11. Antigravity Development Rules

1. Inspect before modifying.
2. Never rewrite the entire project without approval.
3. Never delete existing functionality without explaining why.
4. Maintain a clear separation between original and modified code.
5. Work in small, verifiable stages.
6. Run Flutter analysis after meaningful changes.
7. Run available tests.
8. Build Android after major milestones.
9. Fix errors before moving to the next stage.
10. Document every significant architectural decision.
11. Do not invent API endpoints or unsupported features.
12. Ask for approval before destructive changes or major dependency replacements.

### 12. Definition of Success

OtakuFlQma is successful when:
- It runs reliably on Android.
- Its identity is clearly distinct.
- Arabic RTL works correctly.
- News and anime information are easy to navigate.
- The weekly anime schedule is functional.
- Users can save and discover anime.
- Community features work reliably.
- The codebase remains maintainable.
- The application respects the applicable licenses and content rights.

---

## Final Development Principle

Do not build everything at once.

Study AnimeWitcher, understand what already works, preserve useful functionality, and transform it incrementally into OtakuFlQma.

Quality, stability, and maintainability are more important than the number of features.