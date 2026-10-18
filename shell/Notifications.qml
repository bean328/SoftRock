// SoftRock notification server and popups, top right under the bar.
// Popups expire on their own unless they are critical; click to dismiss.
import Quickshell
import Quickshell.Services.Notifications
import QtQuick

Scope {
    NotificationServer {
        id: server
        bodySupported: true
        actionsSupported: false
        imageSupported: false
        keepOnReload: false

        onNotification: n => {
            n.tracked = true;
        }
    }

    PanelWindow {
        visible: server.trackedNotifications.values.length > 0
        anchors.top: true
        anchors.right: true
        margins.top: Theme.spacingS
        margins.right: Theme.spacingS
        exclusiveZone: 0
        implicitWidth: 360
        implicitHeight: column.implicitHeight
        color: "transparent"

        Column {
            id: column
            width: parent.width
            spacing: Theme.spacingS

            Repeater {
                model: server.trackedNotifications

                Rectangle {
                    id: card
                    required property var modelData
                    readonly property bool critical: modelData.urgency === NotificationUrgency.Critical

                    width: column.width
                    height: content.implicitHeight + Theme.spacingL * 2
                    radius: Theme.radiusMedium
                    color: Theme.surface
                    border.width: 1
                    border.color: critical ? Theme.bad : Theme.border

                    Timer {
                        running: !card.critical
                        interval: card.modelData.expireTimeout > 0 ? card.modelData.expireTimeout * 1000 : 5000
                        onTriggered: card.modelData.expire()
                    }

                    Column {
                        id: content
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.top: parent.top
                        anchors.margins: Theme.spacingL
                        spacing: Theme.spacingXs

                        Text {
                            width: parent.width
                            text: card.modelData.appName
                            visible: text !== ""
                            color: Theme.textMuted
                            font.family: Theme.fontUi
                            font.pixelSize: Theme.fontSizeSmall
                        }
                        Text {
                            width: parent.width
                            text: card.modelData.summary
                            wrapMode: Text.Wrap
                            color: Theme.text
                            font.family: Theme.fontUi
                            font.pixelSize: Theme.fontSizeBody
                            font.weight: Font.DemiBold
                        }
                        Text {
                            width: parent.width
                            text: card.modelData.body
                            visible: text !== ""
                            wrapMode: Text.Wrap
                            maximumLineCount: 4
                            elide: Text.ElideRight
                            textFormat: Text.PlainText
                            color: Theme.textMuted
                            font.family: Theme.fontUi
                            font.pixelSize: Theme.fontSizeBody
                        }
                    }

                    MouseArea {
                        anchors.fill: parent
                        onClicked: card.modelData.dismiss()
                    }
                }
            }
        }
    }
}
