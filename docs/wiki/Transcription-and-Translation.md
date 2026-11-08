# Transcription and Translation

StashFlow can generate subtitles from a scene's audio and optionally translate them into another language. This works even when the scene has no server-provided subtitles.

Speech recognition and translation run **on your device's CPU only**, without GPU acceleration or a cloud transcription service. You download the models first; they are not bundled with the app. Processing speed depends on your CPU and the selected models.

> **Availability:** Requires native playback on Android or desktop. On-device subtitle generation is not available in the web app or while casting. Processing speed and accuracy depend on your hardware, models, and audio quality.

## Recommended setup

- **Speech model:** Start with **`sherpa-onnx-whisper-small`**. Search for this name in the speech-model catalog and choose a compatible multilingual export, rather than an English-only `.en` variant if you need other languages.
- **Source language:** When translating, **set the language actually spoken in the audio** instead of leaving it on **Detect automatically**.
- **Translation model:** Download a compatible model for the exact **source → output** language pair. A speech model alone does not provide translation.

The recommended speech model is a starting point, not a guarantee of real-time performance. If it is too slow or uses too much memory, try a smaller compatible speech model such as Whisper tiny or base. Check each model's details, download size, and license before downloading.

## Generate subtitles

1. Start playing a scene in the native app.
2. Open the player's **subtitle menu** and choose **Transcribe audio**.
3. Under **Speech models**, select an installed model. If you do not have one, expand **Download speech models**, search for `sherpa-onnx-whisper-small`, inspect the model, and download it.
4. Choose the **Source language**. You can use **Detect automatically** with a supported multilingual model, or select the spoken language yourself.
5. Leave **Translate audio** off to show the recognized speech without translation.
6. Choose **Apply** and wait for subtitle preparation to finish.

You can also download and manage models beforehand under **Settings → Playback → On-device subtitles**.

**Apply** becomes available once the required models are installed and no download is in progress. **Cancel** discards configuration changes but keeps any completed model downloads.

## Translate subtitles

Translation is an option inside the same transcription dialog—not a separate subtitle-menu action.

1. Open **subtitle menu → Transcribe audio**.
2. Select a speech model.
3. **Set Source language explicitly** to match the audio.
4. Turn on **Translate audio** and choose the **Output language** you want to read.
5. Download or select a compatible translation model for that language pair. Use **Download translation models** in the dialog, or manage models in Playback settings.
6. Optionally enable **Show original with translation** to display both texts.
7. Choose **Apply**.

For example, to translate Japanese speech into English, set **Source language = Japanese**, **Output language = English**, and install a compatible **Japanese → English** translation model. An English → Japanese model is the opposite direction and will not work for this setup.

### Why set the source language?

Automatic detection runs on individual speech segments. Short phrases, background noise, and mixed-language audio can lead to incorrect detection. During translation, that detected language also determines which translation model is needed.

Setting the source language explicitly removes that ambiguity and keeps translation routed to the intended language pair. It disables automatic detection until you select **Detect automatically** again and apply the change. Choose the language spoken in the audio—not the app's interface language or your desired translation language.

If you use automatic detection, **Automatic (downloaded models)** selects a matching installed translation model for each detected source language. It does not download missing pairs automatically. A missing pair produces a recovery message rather than falling back to an unrelated language.

## Subtitle appearance and playback

- Generated subtitles use the font size, alignment, and vertical position configured in **[Settings → Playback](Settings-Reference#subtitles)**.
- Captions follow the same playback session across inline, fullscreen, feed, and PiP views.
- Starting transcription disables the selected server subtitle track. Select **None** or a server subtitle track to stop generation.
- Starting generation and seeking to an uncached position require preparation time. Subtitle timing follows speech phrases, not individual words.
- Applied model, language, and tuning preferences are remembered between app sessions, but generation itself is session-scoped. Changing scenes or audio tracks stops it; start it again from the subtitle menu when needed.

## Advanced settings

Start with the defaults and change one setting at a time.

| Setting | Default | Range / purpose |
|---------|---------|-----------------|
| **Speech recognition threads** | 2 | 1–8; controls speech-recognition worker threads. More threads do not guarantee faster results on every device. |
| **Audio window** | 6 seconds | 4–12 seconds of audio processed per window. |
| **Speech detection threshold** | 0.5 | 0.2–0.8; lower values include quieter speech, while higher values reject more noise. |
| **Subtitle delay** | 0 | −5 to +5 seconds; adjusts subtitle timing. |
| **Show original with translation** | Off | Displays the recognized source text alongside its translation. |

## Troubleshooting

| Problem | What to try |
|---------|-------------|
| **Apply is unavailable** | Wait for model loading or downloads to finish. Select an installed speech model and, when translating, a matching translation model. |
| **No downloaded model for source → target** | Check the source and output languages and download the correct directional pair. If detection selected the wrong language, set the source language explicitly. |
| **Wrong language or poor translation** | Set the spoken source language explicitly, check the selected audio track, and verify the translation model's direction. Translation depends on the accuracy of the transcription. |
| **Preparation is slow or subtitles lag** | Allow time after starting or seeking. Try a smaller speech model and compare thread settings. Real-time processing is not guaranteed. |
| **Quiet speech is missed or noise becomes text** | Adjust the speech detection threshold under Advanced settings. |
| **Catalog or download fails** | Check connectivity and available storage, then retry. Only compatible model layouts are supported. |
| **Generation stops after changing scenes or audio tracks** | Reopen the subtitle menu and start transcription for the new playback session. |

## Privacy, storage, and backups

Model browsing and downloads require an internet connection and may use mobile data. Once installed, models can be reused offline; playing media from your Stash server still requires access to that media.

Audio and recognized text are processed locally. Generated captions are temporary session data, not a saved SRT file or an upload to your Stash server.

Manage installed models under **Settings → Playback → On-device subtitles**. Removing a model stops active generation before deleting its files. Configuration backups include model selections and tuning preferences, but **not model weights or generated text**; models must be downloaded separately on another device.
