package com.mobtimer.intellij

import com.intellij.openapi.application.ApplicationManager
import com.intellij.openapi.diagnostic.Logger
import com.intellij.openapi.keymap.ex.KeymapManagerEx
import io.ktor.http.*
import io.ktor.serialization.kotlinx.json.*
import io.ktor.server.application.*
import io.ktor.server.cio.*
import io.ktor.server.engine.*
import io.ktor.server.plugins.contentnegotiation.*
import io.ktor.server.request.*
import io.ktor.server.response.*
import io.ktor.server.routing.*
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.SupervisorJob
import kotlinx.coroutines.launch
import kotlinx.serialization.Serializable

object KeymapApiService {
    private val logger = Logger.getInstance(KeymapApiService::class.java)
    private val scope = CoroutineScope(SupervisorJob() + Dispatchers.IO)
    private var server: EmbeddedServer<CIOApplicationEngine, CIOApplicationEngine.Configuration>? = null
    private const val PORT = 8765

    fun start() {
        scope.launch {
            try {
                server = embeddedServer(CIO, port = PORT) {
                    install(ContentNegotiation) {
                        json()
                    }
                    configureRouting()
                }.start(wait = false)
                logger.info("MobTimer API server started on port $PORT")
            } catch (e: Exception) {
                logger.error("Failed to start MobTimer API server", e)
            }
        }
    }

    fun stop() {
        server?.stop(1000, 2000)
        server = null
        logger.info("MobTimer API server stopped")
    }

    private fun Application.configureRouting() {
        routing {
            get("/api/health") {
                call.respond(HttpStatusCode.OK, HealthResponse(status = "ok"))
            }

            get("/api/keymaps") {
                val keymaps = getAvailableKeymaps()
                call.respond(KeymapsResponse(keymaps = keymaps))
            }

            get("/api/keymap") {
                val currentKeymap = getCurrentKeymap()
                call.respond(KeymapResponse(name = currentKeymap))
            }

            post("/api/keymap") {
                val request = call.receive<SetKeymapRequest>()
                val success = setKeymap(request.name)
                if (success) {
                    call.respond(HttpStatusCode.OK, KeymapResponse(name = request.name))
                } else {
                    call.respond(HttpStatusCode.NotFound, ErrorResponse(error = "Keymap not found: ${request.name}"))
                }
            }
        }
    }

    private fun getAvailableKeymaps(): List<String> {
        return ApplicationManager.getApplication().runReadAction<List<String>> {
            val manager = KeymapManagerEx.getInstanceEx()
            manager.allKeymaps.map { it.name }.sorted()
        }
    }

    private fun getCurrentKeymap(): String {
        return ApplicationManager.getApplication().runReadAction<String> {
            val manager = KeymapManagerEx.getInstanceEx()
            manager.activeKeymap?.name ?: "Unknown"
        }
    }

    private fun setKeymap(name: String): Boolean {
        return ApplicationManager.getApplication().runWriteAction<Boolean> {
            val manager = KeymapManagerEx.getInstanceEx()
            val keymap = manager.allKeymaps.find { it.name == name }
            if (keymap != null) {
                manager.activeKeymap = keymap
                logger.info("Switched keymap to: $name")
                true
            } else {
                logger.warn("Keymap not found: $name")
                false
            }
        }
    }

    @Serializable
    data class HealthResponse(val status: String)

    @Serializable
    data class KeymapsResponse(val keymaps: List<String>)

    @Serializable
    data class KeymapResponse(val name: String)

    @Serializable
    data class SetKeymapRequest(val name: String)

    @Serializable
    data class ErrorResponse(val error: String)
}
