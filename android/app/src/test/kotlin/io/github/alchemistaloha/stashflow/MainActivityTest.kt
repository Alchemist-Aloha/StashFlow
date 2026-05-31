package io.github.alchemistaloha.stashflow

import org.junit.Assert.assertEquals
import org.junit.Assert.assertNull
import org.junit.Test
import org.junit.runner.RunWith
import org.robolectric.RobolectricTestRunner
import org.robolectric.annotation.Config

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

    class TestMainActivity : MainActivity() {
        var recentsScreenshotEnabledValue: Boolean? = null

        override fun setRecentsScreenshotEnabledCompat(enabled: Boolean) {
            recentsScreenshotEnabledValue = enabled
        }
    }
}
