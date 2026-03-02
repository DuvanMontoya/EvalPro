/**
 * @archivo   MainActivity.kt
 * @descripcion Actividad principal Android. Registra el MethodChannel
 *              para el modo kiosco usando startLockTask() y FLAG_SECURE.
 * @modulo    ModoKiosco (Android nativo)
 * @autor     EvalPro
 * @fecha     2026-03-02
 */
package com.evalpro.movil

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
                    // FLAG_SECURE: bloquea capturas de pantalla y grabacion
                    window.setFlags(
                        WindowManager.LayoutParams.FLAG_SECURE,
                        WindowManager.LayoutParams.FLAG_SECURE
                    )
                    // startLockTask: inicia el modo kiosco — pide confirmacion al usuario
                    startLockTask()
                    resultado.success(true)
                }
                "desactivar" -> {
                    stopLockTask()
                    window.clearFlags(WindowManager.LayoutParams.FLAG_SECURE)
                    resultado.success(null)
                }
                else -> resultado.notImplemented()
            }
        }
    }
}
