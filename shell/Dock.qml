// Bottom dock: pinned apps, with a dot under the ones that are running.
// Clicking a running app focuses it; otherwise it launches.
import Quickshell
import Quickshell.Wayland
import QtQuick

PanelWindow {
    id: dock

    readonly property var pinned: ["firefox-esr", "thunar", "foot"]

    anchors.bottom: true
    margins.bottom: Theme.spacingS
    implicitWidth: row.implicitWidth + Theme.spacingM * 2
    implicitHeight: 64
    color: "transparent"

    Rectangle {
        anchors.fill: parent
        radius: Theme.radiusLarge
        color: Theme.surface
        border.color: Theme.border
        border.width: 1
    }

    Row {
        id: row
        anchors.centerIn: parent
        spacing: Theme.spacingS

        Repeater {
            model: dock.pinned

            Item {
                id: slot
                required property string modelData
                readonly property var entry: DesktopEntries.byId(modelData)
                readonly property var window: ToplevelManager.toplevels.values.find(t => t.appId === modelData) ?? null

                visible: entry !== null
                width: 48
                height: 52

                Rectangle {
                    anchors.horizontalCenter: parent.horizontalCenter
                    y: 2
                    width: 44
                    height: 44
                    radius: Theme.radiusMedium
                    color: mouse.containsMouse ? Theme.surfaceAlt : "transparent"

                    Behavior on color {
                        ColorAnimation { duration: Theme.motionFast }
                    }

                    Image {
                        anchors.centerIn: parent
                        width: 32
                        height: 32
                        sourceSize.width: 32
                        sourceSize.height: 32
                        source: slot.entry ? Quickshell.iconPath(slot.entry.icon) : ""
                    }
                }

                Rectangle {
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.bottom: parent.bottom
                    width: slot.window ? 6 : 0
                    height: 4
                    radius: Theme.radiusPill
                    color: Theme.accent
                }

                MouseArea {
                    id: mouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        if (slot.window)
                            slot.window.activate();
                        else if (slot.entry)
                            slot.entry.execute();
                    }
                }
            }
        }
    }
}
