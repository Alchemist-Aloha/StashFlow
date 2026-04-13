package io.github.alchemistaloha.stashflow

import android.app.PictureInPictureParams
import android.content.res.Configuration
import android.os.Build
import android.util.Rational
import io.flutter.embedding.engine.FlutterEngine
import com.ryanheise.audioservice.AudioServiceActivity
import io.flutter.plugin.common.MethodChannel

class MainActivity : AudioServiceActivity() {
	private val pipChannel = "stash_app_flutter/pip"
	private var channel: MethodChannel? = null

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
				else -> result.notImplemented()
			}
		}
	}

	private fun enterPipMode(numerator: Int, denominator: Int): Boolean {
		if (Build.VERSION.SDK_INT < Build.VERSION_CODES.O) {
			return false
		}
		return try {
			val builder = PictureInPictureParams.Builder()
			val aspectRatio = Rational(numerator, denominator)
			builder.setAspectRatio(aspectRatio)
			enterPictureInPictureMode(builder.build())
		} catch (_: Throwable) {
			false
		}
	}

	override fun onPictureInPictureModeChanged(isInPictureInPictureMode: Boolean, newConfig: Configuration?) {
		super.onPictureInPictureModeChanged(isInPictureInPictureMode, newConfig)
		channel?.invokeMethod("pipModeChanged", isInPictureInPictureMode)
	}
}
