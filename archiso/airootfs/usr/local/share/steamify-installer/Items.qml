// The Steamify page's rows when `steamify.sh --defaults --list` can't be run
// (see calamares-online.sh, which writes the real list over this copy in
// /usr/local/share/steamify/qml at the start of the installer).
pragma Singleton
import QtQuick

QtObject {
    readonly property var rows: [
        { id: "gaming", label: "SteamOS conversion", hint: "boot into gaming mode, Steam on the desktop", kind: "toggle", parent: "", on: true, selectable: true },
        { id: "boot", label: "Boot into", hint: "", kind: "choice", parent: "gaming", on: false, selectable: true },
        { id: "theme", label: "Install SteamOS theme", hint: "Vapor look (cachyos-vapor)", kind: "toggle", parent: "", on: true, selectable: true },
        { id: "glyphs", label: "Install Steam Deck/Machine icons", hint: "Deck button icons in gaming mode", kind: "toggle", parent: "", on: true, selectable: true },
        { id: "single", label: "Single user mode", hint: "no password, lock screen or log out (SDDM)", kind: "toggle", parent: "", on: true, selectable: true },
        { id: "launcher", label: "Steamify shortcut", hint: "the app on the desktop, Steamify Terminal in the launcher", kind: "toggle", parent: "", on: true, selectable: true },
        { id: "notify", label: "Update notifications", hint: "a notification when there's a new Steamify", kind: "toggle", parent: "", on: true, selectable: true },
        { id: "cec", label: "HDMI-CEC", hint: "use Steam with the TV remote, TV on/off with the PC", kind: "toggle", parent: "", on: true, selectable: true },
        { id: "machine", label: "Steam Machine support", hint: "LED bar driver, hardware settings in Steam", kind: "toggle", parent: "", on: true, selectable: true },
        { id: "poweroff", label: "Power-off fix", hint: "the Steam Machine stays off after shutting down", kind: "toggle", parent: "machine", on: true, selectable: true }
    ]
}
