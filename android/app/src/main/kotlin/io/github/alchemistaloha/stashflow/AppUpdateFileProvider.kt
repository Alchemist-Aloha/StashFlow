package io.github.alchemistaloha.stashflow

import androidx.core.content.FileProvider

/**
 * Grants the system package installer read access to downloaded update APKs.
 *
 * A dedicated subclass keeps this provider from colliding with plugin
 * FileProvider declarations during manifest merging.
 */
class AppUpdateFileProvider : FileProvider()
