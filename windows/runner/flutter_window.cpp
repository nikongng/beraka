#include "flutter_window.h"

#include <optional>

#include "flutter/generated_plugin_registrant.h"

// --- Ajouts pour la gestion de l'imprimante ---
#include <windows.h>
#include <winspool.h>
#include <flutter/method_channel.h>
#include <flutter/standard_method_codec.h>
#include <vector>
#include <string>
// ----------------------------------------------

FlutterWindow::FlutterWindow(const flutter::DartProject& project)
    : project_(project) {}

FlutterWindow::~FlutterWindow() {}

// Fonction utilitaire requise par l'API Windows (les noms d'imprimantes sont en UTF-16)
std::wstring Utf8ToUtf16(const std::string& utf8_string) {
  if (utf8_string.empty()) return std::wstring();
  int size_needed = MultiByteToWideChar(CP_UTF8, 0, &utf8_string[0], (int)utf8_string.size(), NULL, 0);
  std::wstring wstrTo(size_needed, 0);
  MultiByteToWideChar(CP_UTF8, 0, &utf8_string[0], (int)utf8_string.size(), &wstrTo[0], size_needed);
  return wstrTo;
}

bool FlutterWindow::OnCreate() {
  if (!Win32Window::OnCreate()) {
    return false;
  }

  RECT frame = GetClientArea();

  // The size here must match the window dimensions to avoid unnecessary surface
  // creation / destruction in the startup path.
  flutter_controller_ = std::make_unique<flutter::FlutterViewController>(
      frame.right - frame.left, frame.bottom - frame.top, project_);
  // Ensure that basic setup of the controller was successful.
  if (!flutter_controller_->engine() || !flutter_controller_->view()) {
    return false;
  }
  RegisterPlugins(flutter_controller_->engine());

  // --- DEBUT DU CODE DU CANAL DE COMMUNICATION IMPRIMANTE ---
  flutter::MethodChannel<> channel(
      flutter_controller_->engine()->messenger(), "com.votre_app/printer_status",
      &flutter::StandardMethodCodec::GetInstance());

  channel.SetMethodCallHandler(
      [](const flutter::MethodCall<flutter::EncodableValue>& call,
         std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result) {
        
        if (call.method_name() == "getRealStatus") {
          const auto* arguments = std::get_if<flutter::EncodableMap>(call.arguments());
          if (!arguments) {
              result->Error("BAD_ARGS", "Arguments manquants");
              return;
          }
          
          auto printer_name_it = arguments->find(flutter::EncodableValue("printerName"));
          if (printer_name_it == arguments->end() || !std::holds_alternative<std::string>(printer_name_it->second)) {
              result->Error("BAD_ARGS", "Nom de l'imprimante requis");
              return;
          }

          std::string printer_name_utf8 = std::get<std::string>(printer_name_it->second);
          std::wstring printer_name_utf16 = Utf8ToUtf16(printer_name_utf8);

          HANDLE hPrinter;
          // Ouverture de la communication avec l'imprimante
          if (!OpenPrinterW(const_cast<LPWSTR>(printer_name_utf16.c_str()), &hPrinter, NULL)) {
              result->Success(flutter::EncodableValue("INCONNU (Non trouvable)"));
              return;
          }

          DWORD cbNeeded = 0;
          // Premier appel pour avoir la taille de la structure mémoire nécessaire
          GetPrinterW(hPrinter, 2, NULL, 0, &cbNeeded);
          if (cbNeeded == 0) {
              ClosePrinter(hPrinter);
              result->Success(flutter::EncodableValue("INCONNU (Taille erreur)"));
              return;
          }

          std::vector<BYTE> buffer(cbNeeded);
          PRINTER_INFO_2W* pInfo = reinterpret_cast<PRINTER_INFO_2W*>(buffer.data());

          // Deuxième appel pour lire les vraies informations matérielles
          if (GetPrinterW(hPrinter, 2, buffer.data(), cbNeeded, &cbNeeded)) {
              DWORD status = pInfo->Status;
              ClosePrinter(hPrinter);

              std::string statusStr = "READY";
              
              // Masques de bits pour vérifier les statuts matériels profonds
              if (status & PRINTER_STATUS_OFFLINE) statusStr = "OFFLINE";
              else if (status & PRINTER_STATUS_PAPER_JAM) statusStr = "PAPER_JAM";
              else if (status & PRINTER_STATUS_PAPER_OUT) statusStr = "PAPER_OUT";
              else if (status & PRINTER_STATUS_ERROR) statusStr = "ERROR";
              else if (status & PRINTER_STATUS_NOT_AVAILABLE) statusStr = "OFFLINE";

              result->Success(flutter::EncodableValue(statusStr));
          } else {
              ClosePrinter(hPrinter);
              result->Success(flutter::EncodableValue("INCONNU (Lecture échouée)"));
          }
        } else {
          result->NotImplemented();
        }
      });
  // --- FIN DU CODE DU CANAL DE COMMUNICATION IMPRIMANTE ---

  SetChildContent(flutter_controller_->view()->GetNativeWindow());

  flutter_controller_->engine()->SetNextFrameCallback([&]() {
    this->Show();
  });

  // Flutter can complete the first frame before the "show window" callback is
  // registered. The following call ensures a frame is pending to ensure the
  // window is shown. It is a no-op if the first frame hasn't completed yet.
  flutter_controller_->ForceRedraw();

  return true;
}

void FlutterWindow::OnDestroy() {
  if (flutter_controller_) {
    flutter_controller_ = nullptr;
  }

  Win32Window::OnDestroy();
}

LRESULT
FlutterWindow::MessageHandler(HWND hwnd, UINT const message,
                              WPARAM const wparam,
                              LPARAM const lparam) noexcept {
  // Give Flutter, including plugins, an opportunity to handle window messages.
  if (flutter_controller_) {
    std::optional<LRESULT> result =
        flutter_controller_->HandleTopLevelWindowProc(hwnd, message, wparam,
                                                      lparam);
    if (result) {
      return *result;
    }
  }

  switch (message) {
    case WM_FONTCHANGE:
      flutter_controller_->engine()->ReloadSystemFonts();
      break;
  }

  return Win32Window::MessageHandler(hwnd, message, wparam, lparam);
}