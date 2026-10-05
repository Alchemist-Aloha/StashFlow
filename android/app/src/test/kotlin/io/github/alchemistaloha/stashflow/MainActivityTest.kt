package io.github.alchemistaloha.stashflow

import android.app.PictureInPictureParams
import android.util.Rational
import android.content.Context
import android.media.AudioManager
import org.junit.Assert.assertEquals
import org.junit.Assert.assertNull
import org.junit.Assert.assertTrue
import org.junit.Assert.assertFalse
import org.junit.Test
import org.junit.runner.RunWith
import org.robolectric.Robolectric
import org.robolectric.RobolectricTestRunner
import org.robolectric.annotation.Config
import kotlin.math.roundToInt

@RunWith(RobolectricTestRunner::class)
class MainActivityTest {
    @Test
    @Config(sdk = [33])
    fun `disables recents screenshots on android 13 and newer`() {
        val activity = TestMainActivity()
        activity.applyRecentsScreenshotPolicy()

        assertEquals(false, activity.recentsScreenshotEnabledValue)
    }

    @Test
    @Config(sdk = [32])
    fun `keeps default recents screenshot behavior below android 13`() {
        val activity = TestMainActivity()
        activity.applyRecentsScreenshotPolicy()

        assertNull(activity.recentsScreenshotEnabledValue)
    }

    @Test
    fun `small swipe deltas accumulate into a media volume step`() {
        val activity = Robolectric.buildActivity(MainActivity::class.java).get()
        val audioManager = activity.getSystemService(Context.AUDIO_SERVICE) as AudioManager
        val maximum = audioManager.getStreamMaxVolume(AudioManager.STREAM_MUSIC)
        val initial = maximum / 2
        audioManager.setStreamVolume(AudioManager.STREAM_MUSIC, initial, 0)

        repeat(10) { activity.adjustMediaVolume(0.01) }

        assertEquals(initial + (maximum * 0.1).roundToInt(), audioManager.getStreamVolume(AudioManager.STREAM_MUSIC))
    }

    @Test
    @Config(sdk = [33])
    fun `updates active pip ratio without entering again`() {
        val activity = Robolectric.buildActivity(TestMainActivity::class.java).get()
        activity.enterPictureInPictureMode(PictureInPictureParams.Builder().build())

        assertTrue(activity.updatePipAspectRatio(9, 16))
        assertEquals(Rational(9, 16), activity.lastPipParams?.aspectRatio)
        assertTrue(activity.updatePipAspectRatio(16, 9))
        assertEquals(Rational(16, 9), activity.lastPipParams?.aspectRatio)

        assertFalse(activity.updatePipAspectRatio(1, 0))
        assertFalse(activity.updatePipAspectRatio(-1, 1))
        assertFalse(activity.updatePipAspectRatio(1, 100))
        assertEquals(Rational(16, 9), activity.lastPipParams?.aspectRatio)
    }

    @Test
    @Config(sdk = [33])
    fun `does not update pip when the activity is not in pip`() {
        val activity = Robolectric.buildActivity(TestMainActivity::class.java).get()
        assertFalse(activity.updatePipAspectRatio(9, 16))
        assertNull(activity.lastPipParams)
    }

    @Test
    @Config(sdk = [25])
    fun `does not update pip before android 8`() {
        val activity = Robolectric.buildActivity(TestMainActivity::class.java).get()
        assertFalse(activity.updatePipAspectRatio(9, 16))
        assertNull(activity.lastPipParams)
    }

    class TestMainActivity : MainActivity() {
        var recentsScreenshotEnabledValue: Boolean? = null
        var lastPipParams: PictureInPictureParams? = null

        override fun setPictureInPictureParams(params: PictureInPictureParams) {
            lastPipParams = params
        }

        override fun setRecentsScreenshotEnabledCompat(enabled: Boolean) {
            recentsScreenshotEnabledValue = enabled
        }
    }
}
