#include <cstdint>
#include <cstdlib>
#include <cstring>
#include <memory>
#include <fstream>
#include <stdexcept>
#include <string>
#include <vector>
#include <ctranslate2/translator.h>
#include <nlohmann/json.hpp>
#include <sentencepiece_processor.h>

#ifdef _WIN32
#define SF_EXPORT extern "C" __declspec(dllexport)
#else
#define SF_EXPORT extern "C" __attribute__((visibility("default")))
#endif

namespace {
constexpr std::size_t kMaxTextBytes = 16384;
constexpr std::size_t kMaxTokens = 256;
constexpr int32_t kMaxBatch = 64;

struct Translator {
  sentencepiece::SentencePieceProcessor source;
  sentencepiece::SentencePieceProcessor target;
  std::unique_ptr<ctranslate2::Translator> engine;
  bool append_source_eos = true;
  std::string source_eos = "</s>";
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

std::vector<std::string> encode(Translator& translator, const char* text,
                                const char* language_token) {
  if (!text || std::strlen(text) > kMaxTextBytes)
    throw std::invalid_argument("input");
  std::vector<std::string> tokens;
  if (!translator.source.Encode(text, &tokens).ok())
    throw std::runtime_error("tokenize");
  if (tokens.size() > kMaxTokens) throw std::invalid_argument("too long");
  if (language_token && *language_token) tokens.insert(tokens.begin(), language_token);
  if (translator.append_source_eos) tokens.emplace_back(translator.source_eos);
  return tokens;
}
}

// A handle is isolate-confined: close only after its last translation completes.
// All returned strings, including errors, must be released with sf_translation_free.
// `threads` is CTranslate2's intra-op thread count (clamped to 1-8).
SF_EXPORT void* sf_translation_open(const char* directory, int32_t threads,
                                    char** error) noexcept {
  if (error) *error = nullptr;
  try {
    if (!directory || !*directory) throw std::invalid_argument("directory");
    const std::string root(directory);
    auto result = std::make_unique<Translator>();
    if (!result->source.Load(root + "/source.spm").ok() ||
        !result->target.Load(root + "/target.spm").ok())
      throw std::runtime_error("tokenizer");
    std::ifstream config_file(root + "/config.json");
    const auto model_config = nlohmann::json::parse(config_file);
    result->append_source_eos = !model_config.value("add_source_eos", false);
    result->source_eos = model_config.value("eos_token", std::string("</s>"));
    ctranslate2::ReplicaPoolConfig config;
    config.num_threads_per_replica =
        static_cast<std::size_t>(threads < 1 ? 1 : threads > 8 ? 8 : threads);
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

// Translates `count` texts in one CTranslate2 batch. On success writes `count`
// owned strings to `outputs` and returns 1; on failure writes no outputs.
SF_EXPORT int32_t sf_translation_run_batch(void* handle, const char* const* texts,
                                           int32_t count, const char* language_token,
                                           char** outputs, char** error) noexcept {
  if (error) *error = nullptr;
  std::vector<char*> owned;
  try {
    if (!handle || !texts || !outputs || count < 1 || count > kMaxBatch)
      throw std::invalid_argument("input");
    auto& translator = *static_cast<Translator*>(handle);
    std::vector<std::vector<std::string>> batch;
    batch.reserve(static_cast<std::size_t>(count));
    for (int32_t i = 0; i < count; ++i)
      batch.push_back(encode(translator, texts[i], language_token));
    ctranslate2::TranslationOptions options;
    options.beam_size = 1;
    options.max_input_length = kMaxTokens + 2;
    options.max_decoding_length = kMaxTokens;
    const auto results = translator.engine->translate_batch(batch, options);
    if (results.size() != batch.size()) throw std::runtime_error("translate");
    owned.reserve(results.size());
    for (const auto& result : results) {
      std::string output;
      if (result.hypotheses.empty() ||
          !translator.target.Decode(result.hypotheses.front(), &output).ok())
        throw std::runtime_error("translate");
      owned.push_back(copy_string(output));
    }
    for (std::size_t i = 0; i < owned.size(); ++i) outputs[i] = owned[i];
    return 1;
  } catch (...) {
    for (auto* text : owned) std::free(text);
    fail(error);
    return 0;
  }
}

SF_EXPORT void sf_translation_close(void* handle) noexcept {
  delete static_cast<Translator*>(handle);
}
SF_EXPORT void sf_translation_free(void* text) noexcept {
  std::free(text);
}
