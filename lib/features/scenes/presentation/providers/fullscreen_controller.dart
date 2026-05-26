enum FullscreenPhase { inline, entering, fullscreen, exiting, tiktok }

class FullscreenRuntimeState {
  final bool isFullScreen;
  final String viewModeName;
  final FullscreenPhase fullscreenPhase;

  const FullscreenRuntimeState({
    required this.isFullScreen,
    required this.viewModeName,
    required this.fullscreenPhase,
  });
}

class FullscreenController {
  const FullscreenController();

  FullscreenRuntimeState syncFromLegacy({
    required bool isFullScreen,
    required String viewModeName,
  }) {
    if (viewModeName == 'tiktok') {
      return FullscreenRuntimeState(
        isFullScreen: isFullScreen,
        viewModeName: viewModeName,
        fullscreenPhase: FullscreenPhase.tiktok,
      );
    }
    return FullscreenRuntimeState(
      isFullScreen: isFullScreen,
      viewModeName: viewModeName,
      fullscreenPhase: isFullScreen
          ? FullscreenPhase.fullscreen
          : FullscreenPhase.inline,
    );
  }

  FullscreenRuntimeState requestEnterFullscreen({
    required String viewModeName,
  }) {
    return FullscreenRuntimeState(
      isFullScreen: true,
      viewModeName: viewModeName == 'tiktok' ? 'tiktok' : 'fullscreen',
      fullscreenPhase: FullscreenPhase.entering,
    );
  }

  FullscreenRuntimeState markEntered({required String viewModeName}) {
    return FullscreenRuntimeState(
      isFullScreen: true,
      viewModeName: viewModeName,
      fullscreenPhase: viewModeName == 'tiktok'
          ? FullscreenPhase.tiktok
          : FullscreenPhase.fullscreen,
    );
  }

  FullscreenRuntimeState requestExitFullscreen() {
    return const FullscreenRuntimeState(
      isFullScreen: false,
      viewModeName: 'inline',
      fullscreenPhase: FullscreenPhase.exiting,
    );
  }

  FullscreenRuntimeState markExited() {
    return const FullscreenRuntimeState(
      isFullScreen: false,
      viewModeName: 'inline',
      fullscreenPhase: FullscreenPhase.inline,
    );
  }
}
