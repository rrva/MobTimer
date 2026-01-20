package com.mobtimer.intellij

import com.intellij.ide.AppLifecycleListener
import com.intellij.openapi.diagnostic.Logger

class MobTimerPlugin : AppLifecycleListener {
    private val logger = Logger.getInstance(MobTimerPlugin::class.java)

    override fun appFrameCreated(commandLineArgs: MutableList<String>) {
        logger.info("MobTimer plugin: Starting keymap API server...")
        KeymapApiService.start()
    }

    override fun appWillBeClosed(isRestart: Boolean) {
        logger.info("MobTimer plugin: Stopping keymap API server...")
        KeymapApiService.stop()
    }
}
