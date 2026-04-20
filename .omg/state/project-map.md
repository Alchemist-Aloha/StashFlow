# Project Map

## Modules & Responsibilities

### Core (`lib/core/`)
- **Data**: Global data sources and repository implementations.
- **Domain**: Base entities and use cases.
- **Presentation**: Shared widgets and UI helpers.
- **Utils**: Logging, extensions, and constants.

### Features (`lib/features/`)
- **Scenes**: Video browsing, player, and metadata.
- **Performers**: Actor profiles and associations.
- **Studios**: Studio hierarchy and content.
- **Galleries/Images**: Image-based content management.
- **Setup**: Initial connection and configuration wizard.

### Localization (`lib/l10n/`)
- **ARB Files**: Source of truth for all UI strings.
- **Localizations**: Generated classes for type-safe access.

## Dependency Hotspots
- **Riverpod**: State management across all features.
- **GoRouter**: Centralized navigation.
- **GraphQL**: Communication with Stash server.
- **Video Player**: Native integration for playback.
