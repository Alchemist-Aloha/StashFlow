import 'dart:convert';

/// Persisted inference preferences. Bounds are also enforced on backup import.
class CaptionOptions {
  const CaptionOptions({
    this.sourceLanguage = 'auto',
    this.outputLanguage = 'en',
    this.threads = 2,
    this.windowSeconds = 6,
    this.speechThreshold = 0.5,
    this.delayMilliseconds = 0,
    this.bilingual = false,
    this.translate = false,
  });
  final String sourceLanguage, outputLanguage;
  final int threads, windowSeconds, delayMilliseconds;
  final double speechThreshold;
  final bool bilingual;

  /// Whether the transcription dialog should also enable translation.
  final bool translate;

  bool get isValid =>
      (sourceLanguage == 'auto' ||
          sourceLanguage == 'und' ||
          captionLanguageCodes.contains(sourceLanguage)) &&
      captionOutputLanguages.contains(outputLanguage) &&
      threads >= 1 &&
      threads <= 8 &&
      windowSeconds >= 4 &&
      windowSeconds <= 12 &&
      speechThreshold.isFinite &&
      speechThreshold >= 0.2 &&
      speechThreshold <= 0.8 &&
      delayMilliseconds >= -5000 &&
      delayMilliseconds <= 5000;

  Map<String, Object> toJson() => {
    'source': sourceLanguage,
    'output': outputLanguage,
    'threads': threads,
    'window': windowSeconds,
    'threshold': speechThreshold,
    'delay': delayMilliseconds,
    'bilingual': bilingual,
    'translate': translate,
  };

  static CaptionOptions? parse(String? text) {
    if (text == null || text.length > 2048) return null;
    try {
      final json = jsonDecode(text) as Map<String, dynamic>;
      final result = CaptionOptions(
        sourceLanguage: json['source'] as String,
        outputLanguage: json['output'] as String,
        threads: json['threads'] as int,
        windowSeconds: json['window'] as int,
        speechThreshold: (json['threshold'] as num).toDouble(),
        delayMilliseconds: json['delay'] as int,
        bilingual: json['bilingual'] as bool,
        translate: json.containsKey('translate')
            ? json['translate'] as bool
            : false,
      );
      return result.isValid ? result : null;
    } on Object {
      return null;
    }
  }

  CaptionOptions copyWith({
    String? sourceLanguage,
    String? outputLanguage,
    int? threads,
    int? windowSeconds,
    double? speechThreshold,
    int? delayMilliseconds,
    bool? bilingual,
    bool? translate,
  }) => CaptionOptions(
    sourceLanguage: sourceLanguage ?? this.sourceLanguage,
    outputLanguage: outputLanguage ?? this.outputLanguage,
    threads: threads ?? this.threads,
    windowSeconds: windowSeconds ?? this.windowSeconds,
    speechThreshold: speechThreshold ?? this.speechThreshold,
    delayMilliseconds: delayMilliseconds ?? this.delayMilliseconds,
    bilingual: bilingual ?? this.bilingual,
    translate: translate ?? this.translate,
  );
}

/// Fixed source languages override recognizer metadata, including translation routing.
String captionResultLanguage(String detected, String source) {
  if (source != 'auto') return source;
  final language = detected
      .replaceAll('<|', '')
      .replaceAll('|>', '')
      .trim()
      .toLowerCase();
  return captionLanguageCodes.contains(language) ? language : 'und';
}

// Whisper's multilingual vocabulary, not the app's interface-language list.
const captionLanguageCodes = [
  'af',
  'am',
  'ar',
  'as',
  'az',
  'ba',
  'be',
  'bg',
  'bn',
  'bo',
  'br',
  'bs',
  'ca',
  'cs',
  'cy',
  'da',
  'de',
  'el',
  'en',
  'es',
  'et',
  'eu',
  'fa',
  'fi',
  'fo',
  'fr',
  'gl',
  'gu',
  'ha',
  'haw',
  'he',
  'hi',
  'hr',
  'ht',
  'hu',
  'hy',
  'id',
  'is',
  'it',
  'ja',
  'jw',
  'ka',
  'kk',
  'km',
  'kn',
  'ko',
  'la',
  'lb',
  'ln',
  'lo',
  'lt',
  'lv',
  'mg',
  'mi',
  'mk',
  'ml',
  'mn',
  'mr',
  'ms',
  'mt',
  'my',
  'ne',
  'nl',
  'nn',
  'no',
  'oc',
  'pa',
  'pl',
  'ps',
  'pt',
  'ro',
  'ru',
  'sa',
  'sd',
  'si',
  'sk',
  'sl',
  'sn',
  'so',
  'sq',
  'sr',
  'su',
  'sv',
  'sw',
  'ta',
  'te',
  'tg',
  'th',
  'tk',
  'tl',
  'tr',
  'tt',
  'uk',
  'ur',
  'uz',
  'vi',
  'yi',
  'yo',
  'zh',
  'yue',
];
const captionOutputLanguages = [...captionLanguageCodes, 'zh-Hant'];

/// Auto-detected speech must never be silently fed into a different language pair.
class CaptionTranslationUnavailable implements Exception {
  const CaptionTranslationUnavailable(this.source, this.target);
  final String source, target;
}
