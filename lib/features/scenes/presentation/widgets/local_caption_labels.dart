import 'package:flutter/widgets.dart';
import '../../../../core/utils/l10n_extensions.dart';
import '../../data/local_captions/local_caption_model.dart';

/// Localized CLDR names also cover languages outside the app's UI locales.
String localCaptionLanguageLabel(BuildContext context, String language) =>
    switch (language) {
      'auto' => context.l10n.local_captions_automatic,
      'und' => context.l10n.local_captions_model_default,
      'zh' => context.l10n.local_captions_chinese_simplified,
      _ => context.l10n.local_captions_language_name(
        language.replaceAll('-', '_'),
      ),
    };

String localCaptionModelLabel(BuildContext context, LocalCaptionModel model) {
  final source = model.sourceLanguages.length > 1
      ? context.l10n.local_captions_multilingual
      : localCaptionLanguageLabel(context, model.source);
  final language = model.target == null
      ? source
      : context.l10n.local_captions_pair(
          localCaptionLanguageLabel(context, model.source),
          localCaptionLanguageLabel(context, model.target!),
        );
  return context.l10n.local_captions_model(
    model.displayName ??
        switch (model.engine) {
          'marian' => 'Marian',
          'whisper' => 'Whisper tiny',
          _ => 'Zipformer',
        },
    language,
  );
}
