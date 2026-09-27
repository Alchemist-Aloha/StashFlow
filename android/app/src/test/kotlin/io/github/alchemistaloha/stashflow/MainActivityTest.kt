package io.github.alchemistaloha.stashflow

import android.content.Context
import android.media.AudioManager
import org.junit.Assert.assertEquals
import org.junit.Assert.assertNull
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

    class TestMainActivity : MainActivity() {
        var recentsScreenshotEnabledValue: Boolean? = null

        override fun setRecentsScreenshotEnabledCompat(enabled: Boolean) {
            recentsScreenshotEnabledValue = enabled
        }
    }
}
