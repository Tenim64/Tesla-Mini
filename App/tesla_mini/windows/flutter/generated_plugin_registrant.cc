//
//  Generated file. Do not edit.
//

// clang-format off

#include "generated_plugin_registrant.h"

#include <network_info_plus/network_info_plus_windows_plugin.h>
#include <tflite_flutter_helper/tflite_flutter_helper_plugin.h>

void RegisterPlugins(flutter::PluginRegistry* registry) {
  NetworkInfoPlusWindowsPluginRegisterWithRegistrar(
      registry->GetRegistrarForPlugin("NetworkInfoPlusWindowsPlugin"));
  TfliteFlutterHelperPluginRegisterWithRegistrar(
      registry->GetRegistrarForPlugin("TfliteFlutterHelperPlugin"));
}
