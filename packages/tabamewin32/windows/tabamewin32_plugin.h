#ifndef FLUTTER_PLUGIN_TABAMEWIN32_PLUGIN_H_
#define FLUTTER_PLUGIN_TABAMEWIN32_PLUGIN_H_

#include <flutter/method_channel.h>
#include <flutter/plugin_registrar_windows.h>

#include <memory>

extern HHOOK g_MouseHook;
extern HWINEVENTHOOK g_EventHook;

namespace tabamewin32
{

    class Tabamewin32Plugin : public flutter::Plugin
    {
    public:
        static void RegisterWithRegistrar(flutter::PluginRegistrarWindows *registrar);

        Tabamewin32Plugin();

        virtual ~Tabamewin32Plugin();

        // Disallow copy and assign.
        Tabamewin32Plugin(const Tabamewin32Plugin &) = delete;
        Tabamewin32Plugin &operator=(const Tabamewin32Plugin &) = delete;

    private:
        // Called when a method is called on this plugin's channel from Dart.
        void HandleMethodCall(
            const flutter::MethodCall<flutter::EncodableValue> &method_call,
            std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result);
    };

} // namespace tabamewin32

#endif // FLUTTER_PLUGIN_TABAMEWIN32_PLUGIN_H_
