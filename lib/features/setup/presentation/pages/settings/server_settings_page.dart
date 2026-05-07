import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stash_app_flutter/core/data/graphql/graphql_client.dart';
import 'package:stash_app_flutter/core/data/graphql/media_headers_provider.dart';
import 'package:stash_app_flutter/core/presentation/theme/app_theme.dart';
import 'package:stash_app_flutter/features/galleries/presentation/providers/gallery_details_provider.dart';
import 'package:stash_app_flutter/features/galleries/presentation/providers/gallery_list_provider.dart';
import 'package:stash_app_flutter/features/groups/presentation/providers/group_details_provider.dart';
import 'package:stash_app_flutter/features/groups/presentation/providers/group_list_provider.dart';
import 'package:stash_app_flutter/features/performers/presentation/providers/performer_details_provider.dart';
import 'package:stash_app_flutter/features/performers/presentation/providers/performer_list_provider.dart';
import 'package:stash_app_flutter/features/performers/presentation/providers/performer_media_provider.dart';
import 'package:stash_app_flutter/features/scenes/data/repositories/stream_resolver.dart';
import 'package:stash_app_flutter/features/scenes/presentation/providers/scene_details_provider.dart';
import 'package:stash_app_flutter/features/scenes/presentation/providers/scene_list_provider.dart';
import 'package:stash_app_flutter/features/scenes/presentation/providers/video_player_provider.dart';
import 'package:stash_app_flutter/features/setup/presentation/providers/connection_provider.dart';
import 'package:stash_app_flutter/features/setup/presentation/providers/server_profiles_provider.dart';
import 'package:stash_app_flutter/features/setup/presentation/widgets/server_profile_card.dart';
import 'package:stash_app_flutter/features/setup/presentation/widgets/server_profile_drawer.dart';
import 'package:stash_app_flutter/features/studios/presentation/providers/studio_details_provider.dart';
import 'package:stash_app_flutter/features/studios/presentation/providers/studio_list_provider.dart';
import 'package:stash_app_flutter/features/studios/presentation/providers/studio_media_provider.dart';
import 'package:stash_app_flutter/features/tags/presentation/providers/tag_details_provider.dart';
import 'package:stash_app_flutter/features/tags/presentation/providers/tag_list_provider.dart';
import 'package:stash_app_flutter/features/tags/presentation/providers/tag_media_provider.dart';
import 'package:stash_app_flutter/l10n/app_localizations.dart';
import 'package:stash_app_flutter/core/data/auth/auth_mode.dart';
import 'package:stash_app_flutter/core/data/auth/auth_provider.dart';

import '../../widgets/settings_page_shell.dart';
import '../../../domain/models/server_profile.dart';

class ServerSettingsPage extends ConsumerStatefulWidget {
  const ServerSettingsPage({super.key});

  @override
  ConsumerState<ServerSettingsPage> createState() => _ServerSettingsPageState();
}

class _ServerSettingsPageState extends ConsumerState<ServerSettingsPage> {
  @override
  void initState() {
    super.initState();
  }

  Future<void> _flushRuntimeCachesAfterServerChange() async {
    final currentClient = ref.read(graphqlClientProvider);
    currentClient.cache.store.reset();

    ref.read(playerStateProvider.notifier).stop();

    ref.invalidate(serverUrlProvider);
    ref.invalidate(serverApiKeyProvider);
    ref.invalidate(graphqlClientProvider);
    ref.invalidate(connectionStatusProvider);
    ref.invalidate(mediaHeadersProvider);
    ref.invalidate(mediaPlaybackHeadersProvider);

    await ref.read(authProvider.notifier).refreshCookieHeader();

    ref.invalidate(sceneListProvider);
    ref.invalidate(sceneDetailsProvider);
    ref.invalidate(streamResolverProvider);

    ref.invalidate(performerListProvider);
    ref.invalidate(performerDetailsProvider);
    ref.invalidate(performerMediaProvider);
    ref.invalidate(performerMediaGridProvider);

    ref.invalidate(studioListProvider);
    ref.invalidate(studioDetailsProvider);
    ref.invalidate(studioMediaProvider);
    ref.invalidate(studioMediaGridProvider);

    ref.invalidate(tagListProvider);
    ref.invalidate(tagDetailsProvider);
    ref.invalidate(tagMediaProvider);
    ref.invalidate(tagMediaGridProvider);

    ref.invalidate(galleryListProvider);
    ref.invalidate(galleryDetailsProvider);
    ref.invalidate(groupListProvider);
    ref.invalidate(groupDetailsProvider);
  }

  void _showProfileDrawer([ServerProfile? profile]) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => ServerProfileDrawer(profile: profile),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final profiles = ref.watch(serverProfilesProvider);

    ref.listen(activeServerProfileIdProvider, (previous, next) async {
      if (previous != next && next != null) {
        await _flushRuntimeCachesAfterServerChange();
        
        final profile = ref.read(activeProfileProvider);
        if (profile != null && profile.authMode == AuthMode.password) {
          ref.read(authProvider.notifier).login();
        }
      }
    });

    return SettingsPageShell(
      title: '${l10n.settings_server} ${l10n.settings_title}',
      floatingActionButton: FloatingActionButton(
        tooltip: l10n.settings_server_profile_add,
        onPressed: () => _showProfileDrawer(),
        child: const Icon(Icons.add),
      ),
      child: profiles.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.dns_rounded,
                    size: 64 * context.dimensions.fontSizeFactor,
                    color: Colors.grey,
                  ),
                  SizedBox(height: context.dimensions.spacingMedium),
                  Text(
                    l10n.settings_server_profile_empty,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  SizedBox(height: context.dimensions.spacingLarge),
                  ElevatedButton.icon(
                    onPressed: () => _showProfileDrawer(),
                    icon: const Icon(Icons.add),
                    label: Text(l10n.settings_server_profile_add),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: EdgeInsets.all(context.dimensions.spacingMedium),
              itemCount: profiles.length,
              itemBuilder: (context, index) {
                final profile = profiles[index];
                return ServerProfileCard(
                  profile: profile,
                  onEdit: () => _showProfileDrawer(profile),
                );
              },
            ),
    );
  }
}
