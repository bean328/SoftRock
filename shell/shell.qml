// SoftRock Shell entry point. Quickshell loads this file.
import Quickshell
import QtQuick

ShellRoot {
    // One bar and one dock per connected screen; they follow monitors.
    Variants {
        model: Quickshell.screens

        Scope {
            id: perScreen
            required property var modelData

            Bar {
                screen: perScreen.modelData
            }
            Dock {
                screen: perScreen.modelData
            }
        }
    }

    Notifications {}
}
