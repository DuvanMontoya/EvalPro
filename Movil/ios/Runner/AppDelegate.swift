/**
 * @archivo   AppDelegate.swift
 * @descripcion AppDelegate iOS. Registra el MethodChannel para el modo
 *              examen usando AEAssessmentSession de Apple.
 * @modulo    ModoKiosco (iOS nativo)
 * @autor     EvalPro
 * @fecha     2026-03-02
 */
import UIKit
import Flutter
import AutomaticAssessmentConfiguration

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {

    private var sesionEvaluacion: AEAssessmentSession?
    private let CANAL_KIOSCO = "com.evalPro.movil/modoKiosco"

    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {

        let controlador = window?.rootViewController as! FlutterViewController
        let canal = FlutterMethodChannel(
            name: CANAL_KIOSCO,
            binaryMessenger: controlador.binaryMessenger
        )

        canal.setMethodCallHandler { [weak self] (llamada, resultado) in
            guard let self = self else { return }
            switch llamada.method {
            case "activar":
                let configuracion = AEAssessmentConfiguration()
                // AEAssessmentSession deshabilita automaticamente:
                // capturas, grabacion, autocompletar, diccionarios, notificaciones
                let sesion = AEAssessmentSession(configuration: configuracion)
                sesion.delegate = self
                sesion.begin()
                self.sesionEvaluacion = sesion
                resultado(true)
            case "desactivar":
                self.sesionEvaluacion?.end()
                self.sesionEvaluacion = nil
                resultado(nil)
            default:
                resultado(FlutterMethodNotImplemented)
            }
        }

        GeneratedPluginRegistrant.register(with: self)
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
}

extension AppDelegate: AEAssessmentSessionDelegate {
    // El estudiante intento forzar el cierre o hubo interrupcion
    func assessmentSession(
        _ session: AEAssessmentSession,
        wasInterruptedWithError error: Error
    ) {
        // Notificar a Flutter via EventChannel (implementar si se requiere canal de eventos)
        // El ModoExamenServicio detectara esto via AppLifecycleState
        sesionEvaluacion = nil
    }

    func assessmentSession(
        _ session: AEAssessmentSession,
        failedToBeginWithError error: Error
    ) {
        // El SO rechazo iniciar la sesion de evaluacion
        sesionEvaluacion = nil
    }
}