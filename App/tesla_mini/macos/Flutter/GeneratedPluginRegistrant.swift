//
//  Generated file. Do not edit.
//

import FlutterMacOS
import Foundation

import firebase_core
import firebase_ml_model_downloader
import network_info_plus
import path_provider_foundation
import tflite_flutter_helper
import wakelock_macos

func RegisterGeneratedPlugins(registry: FlutterPluginRegistry) {
  FLTFirebaseCorePlugin.register(with: registry.registrar(forPlugin: "FLTFirebaseCorePlugin"))
  FirebaseModelDownloaderPlugin.register(with: registry.registrar(forPlugin: "FirebaseModelDownloaderPlugin"))
  NetworkInfoPlusPlugin.register(with: registry.registrar(forPlugin: "NetworkInfoPlusPlugin"))
  PathProviderPlugin.register(with: registry.registrar(forPlugin: "PathProviderPlugin"))
  TfliteFlutterHelperPlugin.register(with: registry.registrar(forPlugin: "TfliteFlutterHelperPlugin"))
  WakelockMacosPlugin.register(with: registry.registrar(forPlugin: "WakelockMacosPlugin"))
}
