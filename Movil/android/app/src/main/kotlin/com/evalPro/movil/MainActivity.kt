/**
 * @archivo   MainActivity.kt
 * @descripcion Actividad principal Android con bloqueo estricto de examen:
 *              - Modo kiosco dedicado (Device Owner + LockTask).
 *              - Fallback a screen pinning cuando no hay Device Owner.
 *              - Reforzamiento continuo de inmersion.
 * @modulo    ModoKiosco (Android nativo)
 * @autor     EvalPro
 * @fecha     2026-03-05
 */
package com.evalpro.movil

import android.app.ActivityManager
import android.app.admin.DevicePolicyManager
import android.content.ComponentName
import android.content.Context
import android.os.Build
import android.view.KeyEvent
import android.view.View
import android.view.WindowInsets
import android.view.WindowInsetsController
import android.view.WindowManager
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

private const val ERROR_BLOQUEO_ESTRICTO_NO_DISPONIBLE = "BLOQUEO_ESTRICTO_NO_DISPONIBLE"
private const val CANAL_KIOSCO = "com.evalPro.movil/modoKiosco"

class MainActivity : FlutterActivity() {
    private var modoKioscoActivo: Boolean = false
    private val componenteAdmin: ComponentName by lazy {
        ComponentName(this, EvalProDeviceAdminReceiver::class.java)
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            CANAL_KIOSCO
        ).setMethodCallHandler { llamada, resultado ->
            when (llamada.method) {
                "activar" -> {
                    val requerirBloqueoEstricto =
                        llamada.argument<Boolean>("requerirBloqueoEstricto") ?: false
                    activarModoKiosco(
                        requerirBloqueoEstricto = requerirBloqueoEstricto,
                        resultado = resultado
                    )
                }

                "desactivar" -> {
                    desactivarModoKiosco()
                    resultado.success(null)
                }

                "estado" -> {
                    resultado.success(construirEstadoKiosco())
                }

                "reforzarInmersion" -> {
                    aplicarModoInmersion()
                    resultado.success(null)
                }

                else -> resultado.notImplemented()
            }
        }
    }

    override fun onResume() {
        super.onResume()
        if (modoKioscoActivo) {
            aplicarModoInmersion()
        }
    }

    override fun onWindowFocusChanged(hasFocus: Boolean) {
        super.onWindowFocusChanged(hasFocus)
        if (hasFocus && modoKioscoActivo) {
            aplicarModoInmersion()
        }
    }

    override fun onKeyDown(keyCode: Int, event: KeyEvent?): Boolean {
        if (modoKioscoActivo && keyCode == KeyEvent.KEYCODE_APP_SWITCH) {
            return true
        }
        return super.onKeyDown(keyCode, event)
    }

    private fun activarModoKiosco(
        requerirBloqueoEstricto: Boolean,
        resultado: MethodChannel.Result
    ) {
        aplicarProteccionVisualNativa()

        val politicaDispositivo = obtenerPoliticaDispositivo()
        val esDeviceOwner = politicaDispositivo?.isDeviceOwnerApp(packageName) == true
        val lockTaskPermitido = obtenerLockTaskPermitido(politicaDispositivo)

        if (esDeviceOwner && politicaDispositivo != null) {
            configurarPoliticasEstricto(politicaDispositivo)
        }

        var lockTaskActivo = false
        try {
            startLockTask()
            lockTaskActivo = estaEnLockTask()
        } catch (_: Exception) {
            lockTaskActivo = estaEnLockTask()
        }

        val bloqueoEstrictoActivo = esDeviceOwner && lockTaskActivo
        modoKioscoActivo = true

        if (requerirBloqueoEstricto && !bloqueoEstrictoActivo) {
            desactivarModoKiosco()
            resultado.error(
                ERROR_BLOQUEO_ESTRICTO_NO_DISPONIBLE,
                "No es posible aplicar bloqueo estricto sin Device Owner + LockTask.",
                construirEstadoKiosco()
            )
            return
        }

        val estado = construirEstadoKiosco(
            lockTaskActivoForzado = lockTaskActivo,
            lockTaskPermitidoForzado = lockTaskPermitido,
            deviceOwnerForzado = esDeviceOwner
        )
        resultado.success(estado)
    }

    private fun desactivarModoKiosco() {
        try {
            stopLockTask()
        } catch (_: Exception) {
            // Ignorar cuando lockTask no esté activo.
        }

        val politicaDispositivo = obtenerPoliticaDispositivo()
        val esDeviceOwner = politicaDispositivo?.isDeviceOwnerApp(packageName) == true
        if (esDeviceOwner && politicaDispositivo != null) {
            restaurarPoliticasEstricto(politicaDispositivo)
        }

        modoKioscoActivo = false
        limpiarProteccionVisualNativa()
    }

    private fun configurarPoliticasEstricto(politicaDispositivo: DevicePolicyManager) {
        try {
            politicaDispositivo.setLockTaskPackages(componenteAdmin, arrayOf(packageName))
        } catch (_: Exception) {
            // Mantener ejecución; puede fallar en dispositivos no provisionados.
        }
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.P) {
            try {
                politicaDispositivo.setLockTaskFeatures(
                    componenteAdmin,
                    DevicePolicyManager.LOCK_TASK_FEATURE_NONE
                )
            } catch (_: Exception) {
                // Continuar con lo disponible en el dispositivo.
            }
        }
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            try {
                politicaDispositivo.setStatusBarDisabled(componenteAdmin, true)
            } catch (_: Exception) {
                // Algunos OEM pueden restringir este llamado.
            }
        }
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            try {
                politicaDispositivo.setKeyguardDisabled(componenteAdmin, true)
            } catch (_: Exception) {
                // Puede no estar permitido por políticas del sistema.
            }
        }
    }

    private fun restaurarPoliticasEstricto(politicaDispositivo: DevicePolicyManager) {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.P) {
            val caracteristicasRestauradas =
                DevicePolicyManager.LOCK_TASK_FEATURE_HOME or
                    DevicePolicyManager.LOCK_TASK_FEATURE_OVERVIEW or
                    DevicePolicyManager.LOCK_TASK_FEATURE_NOTIFICATIONS or
                    DevicePolicyManager.LOCK_TASK_FEATURE_SYSTEM_INFO or
                    DevicePolicyManager.LOCK_TASK_FEATURE_GLOBAL_ACTIONS or
                    DevicePolicyManager.LOCK_TASK_FEATURE_KEYGUARD
            try {
                politicaDispositivo.setLockTaskFeatures(componenteAdmin, caracteristicasRestauradas)
            } catch (_: Exception) {
                // Ignorar y continuar con liberación visual.
            }
        }
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            try {
                politicaDispositivo.setStatusBarDisabled(componenteAdmin, false)
            } catch (_: Exception) {
                // Ignorar si no estaba aplicado.
            }
        }
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            try {
                politicaDispositivo.setKeyguardDisabled(componenteAdmin, false)
            } catch (_: Exception) {
                // Ignorar si no estaba aplicado.
            }
        }
    }

    private fun obtenerPoliticaDispositivo(): DevicePolicyManager? {
        return try {
            getSystemService(Context.DEVICE_POLICY_SERVICE) as DevicePolicyManager
        } catch (_: Exception) {
            null
        }
    }

    private fun obtenerLockTaskPermitido(politicaDispositivo: DevicePolicyManager?): Boolean {
        if (politicaDispositivo == null) {
            return false
        }
        return try {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                politicaDispositivo.isLockTaskPermitted(packageName)
            } else {
                false
            }
        } catch (_: Exception) {
            false
        }
    }

    private fun estaEnLockTask(): Boolean {
        val gestorActividad = getSystemService(Context.ACTIVITY_SERVICE) as ActivityManager
        return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            gestorActividad.lockTaskModeState != ActivityManager.LOCK_TASK_MODE_NONE
        } else {
            @Suppress("DEPRECATION")
            gestorActividad.isInLockTaskMode
        }
    }

    private fun construirEstadoKiosco(
        lockTaskActivoForzado: Boolean? = null,
        lockTaskPermitidoForzado: Boolean? = null,
        deviceOwnerForzado: Boolean? = null
    ): Map<String, Any> {
        val politicaDispositivo = obtenerPoliticaDispositivo()
        val deviceOwner = deviceOwnerForzado ?: (politicaDispositivo?.isDeviceOwnerApp(packageName) == true)
        val lockTaskPermitido = lockTaskPermitidoForzado ?: obtenerLockTaskPermitido(politicaDispositivo)
        val lockTaskActivo = lockTaskActivoForzado ?: estaEnLockTask()
        // Si la app es Device Owner, puede configurar lock task en el momento de activar.
        // No requerimos que esté preconfigurado en estado previo.
        val bloqueoEstrictoDisponible = deviceOwner
        val bloqueoEstrictoActivo = deviceOwner && lockTaskActivo
        val modo = when {
            bloqueoEstrictoActivo -> "DEVICE_OWNER"
            lockTaskActivo -> "SCREEN_PINNING"
            modoKioscoActivo -> "SOFT"
            else -> "INACTIVO"
        }

        return mapOf(
            "activo" to modoKioscoActivo,
            "lockTaskActivo" to lockTaskActivo,
            "lockTaskPermitido" to lockTaskPermitido,
            "dispositivoPropietario" to deviceOwner,
            "bloqueoEstrictoDisponible" to bloqueoEstrictoDisponible,
            "bloqueoEstrictoActivo" to bloqueoEstrictoActivo,
            "modo" to modo
        )
    }

    private fun aplicarProteccionVisualNativa() {
        window.addFlags(
            WindowManager.LayoutParams.FLAG_SECURE or
                WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON
        )
        aplicarModoInmersion()
    }

    private fun limpiarProteccionVisualNativa() {
        window.clearFlags(
            WindowManager.LayoutParams.FLAG_SECURE or
                WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON
        )
    }

    private fun aplicarModoInmersion() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
            window.insetsController?.let { controlador ->
                controlador.hide(WindowInsets.Type.statusBars() or WindowInsets.Type.navigationBars())
                controlador.systemBarsBehavior =
                    WindowInsetsController.BEHAVIOR_SHOW_TRANSIENT_BARS_BY_SWIPE
            }
            return
        }

        @Suppress("DEPRECATION")
        window.decorView.systemUiVisibility =
            View.SYSTEM_UI_FLAG_IMMERSIVE_STICKY or
                View.SYSTEM_UI_FLAG_LAYOUT_STABLE or
                View.SYSTEM_UI_FLAG_LAYOUT_HIDE_NAVIGATION or
                View.SYSTEM_UI_FLAG_LAYOUT_FULLSCREEN or
                View.SYSTEM_UI_FLAG_HIDE_NAVIGATION or
                View.SYSTEM_UI_FLAG_FULLSCREEN
    }
}
