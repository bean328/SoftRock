// Top bar: workspaces on the left, focused window in the middle, status on the right.
import Quickshell
import Quickshell.Wayland
import Quickshell.Services.UPower
import QtQuick
import QtQuick.Layouts

PanelWindow {
    id: bar

    anchors {
        top: true
        left: true
        right: true
    }
    implicitHeight: Theme.barHeight
    color: Theme.background

    Rectangle {
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        height: 1
        color: Theme.border
    }

    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: Theme.spacingL
        anchors.rightMargin: Theme.spacingL
        spacing: Theme.spacingL

        Workspaces {}

        Text {
            Layout.fillWidth: true
            horizontalAlignment: Text.AlignHCenter
            elide: Text.ElideRight
            text: ToplevelManager.activeToplevel ? ToplevelManager.activeToplevel.title : ""
            color: Theme.textMuted
            font.family: Theme.fontUi
            font.pixelSize: Theme.fontSizeBody
        }

        // Only create the battery item on machines that have one.
        Loader {
            active: UPower.displayDevice && UPower.displayDevice.isLaptopBattery
            visible: active
            sourceComponent: BatteryIndicator {}
        }

        Clock {}
    }
}
