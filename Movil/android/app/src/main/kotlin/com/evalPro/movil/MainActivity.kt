/**
 * @archivo   MainActivity.kt
 * @descripcion Actividad principal Android. Registra el MethodChannel
 *              para el modo kiosco usando startLockTask() y FLAG_SECURE.
 * @modulo    ModoKiosco (Android nativo)
 * @autor     EvalPro
 * @fecha     2026-03-02
 */
package com.evalpro.movil

import android.content.pm.ApplicationInfo
import android.view.WindowManager
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val CANAL_KIOSCO = "com.evalPro.movil/modoKiosco"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            CANAL_KIOSCO
        ).setMethodCallHandler { llamada, resultado ->
            when (llamada.method) {
                "activar" -> {
                    val esDebuggable =
                        (applicationInfo.flags and ApplicationInfo.FLAG_DEBUGGABLE) != 0
                    // FLAG_SECURE: bloquea capturas de pantalla y grabacion
                    window.setFlags(
                        WindowManager.LayoutParams.FLAG_SECURE,
                        WindowManager.LayoutParams.FLAG_SECURE
                    )
                    // En debug evitamos startLockTask para no interrumpir el flujo con el dialogo del sistema.
                    if (esDebuggable) {
                        resultado.success(true)
                    } else {
                        try {
                            // startLockTask: inicia el modo kiosco (puede pedir confirmacion en primer uso).
                            startLockTask()
                            resultado.success(true)
                        } catch (error: Exception) {
                            resultado.error(
                                "MODO_KIOSCO_ERROR",
                                error.message ?: "No fue posible activar modo kiosco",
                                null
                            )
                        }
                    }
                }
                "desactivar" -> {
                    val esDebuggable =
                        (applicationInfo.flags and ApplicationInfo.FLAG_DEBUGGABLE) != 0
                    if (!esDebuggable) {
                        try {
                            stopLockTask()
                        } catch (_: Exception) {
                            // Ignorar cuando lock task no este activo.
                        }
                    }
                    window.clearFlags(WindowManager.LayoutParams.FLAG_SECURE)
                    resultado.success(null)
                }
                else -> resultado.notImplemented()
            }
        }
    }
}
