package io.github.alchemistaloha.stashflow

import android.app.PictureInPictureParams
import android.content.Context
import android.content.Intent
import android.content.res.Configuration
import android.media.AudioManager
import android.net.Uri
import android.os.Build
import android.os.Bundle
import android.provider.Settings
import android.util.Rational
import android.util.Log
import androidx.core.content.FileProvider
import io.flutter.embedding.engine.FlutterEngine
import com.ryanheise.audioservice.AudioServiceFragmentActivity
import io.flutter.plugin.common.MethodChannel
import java.io.File
import kotlin.math.roundToInt

open class MainActivity : AudioServiceFragmentActivity() {
	private val pipChannel = "stash_app_flutter/pip"
	private val appUpdateChannel = "stash_app_flutter/app_update"
	private val volumeChannel = "stash_app_flutter/media_volume"
	private var channel: MethodChannel? = null
	private var pendingMediaVolumeSteps = 0.0
	// Set by Dart while a scene plays locally and auto-PiP is on.
	private var autoPipRatio: Rational? = null

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
				"setAutoPip" -> {
					val numerator = call.argument<Int>("numerator") ?: 0
					val denominator = call.argument<Int>("denominator") ?: 0
					result.success(setAutoPip(call.argument<Boolean>("enabled") == true, numerator, denominator))
				}
				"getPrimaryAbi" -> {
					result.success(Build.SUPPORTED_ABIS.firstOrNull())
				}
				else -> result.notImplemented()
			}
		}

		MethodChannel(flutterEngine.dartExecutor.binaryMessenger, appUpdateChannel)
			.setMethodCallHandler { call, result ->
				when (call.method) {
					"canRequestPackageInstalls" -> result.success(canInstallPackages())
					"installApk" -> {
						val path = call.argument<String>("path")
						if (path.isNullOrEmpty()) {
							result.error("invalid_path", "APK path is required.", null)
						} else {
							result.success(installApk(File(path)))
						}
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

	internal fun canInstallPackages(): Boolean =
		Build.VERSION.SDK_INT < Build.VERSION_CODES.O || packageManager.canRequestPackageInstalls()

	/**
	 * Opens the system installer for an APK inside the app_update cache folder.
	 *
	 * Returns "permission_required" after opening the per-app "install unknown
	 * apps" settings screen when that permission is missing, "started" when the
	 * installer opens, and "failed" otherwise.
	 */
	internal fun installApk(apk: File): String {
		val updateDirectory = File(cacheDir, "app_update").canonicalFile
		val canonicalApk = apk.canonicalFile
		if (canonicalApk.parentFile != updateDirectory || !canonicalApk.isFile) {
			Log.w("StashFlow", "Rejected update APK outside the update cache")
			return "failed"
		}
		if (!canInstallPackages()) {
			return try {
				startActivity(
					Intent(
						Settings.ACTION_MANAGE_UNKNOWN_APP_SOURCES,
						Uri.parse("package:$packageName"),
					),
				)
				"permission_required"
			} catch (error: Throwable) {
				Log.w("StashFlow", "Failed to open install permission settings", error)
				"failed"
			}
		}
		return try {
			val uri = FileProvider.getUriForFile(this, "$packageName.app_update", canonicalApk)
			val intent = Intent(Intent.ACTION_VIEW)
				.setDataAndType(uri, "application/vnd.android.package-archive")
				.addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION)
			startActivity(intent)
			"started"
		} catch (error: Throwable) {
			Log.w("StashFlow", "Failed to open the package installer", error)
			"failed"
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
	} catch (error: Throwable) {
		Log.w("StashFlow", "Failed to adjust media volume", error)
		null
	}

	private fun enterPipMode(numerator: Int, denominator: Int): Boolean {
		if (Build.VERSION.SDK_INT < Build.VERSION_CODES.O) {
			return false
		}
		return try {
			enterPictureInPictureMode(pipParams(numerator, denominator))
		} catch (error: Throwable) {
			Log.w("StashFlow", "Failed to enter picture-in-picture", error)
			false
		}
	}

	/** Android 12+ lets the system enter PiP itself; older versions use [onUserLeaveHint]. */
	private fun setAutoPip(enabled: Boolean, numerator: Int, denominator: Int): Boolean {
		if (Build.VERSION.SDK_INT < Build.VERSION_CODES.O) return false
		autoPipRatio = if (enabled && numerator > 0 && denominator > 0) Rational(numerator, denominator) else null
		if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
			return try {
				val builder = PictureInPictureParams.Builder().setAutoEnterEnabled(autoPipRatio != null)
				autoPipRatio?.let { builder.setAspectRatio(it) }
				setPictureInPictureParams(builder.build())
				true
			} catch (error: Throwable) {
				Log.w("StashFlow", "Failed to update auto picture-in-picture", error)
				false
			}
		}
		return true
	}

	override fun onUserLeaveHint() {
		super.onUserLeaveHint()
		val ratio = autoPipRatio ?: return
		if (Build.VERSION.SDK_INT in Build.VERSION_CODES.O until Build.VERSION_CODES.S && !isInPictureInPictureMode) {
			enterPipMode(ratio.numerator, ratio.denominator)
		}
	}

	internal fun updatePipAspectRatio(numerator: Int, denominator: Int): Boolean {
		if (Build.VERSION.SDK_INT < Build.VERSION_CODES.O || !isInPictureInPictureMode) {
			return false
		}
		return try {
			setPictureInPictureParams(pipParams(numerator, denominator))
			true
		} catch (error: Throwable) {
			Log.w("StashFlow", "Failed to update picture-in-picture aspect ratio", error)
			false
		}
	}

	@android.annotation.TargetApi(Build.VERSION_CODES.O)
	private fun pipParams(numerator: Int, denominator: Int): PictureInPictureParams {
		require(numerator > 0 && denominator > 0)
		val ratio = numerator.toDouble() / denominator
		require(ratio in (1.0 / 2.39)..2.39)
		val builder = PictureInPictureParams.Builder()
			.setAspectRatio(Rational(numerator, denominator))
		// Params replace the activity's previous ones; keep auto-enter as Dart last set it.
		if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) builder.setAutoEnterEnabled(autoPipRatio != null)
		return builder.build()
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

	override fun onPictureInPictureModeChanged(isInPictureInPictureMode: Boolean, newConfig: Configuration) {
		super.onPictureInPictureModeChanged(isInPictureInPictureMode, newConfig)
		channel?.invokeMethod("pipModeChanged", isInPictureInPictureMode)
	}
}
