package io.github.alchemistaloha.stashflow

import android.app.PictureInPictureParams
import android.content.Context
import android.content.res.Configuration
import android.media.AudioManager
import android.os.Build
import android.os.Bundle
import android.util.Rational
import io.flutter.embedding.engine.FlutterEngine
import com.ryanheise.audioservice.AudioServiceActivity
import io.flutter.plugin.common.MethodChannel
import kotlin.math.roundToInt

open class MainActivity : AudioServiceActivity() {
	private val pipChannel = "stash_app_flutter/pip"
	private val volumeChannel = "stash_app_flutter/media_volume"
	private var channel: MethodChannel? = null
	private var pendingMediaVolumeSteps = 0.0

	override fun onCreate(savedInstanceState: Bundle?) {
		super.onCreate(savedInstanceState)
		applyRecentsScreenshotPolicy()
	}

	override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
		super.configureFlutterEngine(flutterEngine)

		channel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, pipChannel)
		channel?.setMethodCallHandler { call, result ->
			when (call.method) {
				"enterPictureInPicture" -> {
					val numerator = call.argument<Int>("numerator") ?: 1
					val denominator = call.argument<Int>("denominator") ?: 1
					result.success(enterPipMode(numerator, denominator))
				}
				"updatePictureInPictureAspectRatio" -> {
					val numerator = call.argument<Int>("numerator") ?: 0
					val denominator = call.argument<Int>("denominator") ?: 0
					result.success(updatePipAspectRatio(numerator, denominator))
				}
				"getPrimaryAbi" -> {
					result.success(Build.SUPPORTED_ABIS.firstOrNull())
				}
				else -> result.notImplemented()
			}
		}

		MethodChannel(flutterEngine.dartExecutor.binaryMessenger, volumeChannel)
			.setMethodCallHandler { call, result ->
				when (call.method) {
					"adjustMediaVolume" -> {
						val delta = call.argument<Double>("delta")
						if (delta == null || !delta.isFinite()) {
							result.error("invalid_volume", "Volume delta must be a finite number.", null)
						} else {
							result.success(adjustMediaVolume(delta))
						}
					}
					else -> result.notImplemented()
				}
			}
	}

	internal fun adjustMediaVolume(delta: Double): Double? = try {
		val audioManager = getSystemService(Context.AUDIO_SERVICE) as? AudioManager ?: return null
		val maximum = audioManager.getStreamMaxVolume(AudioManager.STREAM_MUSIC)
		if (maximum <= 0) return null

		pendingMediaVolumeSteps += delta * maximum
		val adjustment = pendingMediaVolumeSteps.roundToInt()
		val current = audioManager.getStreamVolume(AudioManager.STREAM_MUSIC)
		val unclampedTarget = current + adjustment
		val target = unclampedTarget.coerceIn(0, maximum)
		pendingMediaVolumeSteps = if (target == unclampedTarget) {
			pendingMediaVolumeSteps - adjustment
		} else {
			0.0
		}
		audioManager.setStreamVolume(
			AudioManager.STREAM_MUSIC,
			target,
			AudioManager.FLAG_SHOW_UI,
		)
		audioManager.getStreamVolume(AudioManager.STREAM_MUSIC).toDouble() / maximum
	} catch (_: Throwable) {
		null
	}

	private fun enterPipMode(numerator: Int, denominator: Int): Boolean {
		if (Build.VERSION.SDK_INT < Build.VERSION_CODES.O) {
			return false
		}
		return try {
			enterPictureInPictureMode(pipParams(numerator, denominator))
		} catch (_: Throwable) {
			false
		}
	}

	internal fun updatePipAspectRatio(numerator: Int, denominator: Int): Boolean {
		if (Build.VERSION.SDK_INT < Build.VERSION_CODES.O || !isInPictureInPictureMode) {
			return false
		}
		return try {
			setPictureInPictureParams(pipParams(numerator, denominator))
			true
		} catch (_: Throwable) {
			false
		}
	}

	@android.annotation.TargetApi(Build.VERSION_CODES.O)
	private fun pipParams(numerator: Int, denominator: Int): PictureInPictureParams {
		require(numerator > 0 && denominator > 0)
		val ratio = numerator.toDouble() / denominator
		require(ratio in (1.0 / 2.39)..2.39)
		return PictureInPictureParams.Builder()
			.setAspectRatio(Rational(numerator, denominator))
			.build()
	}

	internal fun applyRecentsScreenshotPolicy() {
		if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
			setRecentsScreenshotEnabledCompat(false)
		}
	}

	internal open fun setRecentsScreenshotEnabledCompat(enabled: Boolean) {
		if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
			setRecentsScreenshotEnabled(enabled)
		}
	}

	override fun onPictureInPictureModeChanged(isInPictureInPictureMode: Boolean, newConfig: Configuration?) {
		super.onPictureInPictureModeChanged(isInPictureInPictureMode, newConfig)
		channel?.invokeMethod("pipModeChanged", isInPictureInPictureMode)
	}
}
