import 'package:flutter/widgets.dart';
import '../../../../core/utils/l10n_extensions.dart';
import '../../data/local_captions/local_caption_model.dart';

String localCaptionLanguageLabel(BuildContext context, String language) =>
    switch (language) {
      'en' => context.l10n.settings_playback_subtitle_lang_english,
      'zh' => context.l10n.local_captions_chinese_simplified,
      'ja' => context.l10n.settings_playback_subtitle_lang_japanese,
      _ => language,
    };

String localCaptionModelLabel(BuildContext context, LocalCaptionModel model) {
  final source = localCaptionLanguageLabel(context, model.source);
  final language = model.target == null
      ? source
      : context.l10n.local_captions_pair(
          source,
          localCaptionLanguageLabel(context, model.target!),
        );
  return context.l10n.local_captions_model(switch (model.engine) {
    'marian' => 'Marian',
    'whisper' => 'Whisper tiny',
    _ => 'Zipformer',
  }, language);
}
