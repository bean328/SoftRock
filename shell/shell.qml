// SoftRock Shell entry point. Quickshell loads this file.
import Quickshell
import QtQuick

ShellRoot {
    // One bar per connected screen; bars appear and disappear with monitors.
    Variants {
        model: Quickshell.screens

        Bar {
            required property var modelData
            screen: modelData
        }
    }
}
