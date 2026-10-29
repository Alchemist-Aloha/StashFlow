#include <cstdlib>
#include <cstring>
#include <memory>
#include <stdexcept>
#include <string>
#include <vector>
#include <ctranslate2/translator.h>
#include <sentencepiece_processor.h>

#ifdef _WIN32
#define SF_EXPORT extern "C" __declspec(dllexport)
#else
#define SF_EXPORT extern "C" __attribute__((visibility("default")))
#endif

namespace {
struct Translator {
  sentencepiece::SentencePieceProcessor source;
  sentencepiece::SentencePieceProcessor target;
  std::unique_ptr<ctranslate2::Translator> engine;
};

char* copy_string(const std::string& value) {
  auto* result = static_cast<char*>(std::malloc(value.size() + 1));
  if (!result) throw std::bad_alloc();
  std::memcpy(result, value.c_str(), value.size() + 1);
  return result;
}
void fail(char** error) noexcept {
  // Errors can include user text or model paths. Never send those to logs/UI.
  if (error) {
    try { *error = copy_string("Local translation failed"); } catch (...) {}
  }
}
}

// A handle is isolate-confined: close only after its last translation completes.
// All returned strings, including errors, must be released with sf_translation_free.
SF_EXPORT void* sf_translation_open(const char* directory, char** error) noexcept {
  if (error) *error = nullptr;
  try {
    if (!directory || !*directory) throw std::invalid_argument("directory");
    const std::string root(directory);
    auto result = std::make_unique<Translator>();
    if (!result->source.Load(root + "/source.spm").ok() ||
        !result->target.Load(root + "/target.spm").ok())
      throw std::runtime_error("tokenizer");
    ctranslate2::ReplicaPoolConfig config;
    config.num_threads_per_replica = 2;
    config.max_queued_batches = 1;
    result->engine = std::make_unique<ctranslate2::Translator>(
      root, ctranslate2::Device::CPU, ctranslate2::ComputeType::AUTO,
      std::vector<int>{0}, false, config);
    return result.release();
  } catch (...) {
    fail(error);
    return nullptr;
  }
}

SF_EXPORT char* sf_translation_run(void* handle, const char* text,
                                   const char* language_token, char** error) noexcept {
  if (error) *error = nullptr;
  try {
    if (!handle || !text || std::strlen(text) > 16384)
      throw std::invalid_argument("input");
    auto& translator = *static_cast<Translator*>(handle);
    std::vector<std::string> tokens;
    if (!translator.source.Encode(text, &tokens).ok())
      throw std::runtime_error("tokenize");
    if (tokens.size() > 256) throw std::invalid_argument("too long");
    if (language_token && *language_token) tokens.insert(tokens.begin(), language_token);
    tokens.emplace_back("</s>"); // Marian tokenizer's EOS; CT2 config does not add it.
    ctranslate2::TranslationOptions options;
    options.beam_size = 1;
    options.max_input_length = 258;
    options.max_decoding_length = 256;
    const auto results = translator.engine->translate_batch({tokens}, options);
    std::string output;
    if (results.empty() || results.front().hypotheses.empty() ||
        !translator.target.Decode(results.front().hypotheses.front(), &output).ok())
      throw std::runtime_error("translate");
    return copy_string(output);
  } catch (...) {
    fail(error);
    return nullptr;
  }
}
SF_EXPORT void sf_translation_close(void* handle) noexcept {
  delete static_cast<Translator*>(handle);
}
SF_EXPORT void sf_translation_free(void* text) noexcept {
  std::free(text);
}
