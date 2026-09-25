// Five workspace pills. The focused one widens and takes the accent color.
import Quickshell.Hyprland
import QtQuick

Row {
    spacing: Theme.spacingS

    Repeater {
        model: 5

        Rectangle {
            required property int index
            readonly property int wsId: index + 1
            readonly property bool focused: Hyprland.focusedWorkspace !== null && Hyprland.focusedWorkspace.id === wsId
            readonly property bool occupied: Hyprland.workspaces.values.some(ws => ws.id === wsId)

            anchors.verticalCenter: parent.verticalCenter
            width: focused ? 28 : 10
            height: 10
            radius: Theme.radiusPill
            color: focused ? Theme.accent : (occupied ? Theme.textMuted : Theme.border)

            Behavior on width {
                NumberAnimation { duration: Theme.motionNormal; easing.type: Easing.OutCubic }
            }

            MouseArea {
                anchors.fill: parent
                anchors.margins: -4
                cursorShape: Qt.PointingHandCursor
                onClicked: Hyprland.dispatch("workspace " + parent.wsId)
            }
        }
    }
}
